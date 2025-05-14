//
//  OAuth2TokenStorage.swift
//  ImageLenta
//
//  Created by Ди Di on 22/03/25.
//

import Foundation
import SwiftKeychainWrapper


final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    private init() {}
    
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
