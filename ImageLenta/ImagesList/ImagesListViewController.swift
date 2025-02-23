//
//  ViewController.swift
//  ImageLenta
//
//  Created by Ди Di on 20/02/25.
//

import UIKit


class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return }
        
        cell.cellImage.image = image
        cell.date.text = dateFormatter.string(from: Date())
        
        let heartImage = indexPath.row % 2 == 0 ? UIImage(named: "unliked") : UIImage(named: "liked")
        
        cell.likeButton.setImage(heartImage, for: .normal)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return 0 }
        
        let imageBorders = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let imageViewWidth = tableView.bounds.width - imageBorders.left - imageBorders.right
        let imageWidth = image.size.width
        let imageDifference = imageViewWidth / imageWidth
        let imageViewHeight = image.size.height * imageDifference
        let imageHeight = imageViewHeight + imageBorders.bottom + imageBorders.top
        
        return imageHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath
        )
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

