//
//  ProfilePhoto.swift
//  ImageLenta
//
//  Created by Ди Di on 05/04/25.
//

import Foundation


final class ProfileImageService {
    private let urlSession = URLSession.shared
    private init() {}
    static let shared = ProfileImageService()
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    struct ProfileImage: Codable {
        let profileImageSmall: String
        
        enum CodingKeys: String, CodingKey {
            case profileImageSmall = "small"
        }
    }
    
    func fetchProfileImage(for username: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = Constants.defaultBaseURL
            .appendingPathComponent("users")
            .appendingPathComponent(username)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue
        
        let task = NetworkClient().objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let decodedProfilePhotoResult):
                    let avatarURL = decodedProfilePhotoResult.profileImage.profileImageSmall
                    guard let self = self else { return }
                    self.avatarURL = avatarURL
                    
                    completion(.success(avatarURL))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL]
                        )
                    
                case .failure(let error):
                    print("[ProfileImageService:fetchProfileImage]: Ошибка - \(error.localizedDescription), username: \(username)")
                    completion(.failure(error))
                    
                }
            }
        }
        task.resume()
    }
}


