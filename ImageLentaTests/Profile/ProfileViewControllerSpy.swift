//
//  ProfileViewControllerSpy.swift
//  ImageLenta
//
//  Created by Ди Di on 11/05/25.
//

import ImageLenta
import Foundation


final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var setProfileInfoCalled = false
    var receivedName: String?
    var receivedUsername: String?
    var receivedDescription: String?
    var setAvatarCalled = false
    var receivedAvatarURL: URL?
    var showLogoutAlertCalled = false
    
    func setProfileInfo(name: String, username: String, description: String) {
        setProfileInfoCalled = true
        receivedName = name
        receivedUsername = username
        receivedDescription = description
    }
    
    func setAvatar(url: URL) {
        setAvatarCalled = true
        receivedAvatarURL = url
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}
