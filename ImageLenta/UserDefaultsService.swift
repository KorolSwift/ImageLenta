//
//  UserDefaultsService.swift
//  ImageLenta
//
//  Created by Ди Di on 11/04/25.
//

import Foundation


final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    private init() {}
    
    private enum Key {
        static let hasLaunchedBefore = "hasLaunchedBefore"
    }
    
    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Key.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Key.hasLaunchedBefore) }
    }
}
