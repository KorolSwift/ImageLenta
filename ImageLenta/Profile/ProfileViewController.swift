//
//  ProfileViewController.swift
//  ImageLenta
//
//  Created by Ди Di on 27/02/25.
//

import UIKit
import Kingfisher

extension UIImage {
    static var noPhoto: UIImage {
        UIImage(named: "PhotoNoName") ?? UIImage()
    }
    static var launchScreenLogo: UIImage {
        UIImage(named: "LaunchScreen") ?? UIImage()
    }
}

final class ProfileViewController: UIViewController {
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = .noPhoto
        view.clipsToBounds = true
        view.layer.cornerRadius = 35
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel ()
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    private let nicKLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "Exit") ?? UIImage(),
            target: self,
            action: #selector(self.didTapLogout)
        )
        button.tintColor = .ypRed
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        [imageView,
         nameLabel,
         nicKLabel,
         descriptionLabel,
         exitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            nicKLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicKLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: nicKLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        if let profileService = ProfileService.shared.profile {
            nameLabel.text = profileService.name
            nicKLabel.text = profileService.loginName
            descriptionLabel.text = profileService.bio
        }
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
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
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            imageView.image = .noPhoto
            return }
        
        if url.absoluteString.contains("placeholder-avatars/") {
            imageView.image = .noPhoto
            return
        }
        imageView.kf.setImage(with: url, placeholder: UIImage.noPhoto, options: [.cacheOriginalImage])
    }
    
    private func updateProfileDetails(profile: ProfileService.Profile) {
        nameLabel.text = profile.name
        nicKLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    @objc
    private func didTapLogout() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .default
        ) { _ in
            ProfileLogoutService.shared.logout()
            guard let window = UIApplication.shared.windows.first else { return }
            let splash = SplashViewController()
            window.rootViewController = splash
            window.makeKeyAndVisible()
        })
        
        alert.addAction(UIAlertAction(
            title: "Нет",
            style: .default,
            handler: nil
        ))
        self.present(alert, animated: true, completion: nil)
    }
}
