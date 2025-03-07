//
//  ProfileViewController.swift
//  ImageLenta
//
//  Created by Ди Di on 27/02/25.
//

import UIKit


final class ProfileViewController: UIViewController {
    private var labels: [UILabel] = []
    private let imageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "Photo")
        view.image = image
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.tintColor = .ypWhite
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        
        let nicKLabel = UILabel()
        nicKLabel.text = "@ekaterina_nov"
        nicKLabel.textColor = .ypGray
        nicKLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "Exit") ?? UIImage(),
            target: self,
            action: #selector(Self.didTapButton)
        )
        exitButton.tintColor = .ypRed
        
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
    }
    
    @objc
    private func didTapButton() {
        // TODO: Добавить обработчик нажатия кнопки логаута
    }
}
