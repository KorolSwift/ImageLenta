//
//  ImagesListViewControllerProtocol.swift
//  ImageLenta
//
//  Created by Ди Di on 12/05/25.
//

import UIKit


protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(previousCount: Int)//newCount
    func showErrorAlert(message: String)
    func reloadRow(at indexPath: IndexPath)
}
