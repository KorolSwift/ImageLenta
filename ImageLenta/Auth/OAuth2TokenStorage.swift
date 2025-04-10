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
//    private let firstLaunchKey = "isFirstLaunch"
//    
//    init() {
//        let isFirstLaunch = !UserDefaults.standard.bool(forKey: firstLaunchKey)
//        if isFirstLaunch {
//            KeychainWrapper.standard.removeObject(forKey: tokenKey)
//            UserDefaults.standard.set(true, forKey: firstLaunchKey)
//            print("[OAuth2TokenStorage INIT] First launch — token removed from Keychain")
//        }
//    }
    
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



