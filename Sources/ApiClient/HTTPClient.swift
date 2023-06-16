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
@available(macOS 12.0, *)
extension HTTPClient {
    
    ///execute a url request and return result on given queue using combine framework
    public func run<T: Decodable>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, decoder: JSONDecoder, overrideBaseURL: URL?) async throws -> Response<T> {
        
        return try await runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, overrideBaseURL: overrideBaseURL, responseMap: { (data, response) in
            try ResponseParser().parse(data: data, response: response, decoder: decoder)
        })
     }
    
    ///execute a url request and return raw data  on given queue using combine framework
    public func run(endpoint: EndPoint, requestEncoder: URLRequestEncoder, overrideBaseURL: URL?) async throws -> Response<Data> {
        return try await runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, overrideBaseURL: overrideBaseURL, responseMap: { (data, response) in
            try ResponseParser().parse(data: data, response: response)
        })
     }
    
    private func runDataTask<T>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, overrideBaseURL: URL?, responseMap: (Data,URLResponse) throws -> Response<T>) async throws -> Response<T> {
        
        let request = try getRequest(from: endpoint, requestEncoder: requestEncoder, overrideBaseURL: overrideBaseURL)
        let result: (data: Data, response: URLResponse) = try await session.data(for: request)
        return try responseMap(result.data, result.response)
    }
}
