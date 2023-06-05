//
//  URLSessionClient.swift
//  Store
//
//  Created by Mansoor Ali on 29/10/2021.
//

import Foundation

public class HTTPClient {
    
    private var sessionHeaders = [String:String]()
    private var session: URLSession
    public let baseURL: URL
    
    public init(config: URLSessionConfiguration, baseURL: URL) {
        session = URLSession(configuration: config)
        self.baseURL = baseURL
    }

    ///set sessionHeader which are
    public func set(sessionHeaders: [String:String]) {
        let configuration = session.configuration
        configuration.httpAdditionalHeaders = sessionHeaders
        session = URLSession(configuration: configuration)
    }
    
    func getRequest(from endpoint: EndPoint, requestEncoder: URLRequestEncoder, overrideBaseURL: URL?) throws -> URLRequest {
        try requestEncoder.request(from: overrideBaseURL ?? baseURL, endPoint: endpoint)
    }
}

// MARK: Callback
extension HTTPClient {
    
    ///execute a url request and return result on given queue using combine framework
    public func run<T: Decodable>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, decoder: JSONDecoder, overrideBaseURL: URL?, completion: @escaping (Result<Response<T>, Error>) -> Void) {
        
        return runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, overrideBaseURL: overrideBaseURL, responseMap: { (data, response) in
            try ResponseParser().parse(data: data, response: response, decoder: decoder)
        }, completion: completion)
     }
    
    ///execute a url request and return raw data  on given queue using combine framework
    public func run(endpoint: EndPoint, requestEncoder: URLRequestEncoder, overrideBaseURL: URL?, completion: @escaping (Result<Response<Data>, Error>) -> Void) {
        
        return runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, overrideBaseURL: overrideBaseURL, responseMap: { (data, response) in
            try ResponseParser().parse(data: data, response: response)
        }, completion: completion)
     }
    
    private func runDataTask<T>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, overrideBaseURL: URL?, responseMap: @escaping (Data,URLResponse) throws -> Response<T>, completion: @escaping (Result<Response<T>, Error>) -> Void) {
        
        do {
            let request = try getRequest(from: endpoint, requestEncoder: requestEncoder, overrideBaseURL: overrideBaseURL)
            session.dataTask(with: request) { data, response, error in
                
                guard let data = data, let response = response else {
                    completion(.failure(error ?? RequestError.unknown))
                    return
                }
                
                do {
                    let response = try responseMap(data, response)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
        } catch {
            return completion(.failure(error))
        }
    }
}
