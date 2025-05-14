//
//  MockProfileService.swift
//  ImageLenta
//
//  Created by Ди Di on 11/05/25.
//

import Foundation
@testable import ImageLenta


final class MockProfileService: ProfileServiceProtocol {
    let profile: ProfileService.Profile? = ProfileService.Profile(
        username: "mock_user",
        name: "Mock User",
        loginName: "@mock_user",
        bio: "Test profile"
    )
    
    func fetchProfile(token: String, completion: @escaping (Result<ProfileService.Profile, Error>) -> Void) {
        if let profile = profile {
            completion(.success(profile))
        } else {
            completion(.failure(NSError(domain: "MockProfileService", code: -1)))
        }
    }
}
