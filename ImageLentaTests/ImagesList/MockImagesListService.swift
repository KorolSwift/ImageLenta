//
//  MockImagesListService.swift
//  ImageLenta
//
//  Created by Ди Di on 12/05/25.
//

import Foundation
import ImageLenta


final class MockImagesListService: ImagesListServiceProtocol {
    var fetchCalled = false
    var likeCalled = false
    var shouldFailLike = false
    var photos: [ImagesListService.Photo] = []
    
    var samplePhoto: ImagesListService.Photo {
        ImagesListService.Photo(
            id: "1",
            size: .init(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false
        )
    }
    
    func fetchPhotosNextPage(for username: String, token: String, completion: @escaping (Result<[ImagesListService.Photo], Error>) -> Void) {
        fetchCalled = true
        photos.append(samplePhoto)
        completion(.success(photos))
    }
    
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        likeCalled = true
        if shouldFailLike {
            completion(.failure(NSError(domain: "LikeTest", code: 1)))
        } else {
            if let index = photos.firstIndex(where: { $0.id == photoId }) {
                photos[index].isLiked.toggle()
            }
            completion(.success(()))
        }
    }
    
    func cleanPhotos() {
        photos.removeAll()
    }
}
