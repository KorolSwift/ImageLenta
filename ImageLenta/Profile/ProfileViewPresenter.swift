//
//  ProfilePresenter.swift
//  ImageLenta
//
//  Created by Ди Di on 06/05/25.
//

import UIKit


public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var view: (any ProfileViewControllerProtocol)?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    init(profileService: ProfileServiceProtocol = ProfileService.shared,
         profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        if let profile = profileService.profile{
            view?.setProfileInfo(
                name: profile.name,
                username: profile.loginName,
                description: profile.bio ?? ""
            )
        }
        
        NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let urlString = profileImageService.avatarURL,
            let url = URL(string: urlString)
        else { return }
        view?.setAvatar(url: url)
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
}
