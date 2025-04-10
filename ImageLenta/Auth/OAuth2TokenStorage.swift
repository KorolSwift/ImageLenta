//
//  OAuth2TokenStorage.swift
//  ImageLenta
//
//  Created by Ди Di on 22/03/25.
//

import Foundation
import SwiftKeychainWrapper


final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
            
        } set {
            guard let token = newValue else {
                return
            }
            KeychainWrapper.standard.set(token, forKey: tokenKey)
        }
    }
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}



