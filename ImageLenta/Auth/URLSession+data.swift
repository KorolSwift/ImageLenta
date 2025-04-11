//
//  URLSession+data.swift
//  ImageLenta
//
//  Created by Ди Di on 21/03/25.
//

import Foundation


private enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask
}

struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case codeError
    }
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        _ = data(for: request, completion: handler)
    }
    
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                print("Ошибка HTTP кода: \(response.statusCode)")
                completion(.failure(NetworkError.codeError))
                return
            }
            guard let data = data else { return }
            print("Ошибка: нет данных")
            completion(.success(data))
        }
        task.resume()
        return task
    }
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        return data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let model = try decoder.decode(T.self, from: data)
                    completion(.success(model))
                } catch {
                    print("[objectTask]: Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "недоступны")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[objectTask]: Ошибка сети: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

