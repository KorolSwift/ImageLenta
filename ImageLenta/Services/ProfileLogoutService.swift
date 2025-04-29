//
//  ProfileLogoutService.swift
//  ImageLenta
//
//  Created by Ди Di on 24/04/25.
//

import Foundation
import WebKit


final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        cleanCookies()
        OAuth2TokenStorage.shared.clearToken()
        ProfileImageService.shared.cleanAvatar()
        ProfileService.shared.cleanProfile()
        ImagesListService.shared.cleanPhotos()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
