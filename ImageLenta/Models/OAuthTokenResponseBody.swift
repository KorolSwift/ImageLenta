//
//  Untitled.swift
//  ImageLenta
//
//  Created by Ди Di on 22/03/25.
//

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
