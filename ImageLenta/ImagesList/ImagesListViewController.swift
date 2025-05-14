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
    var presenter: ImagesListPresenterProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let presenter = ImagesListViewPresenter()
        self.presenter = presenter
        presenter.view = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        
        presenter.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photo = presenter?.photo(at: indexPath),
                let url = URL(string: photo.largeImageURL)
            else {
                print("Invalid segue destination")
                return
            }
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath) else { return 0 }
        let imageViewWidth = tableView.bounds.width - 16 * 2
        let imageRatio = CGFloat(photo.size.height) / CGFloat(photo.size.width)
        let imageHeight = imageViewWidth * imageRatio
        return imageHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        tableView.accessibilityIdentifier = "ImagesListTable"
        
        if let photo = presenter?.photo(at: indexPath) {
            let model = ListCellModel(
                imageURL: photo.thumbImageURL,
                date: photo.createdAt,
                isLiked: photo.isLiked
            )
            cell.configure(with: model)
        }
        
        cell.onImageLoaded = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        return cell
    }
}

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func updateTableViewAnimated(previousCount: Int) {
        tableView.performBatchUpdates {
            let currentCount = tableView.numberOfRows(inSection: 0)
            let newCount = presenter?.photosCount ?? 0
            guard newCount > currentCount else { return }
            
            let indexPaths = (currentCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}
