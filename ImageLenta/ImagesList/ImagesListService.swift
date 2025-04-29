//
//  ImagesListService.swift
//  ImageLenta
//
//  Created by Ди Di on 17/04/25.
//

import Foundation
import UserNotifications


class ImagesListService {
    
    static let shared = ImagesListService()
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private let isoDateFormatter = ISO8601DateFormatter()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    struct PhotoResult: Codable {
        let id: String
        let createdAt: String?
        let width: Int
        let height: Int
        var size: CGSize {
            CGSize(width: width, height: height)
        }
        let welcomeDescription: String?
        let urls: UrlsResult
        let likedByUser: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case createdAt = "created_at"
            case width
            case height
            case welcomeDescription = "description"
            case urls
            case likedByUser = "liked_by_user"
        }
    }
    
    struct UrlsResult: Codable {
        let thumb: String
        let large: String
        
        enum CodingKeys: String, CodingKey {
            case thumb
            case large = "full"
        }
    }
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        var isLiked: Bool
    }
    
    func fetchPhotosNextPage(for username: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        

        var urlComponents = URLComponents(
            url: Constants.defaultBaseURL.appendingPathComponent("photos"),
            resolvingAgainstBaseURL: false
        )
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents?.url else {
            print("Невалидный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue
        
        let networkTask = NetworkClient().objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                
                switch result {
                case .success(let decodedPhotoResult):
                    let photos = decodedPhotoResult.map { photoResult in
                        Photo(
                            id: photoResult.id,
                            size: photoResult.size,
                            createdAt: photoResult.createdAt.flatMap { self.isoDateFormatter.date(from: $0) },
                            welcomeDescription: photoResult.welcomeDescription,
                            thumbImageURL: photoResult.urls.thumb,
                            largeImageURL: photoResult.urls.large,
                            isLiked: photoResult.likedByUser
                        )}
                    self.photos.append(contentsOf: photos)
                    self.lastLoadedPage = (self.lastLoadedPage ?? 0) + 1
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    
                    completion(.success("success"))
                    
                case .failure(let error):
                    print("[ImageListService:fetchPhotosNextPage]: Ошибка - \(error.localizedDescription), username: \(username)")
                    completion(.failure(error))
                }
            } }
        self.task = networkTask
        networkTask.resume()
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else { return }
        print("Отправляем запрос \(isLiked ? "DELETE" : "POST") на фото с ID: \(photoId)")
        
        let urlmethod = isLiked ? "DELETE" : "POST"
        
        var request = URLRequest(
            url: Constants.defaultBaseURL
                .appendingPathComponent("photos")
                .appendingPathComponent(photoId)
                .appendingPathComponent("like")
        )
        
        request.httpMethod = urlmethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        enum NetworkError: Error {
            case urlSessionError
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                struct Wrapper: Decodable {
                    struct PhotoObj: Decodable {
                        let id: String
                        let liked_by_user: Bool
                    }
                    let photo: PhotoObj
                }
                
                do {
                    let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
                    if let idx = self.photos.firstIndex(where: { $0.id == wrapper.photo.id }) {
                        self.photos[idx].isLiked = wrapper.photo.liked_by_user
                    }
                    completion(.success(()))
                } catch {
                    print("[changeLike] Ошибка парсинга: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func cleanPhotos() {
        photos = []
        lastLoadedPage = nil
    }
}
