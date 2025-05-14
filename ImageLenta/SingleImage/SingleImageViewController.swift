//
//  SingleImageViewController.swift
//  ImageLenta
//
//  Created by Ди Di on 28/02/25.
//

import UIKit


final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        loadFullImage()
    }
    
    @IBAction private func tapWhiteBackWard() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func tapSharingButton() {
        guard let image = imageView.image else { return }
        let sharing = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(sharing, animated: true, completion: nil)
    }
    
    private func loadFullImage() {
        guard let fullImageUrl = imageURL else { return }
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: fullImageUrl) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.imageView.frame.size = value.image.size
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }

    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            self.loadFullImage()
        })
        present(alert, animated: true)
        
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
