//
//  Client.swift
//  AppFlavors-debug
//
//  Created by Mansoor Ali on 01/09/2021.
//  Copyright © 2021 Softhouse Nordic, AB. All rights reserved.
//

import Foundation
import PromiseKit

public class PromiseSessionClient {

    private var sessionHeaders = [String:String]()
    private let session: URLSession
    public let baseURL: URL
    
    public init(config: URLSessionConfiguration, baseURL: URL) {
        session = URLSession(configuration: config)
        self.baseURL = baseURL
    }

    ///set sessionHeader which are
    public func set(sessionHeaders: [String:String]) {
        for (key,value) in sessionHeaders {
            self.session.configuration.httpAdditionalHeaders?[key] = value
        }
    }
    
    func run<T:Decodable>(endpoinit: EndPoint, requestEncoder: HTTPEncoder, decoder: JSONDecoder) -> Promise<T> {
        
        return Promise() { [weak self] (seal: Resolver<T>) in
            
            guard let request = getRequest(from: endpoinit, requestEncoder: requestEncoder, resolver: seal) else { return }
            
            session.dataTask(with: request) { data, httpResponse, error in
                
                guard let response = httpResponse as? HTTPURLResponse else  {
                    seal.reject(error ?? RequestError.unknown)
                    return
                }
                
                self?.mapData(data: data, response: response, error: error, resolver: seal, decoder: decoder)
            }
        }
    }
    
    private func mapData<T: Decodable>(data: Data?, response: HTTPURLResponse, error: Error? , resolver: Resolver<T>, decoder: JSONDecoder) {
        
        switch response.statusCode {
        case 200..<300:
            do {
                guard let data = data else {
                    resolver.reject(error ?? RequestError.unknown)
                    return
                }
                let json = try decoder.decode(T.self, from: data)
                return resolver.fulfill(json)
            } catch {
                resolver.reject(error)
            }
        default:
            if let data = data {
                resolver.reject(RequestError.badResponse(response.statusCode, data, response))
            }else {
                resolver.reject(error ?? RequestError.unknown)
            }
        }
    }

    private func getRequest<T: Decodable>(from endpoint: EndPoint, requestEncoder: HTTPEncoder, resolver: Resolver<T>) -> URLRequest? {
        do {
            return try requestEncoder.request(from: endpoint.baseURL ?? baseURL, endPoint: endpoint)
        }catch {
            resolver.reject(error)
            return nil
        }
    }
}


