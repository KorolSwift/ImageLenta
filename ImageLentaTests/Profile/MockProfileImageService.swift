//
//  MockProfileImageService.swift
//  ImageLenta
//
//  Created by Ди Di on 11/05/25.
//

import Foundation
@testable import ImageLenta


final class MockProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String? = "https://example.com/avatar.png"
}
