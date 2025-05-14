//
//  ImagesListViewSpy.swift
//  ImageLenta
//
//  Created by Ди Di on 12/05/25.
//

import Foundation
@testable import ImageLenta


final class ImagesListViewSpy: ImagesListViewControllerProtocol {
    var updateCalled = false
    var reloadCalled = false
    var alertMessage: String?
    
    func updateTableViewAnimated(previousCount: Int) {
        updateCalled = true
    }
    
    func reloadRow(at indexPath: IndexPath) {
        reloadCalled = true
    }
    
    func showErrorAlert(message: String) {
        alertMessage = message
    }
}
