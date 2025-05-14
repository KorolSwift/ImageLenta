//
//  WebViewViewControllerDelegate.swift
//  ImageLenta
//
//  Created by Ди Di on 17/03/25.
//

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
