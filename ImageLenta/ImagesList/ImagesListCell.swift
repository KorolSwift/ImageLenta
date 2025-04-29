//
//  ImagesListCell.swift
//  ImageLenta
//
//  Created by Ди Di on 22/02/25.
//

import UIKit
import Kingfisher


protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    var onImageLoaded: (() -> Void)?
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    var likeButtonTapped: (() -> Void)?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBAction func tapButton(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func configure(with model: ListCellModel) {
        let stubImageView = UIImageView(image: UIImage(named: "Stub"))
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        stubImageView.contentMode = .scaleAspectFit
        cellImage.backgroundColor = UIColor(named: "YP Gray")
        cellImage.addSubview(stubImageView)
        
        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: cellImage.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: cellImage.centerYAnchor),
            stubImageView.widthAnchor.constraint(equalToConstant: 83),
            stubImageView.heightAnchor.constraint(equalToConstant: 74)
        ])
        
        cellImage.kf.indicatorType = .activity
        
        cellImage.kf.setImage(with: URL(string: model.imageURL)) { [weak self] result in
            switch result {
            case .success:
                stubImageView.removeFromSuperview()
                self?.onImageLoaded?()
            case .failure:
                break
            }
        }
        
        if let dateValue = model.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                date.text = dateFormatter.string(from: dateValue)
            } else {
                date.text = ""
            }
        
        setIsLiked(model.isLiked)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        for subview in cellImage.subviews where subview is UIImageView {
            if (subview as? UIImageView)?.image == UIImage(named: "Stub") {
                subview.removeFromSuperview()
            }
        }
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let heartImage = isLiked ? UIImage(named: "liked") : UIImage(named: "unliked")
        likeButton.setImage(heartImage, for: .normal)
        likeButton.setTitle("", for: .normal)
    }
}
