//
//  WebViewViewControllerSpy.swift
//  ImageLenta
//
//  Created by Ди Di on 06/05/25.
//

import ImageLenta
import Foundation


class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageLenta.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    
    func setProgressHidden(_ isHidden: Bool) {}
}
