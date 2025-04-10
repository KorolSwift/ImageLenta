//
//  SplashViewController.swift
//  ImageLenta
//
//  Created by Ди Di on 22/03/25.
//

import UIKit


final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchScreen")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 78)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false {
            OAuth2TokenStorage().clearToken()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            switchToAuthScreen()
        }
    }
    
    private func switchToAuthScreen() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "authViewController") as? AuthViewController
        else {
            print("Не удалось загрузить AuthViewController по Storyboard ID")
            return
        }
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImage(for: profile.username, token: token) { _ in
                    DispatchQueue.main.async {
                        self.switchToTabBarController()
                    }}
            case .failure(let error):
                print("Failed to fetch profile:", error)
                break
            }
        }
    }
}
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) {
            
            guard let token = self.storage.token else { return }
            self.fetchProfile(token: token)
        }
    }
}
