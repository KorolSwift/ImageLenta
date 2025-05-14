//
//  ImagesListService.swift
//  ImageLenta
//
//  Created by Ди Di on 17/04/25.
//

import Foundation
import UserNotifications


public class ImagesListService: ImagesListServiceProtocol {
    static let shared = ImagesListService()
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) public var photos: [Photo] = []
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
    
    public struct Photo {
        public let id: String
        public let size: CGSize
        public let createdAt: Date?
        public let welcomeDescription: String?
        public let thumbImageURL: String
        public let largeImageURL: String
        public var isLiked: Bool
        
        public init(
            id: String,
            size: CGSize,
            createdAt: Date?,
            welcomeDescription: String?,
            thumbImageURL: String,
            largeImageURL: String,
            isLiked: Bool
        ) {
            self.id = id
            self.size = size
            self.createdAt = createdAt
            self.welcomeDescription = welcomeDescription
            self.thumbImageURL = thumbImageURL
            self.largeImageURL = largeImageURL
            self.isLiked = isLiked
        }
    }
    
    public func fetchPhotosNextPage(for username: String, token: String, completion: @escaping (Result<[ImagesListService.Photo], Error>) -> Void) {
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
            completion(.failure(NSError(domain: "InvalidURL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = NetworkClient().objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let photoResults):
                    let newPhotos: [Photo] = photoResults.map { result in
                        Photo(
                            id: result.id,
                            size: result.size,
                            createdAt: result.createdAt.flatMap { self.isoDateFormatter.date(from: $0) },
                            welcomeDescription: result.welcomeDescription,
                            thumbImageURL: result.urls.thumb,
                            largeImageURL: result.urls.large,
                            isLiked: result.likedByUser
                        )
                    }
                    
                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                    
                    completion(.success(newPhotos))
                case .failure(let error):
                    print("[ImageListService:fetchPhotosNextPage]: Ошибка - \(error.localizedDescription), username: \(username)")
                    completion(.failure(error))
                }
            } }
    }
    
    public func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    public func cleanPhotos() {
        photos = []
        lastLoadedPage = nil
    }
}
