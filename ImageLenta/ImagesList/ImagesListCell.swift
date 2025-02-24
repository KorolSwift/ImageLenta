//
//  ImagesListCell.swift
//  ImageLenta
//
//  Created by Ди Di on 22/02/25.
//

import UIKit


class ImagesListCell: UITableViewCell {
    
    struct Model {
        let image: UIImage?
        let date: String
        let isLiked: Bool
    }
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBAction func tapButton(_ sender: Any) {}
    
    func configure(with model: Model) {
        cellImage.image = model.image
        date.text = model.date
        likeButton.isSelected = model.isLiked
    }
}
