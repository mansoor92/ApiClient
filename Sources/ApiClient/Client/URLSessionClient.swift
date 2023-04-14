//
//  URLSessionClient.swift
//  Store
//
//  Created by Mansoor Ali on 29/10/2021.
//

import Foundation
import Combine

public class URLSessionClient {

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
    
    private func getRequest(from endpoint: EndPoint, requestEncoder: HTTPEncoder) throws -> URLRequest {
        try requestEncoder.request(from: endpoint.baseURL ?? baseURL, endPoint: endpoint)
    }
}

// MARK: Combine
extension URLSessionClient {
    
    ///execute a url request and return result on given queue using combine framework
    public func run<T: Decodable>(endpoint: EndPoint, requestEncoder: HTTPEncoder, decoder: JSONDecoder, queue: DispatchQueue) ->
    AnyPublisher<Response<T>, Error> {
        do {
            let request = try getRequest(from: endpoint, requestEncoder: requestEncoder)
            return session
                .dataTaskPublisher(for: request)
                .tryMap { [unowned self] result -> Response<T> in
                    return try parse(data: result.data, response: result.response, decoder: decoder)
                }
                .receive(on: queue)
                .eraseToAnyPublisher()
        }catch {
            return Fail<Response<T>, Error>(error: error).eraseToAnyPublisher()
        }
     }
    
    ///execute a url request and return raw data  on given queue using combine framework
    public func rawData(endpoint: EndPoint, requestEncoder: HTTPEncoder, decoder: JSONDecoder, queue: DispatchQueue) ->
    AnyPublisher<Response<Data>, Error> {
        do {
            let request = try getRequest(from: endpoint, requestEncoder: requestEncoder)
            return session
                .dataTaskPublisher(for: request)
                .tryMap { [unowned self] result -> Response<Data> in
                    return try self.wrap(data: result.data, response: result.response)
                }
                .receive(on: queue)
                .eraseToAnyPublisher()
        }catch {
            return Fail<Response<Data>, Error>(error: error).eraseToAnyPublisher()
        }
     }
    
    
    private func parse<T: Decodable>(data: Data, response: URLResponse, decoder: JSONDecoder) throws -> Response<T> {
        let validatedData = try validate(data: data, response: response)
        let value = try decoder.decode(T.self, from: validatedData)
        return Response(value: value, response: response)
    }
    
    private func wrap(data: Data, response: URLResponse) throws -> Response<Data> {
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

// MARK: Ayscn await
extension URLSessionClient {
    
    public func run<T>(endpoint: EndPoint, requestEncoder: HTTPEncoder, decoder: JSONDecoder) async throws -> Response<T> where T : Decodable {
        let request = try getRequest(from: endpoint, requestEncoder: requestEncoder)
        let (data, response) = try await session.data(for: request)
        return try parse(data: data, response: response, decoder: decoder)
    }
    
    public func rawData(endpoint: EndPoint, requestEncoder: HTTPEncoder, decoder: JSONDecoder) async throws -> Response<Data> {
        let request = try getRequest(from: endpoint, requestEncoder: requestEncoder)
        let (data, response) = try await session.data(for: request)
        return try wrap(data: data, response: response)
    }
}
