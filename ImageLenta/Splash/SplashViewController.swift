//
//  SplashViewController.swift
//  ImageLenta
//
//  Created by Ди Di on 22/03/25.
//

import UIKit


final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let showRegistrationIdentifier = "showRegistration"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SplashViewController: token =", storage.token as Any)
        
        if let token = storage.token {
            switchToTabBarController()
            
        } else {
            performSegue(withIdentifier: showRegistrationIdentifier, sender: nil)
        }
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
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showRegistrationIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for showRegistration")
                return
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
        
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        switchToTabBarController()
    }
}
