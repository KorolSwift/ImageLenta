//
//  OAuth2TokenStorage.swift
//  ImageLenta
//
//  Created by Ди Di on 22/03/25.
//

import Foundation


final class OAuth2TokenStorage {
    private let defaults = UserDefaults.standard
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            let storedValue = defaults.string(forKey: tokenKey)
            print("[OAuth2TokenStorage GET] token = \(String(describing: storedValue))")
            return storedValue
        }
        set {
            defaults.setValue(newValue, forKey: tokenKey)
            print("[OAuth2TokenStorage SET] newValue = \(String(describing: newValue))")
        }
    }
}
