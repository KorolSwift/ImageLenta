//
//  OAuth2Service.swift
//  ImageLenta
//
//  Created by Ди Di on 20/03/25.
//

import Foundation


enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    weak var delegate: AuthViewControllerDelegate?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private func createUrlRequest(code: String) -> URLRequest {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            fatalError("Неверный URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let parameterArray = parameters.map { "\($0.key)=\($0.value)" }
        let parameterString = parameterArray.joined(separator: "&")
        request.httpBody = parameterString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        let request = createUrlRequest(code: code)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
                
                switch result {
                case .success(let response):
                    OAuth2TokenStorage().token = response.accessToken
                    completion(.success(response.accessToken))
                    
                case .failure(let error):
                    print("[OAuth2Service:fetchOAuthToken]: Ошибка - \(error.localizedDescription), code: \(code)")

                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }}
                           
