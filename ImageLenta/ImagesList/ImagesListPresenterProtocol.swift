//
//  ImagesListPresenter.swift
//  ImageLenta
//
//  Created by Ди Di on 12/05/25.
//

import UIKit


protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at indexPath: IndexPath) -> ImagesListService.Photo
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}
