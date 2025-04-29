//
//  ViewController.swift
//  ImageLenta
//
//  Created by Ди Di on 20/02/25.
//

import UIKit


final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let imagesListService = ImagesListService()
    private var photos: [ImagesListService.Photo] = []
    weak var delegate: ImagesListCellDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataSource = self
        if let token = OAuth2TokenStorage.shared.token {
            let username = ProfileService.shared.profile?.username ?? ""
            imagesListService.fetchPhotosNextPage(for: username, token: token) { [weak self] result in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            
            let previousCount = self.photos.count
            self.photos = self.imagesListService.photos
            let newCount = self.photos.count
            
            guard newCount > previousCount else { return }
            
            let indexPaths = (previousCount..<newCount).map { IndexPath(row: $0, section: 0) }
            
            
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                print("Invalid segue destination")
                return
            }
            let photo = photos[indexPath.row]
            let url = URL(string: photo.largeImageURL)
            viewController.imageURL = url
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = imagesListService.photos[indexPath.row]
        
        let imageViewWidth = tableView.bounds.width - 16 * 2
        let imageRatio = CGFloat(photo.size.height) / CGFloat(photo.size.width)
        let imageHeight = imageViewWidth * imageRatio
        
        return imageHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard cell is ImagesListCell else { return }
        
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        let username = ProfileService.shared.profile?.username ?? ""
        
        if indexPath.row + 1 == imagesListService.photos.count {
            
            let previousCount = imagesListService.photos.count
            imagesListService.fetchPhotosNextPage(for: username, token: token) { result in
                switch result {
                    
                case .success:
                    DispatchQueue.main.async {
                        self.updateTableViewAnimated(previousCount: previousCount)
                    }
                case .failure(let error):
                    print("Ошибка загрузки фото: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "Ошибка",
                            message: "Не удалось загрузить фотографии.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Ок", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }}
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        let model = ListCellModel(
            imageURL: photo.thumbImageURL,
            date: photo.createdAt,
            isLiked: photo.isLiked
        )
        cell.configure(with: model)
        
        cell.likeButtonTapped = { [weak self] in
            guard self != nil else { return }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        configCell(for: cell, with: indexPath)
        
        cell.onImageLoaded = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        return cell
    }
    
    private func updateTableViewAnimated(previousCount: Int) {
        let previousCount = tableView.numberOfRows(inSection: 0)
        let newCount = imagesListService.photos.count
        
        let indexPaths = (previousCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(
            photoId: photo.id,
            isLiked: photo.isLiked) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        
                        if self.imagesListService.photos.firstIndex(where: { $0.id == photo.id }) != nil {
                            let newLiked = !photo.isLiked
                            self.photos[indexPath.row].isLiked = newLiked
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                        UIBlockingProgressHUD.dismiss()
                    case .failure(let error):
                        UIBlockingProgressHUD.dismiss()
                        
                        let alert = UIAlertController(
                            title: "Ошибка",
                            message: "в установке/удалении лайка: \n\(error.localizedDescription)",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Ок", style: .default))
                        self.present(alert, animated: true)
                    }
                }
                
            }
    }
}


