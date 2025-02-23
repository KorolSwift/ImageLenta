//
//  ImagesListCell.swift
//  ImageLenta
//
//  Created by Ди Di on 22/02/25.
//

import UIKit


class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBAction func tapButton(_ sender: Any) {}
}
