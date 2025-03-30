//
//  OAuth2Service.swift
//  ImageLenta
//
//  Created by Ди Di on 20/03/25.
//

import Foundation


final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    weak var delegate: AuthViewControllerDelegate?
    
    func createUrlRequest(code: String) -> URLRequest {
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
        print("fetchOAuthToken called with code: \(code)")
        let request = createUrlRequest(code: code)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.zeroByteResource)))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                OAuth2TokenStorage().token = response.accessToken
                DispatchQueue.main.async {
                    completion(.success(response.accessToken))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        } .resume()
    }
}
