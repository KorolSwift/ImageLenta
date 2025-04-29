//
//  ProfileService.swift
//  ImageLenta
//
//  Created by Ди Di on 05/04/25.
//

import Foundation


final class ProfileService {
    
    private let urlSession = URLSession.shared
    static let shared = ProfileService()
    private init() {}
    private(set) var profile: Profile?
    
    struct ProfileResult: Codable {
        let username: String
        let firstName: String
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
    
    struct Profile: Codable {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
    }
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        let url = Constants.defaultBaseURL.appendingPathComponent("me")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = NetworkClient().objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let decodedProfileResult):
                    let profile = Profile(
                        username: decodedProfileResult.username,
                        name: "\(decodedProfileResult.firstName) \(decodedProfileResult.lastName ?? "")",
                        loginName: "@\(decodedProfileResult.username)",
                        bio: decodedProfileResult.bio
                    )
                    guard let self = self else { return }
                    self.profile = profile
                    completion(.success(profile))
                    
                case .failure(let error):
                    print("[ProfileService:fetchProfile]: Ошибка - \(error.localizedDescription), token: \(token)")
                    
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func cleanProfile() {
        profile = nil
    }
}
