//
//  ImagesListViewPresenter.swift
//  ImageLenta
//
//  Created by Ди Di on 12/05/25.
//

import Foundation
import UIKit


final class ImagesListViewPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var photos: [ImagesListService.Photo] = []
    private var isFetching = false
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }
    
    var photosCount: Int {
        return photos.count
    }
    
    func viewDidLoad() {
        guard let token    = OAuth2TokenStorage.shared.token,
              let username = ProfileService.shared.profile?.username
        else { return }
        
        imagesListService.fetchPhotosNextPage(for: username, token: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let newPhotos):
                let previousCount = self.photos.count
                self.photos.append(contentsOf: newPhotos)
                self.view?.updateTableViewAnimated(previousCount: previousCount)
            case .failure(let error):
                self.view?.showErrorAlert(message: "Не удалось загрузить фотографии.\n\(error.localizedDescription)")
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
            self.view?.updateTableViewAnimated(previousCount: previousCount)
        }
    }
    
    func photo(at indexPath: IndexPath) -> ImagesListService.Photo {
        return photos[indexPath.row]
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        guard indexPath.row + 1 == photos.count,
              !isFetching,
              let token = OAuth2TokenStorage.shared.token else {
            return
        }
        isFetching = true
        let previousCount = photos.count
        
        imagesListService.fetchPhotosNextPage(for: "", token: token) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let newPhotos):
                self.photos.append(contentsOf: newPhotos)
                let newCount = self.photos.count
                guard newCount > previousCount else { return }
                self.view?.updateTableViewAnimated(previousCount: previousCount)
            case .failure(let error):
                let message = "Не удалось загрузить фотографии.\n\(error.localizedDescription)"
                self.view?.showErrorAlert(message: message)
            }
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        imagesListService.changeLike(photoId: photo.id, isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                if let idx = self.photos.firstIndex(where: { $0.id == photo.id }) {
                    self.photos[idx].isLiked.toggle()
                    self.view?.reloadRow(at: indexPath)
                }
            case .failure(let error):
                self.view?.showErrorAlert(message: "Ошибка в установке/удалении лайка:\n\(error.localizedDescription)")
            }
        }
    }
}
