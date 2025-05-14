//
//  ImagesListServiceProtocol.swift
//  ImageLenta
//
//  Created by Ди Di on 12/05/25.
//

import Foundation


public protocol ImagesListServiceProtocol: AnyObject {
    var photos: [ImagesListService.Photo] { get }
    func fetchPhotosNextPage(for username: String, token: String, completion: @escaping (Result<[ImagesListService.Photo], Error>) -> Void)
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func cleanPhotos()
}
