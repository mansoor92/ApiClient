//
//  URLSessionClient.swift
//  Store
//
//  Created by Mansoor Ali on 29/10/2021.
//

import Foundation
import Combine

class ResponseParser {
    
    func parse<T: Decodable>(data: Data, response: URLResponse, decoder: JSONDecoder) throws -> Response<T> {
        let validatedData = try validate(data: data, response: response)
        let value = try decoder.decode(T.self, from: validatedData)
        return Response(value: value, response: response)
    }
    
    func wrap(data: Data, response: URLResponse) throws -> Response<Data> {
        let validatedData = try validate(data: data, response: response)
        return Response(value: validatedData, response: response)
    }
    
    private func validate(data: Data, response: URLResponse) throws -> Data {
        let httpResponse = response as! HTTPURLResponse
        
        switch httpResponse.statusCode {
        case 200..<300:
            return data
        default:
            throw(RequestError.badResponse(httpResponse.statusCode, data, httpResponse))
        }
    }
}

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
    
    func getRequest(from endpoint: EndPoint, requestEncoder: URLRequestEncoder) throws -> URLRequest {
        try requestEncoder.request(from: endpoint.baseURL ?? baseURL, endPoint: endpoint)
    }
}

// MARK: Callback
extension HTTPClient {
    
    ///execute a url request and return result on given queue using combine framework
    public func run<T: Decodable>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, decoder: JSONDecoder, completion: @escaping (Result<Response<T>, Error>) -> Void) {
        
        return runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, responseMap: { (data, response) in
            try ResponseParser().parse(data: data, response: response, decoder: decoder)
        }, completion: completion)
     }
    
    ///execute a url request and return raw data  on given queue using combine framework
    public func rawData(endpoint: EndPoint, requestEncoder: URLRequestEncoder, completion: @escaping (Result<Response<Data>, Error>) -> Void) {
        
        return runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, responseMap: { (data, response) in
            try ResponseParser().wrap(data: data, response: response)
        }, completion: completion)
     }
    
    private func runDataTask<T>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, responseMap: @escaping (Data,URLResponse) throws -> Response<T>, completion: @escaping (Result<Response<T>, Error>) -> Void) {
        
        do {
            let request = try getRequest(from: endpoint, requestEncoder: requestEncoder)
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

// MARK: Combine
extension HTTPClient {
    
    ///execute a url request and return result on given queue using combine framework
    public func run<T: Decodable>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, decoder: JSONDecoder, queue: DispatchQueue) ->
    AnyPublisher<Response<T>, Error> {
        
        return runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, responseMap: {
            try ResponseParser().parse(data: $0.data, response: $0.response, decoder: decoder)
        }, queue: queue)
     }
    
    ///execute a url request and return raw data  on given queue using combine framework
    public func rawData(endpoint: EndPoint, requestEncoder: URLRequestEncoder, queue: DispatchQueue) ->
    AnyPublisher<Response<Data>, Error> {
        
        return runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, responseMap: {
            try ResponseParser().wrap(data: $0.data, response: $0.response)
        }, queue: queue)
     }
    
    private func runDataTask<T>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, responseMap: @escaping (URLSession.DataTaskPublisher.Output) throws -> Response<T>, queue: DispatchQueue) ->
    AnyPublisher<Response<T>, Error> {
        do {
            let request = try getRequest(from: endpoint, requestEncoder: requestEncoder)
            return session
                .dataTaskPublisher(for: request)
                .tryMap { try responseMap($0) }
                .receive(on: queue)
                .eraseToAnyPublisher()
        } catch {
            return Fail<Response<T>, Error>(error: error).eraseToAnyPublisher()
        }
    }
}

// MARK: Ayscn await
extension HTTPClient {
    
    public func run<T>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, decoder: JSONDecoder) async throws -> Response<T> where T : Decodable {
        
        return try await runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, responseMap: { data, response in
            return try ResponseParser().parse(data: data, response: response, decoder: decoder)
        })
    }
    
    public func rawData(endpoint: EndPoint, requestEncoder: URLRequestEncoder, decoder: JSONDecoder) async throws -> Response<Data> {

        return try await runDataTask(endpoint: endpoint, requestEncoder: requestEncoder, responseMap: { data, response in
            return try ResponseParser().wrap(data: data, response: response)
        })
    }
    
    private func runDataTask<T>(endpoint: EndPoint, requestEncoder: URLRequestEncoder, responseMap: @escaping (Data, URLResponse) async throws -> Response<T>) async throws -> Response<T> {
        let request = try getRequest(from: endpoint, requestEncoder: requestEncoder)
        let (data, response) = try await session.data(for: request)
        return try await responseMap(data,response)
    }
}
