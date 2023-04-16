//
//  DefaultEncoder.swift
//  Store
//
//  Created by Mansoor Ali on 30/10/2021.
//

import Foundation

public protocol URLRequestEncoder {
    var jsonEncoder: JSONEncoder { get }
    func request(from baseURL: URL, endPoint: EndPoint) throws -> URLRequest
}


public class DefaultURLRequestEncoder: URLRequestEncoder {

    public let jsonEncoder: JSONEncoder
    
	public init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }

	///if  endPoint contains basePath it overrides encoder basePath
	public func request(from baseURL: URL, endPoint: EndPoint) throws -> URLRequest {

		var request = URLRequest(url: baseURL.appendingPathComponent(endPoint.path))
		request.httpMethod = endPoint.method.rawValue
		request.allHTTPHeaderFields = endPoint.headers

		let queryItems = try encode(queryItems: endPoint.queryItems, encoder: jsonEncoder)
		request.url = try request.url?.appendingQueryItems(queryItems)

		if let body = endPoint.body {
			request.httpBody = try encode(body: body, encoder: jsonEncoder)
		}

		return request
	}

	private func encode(body: Encodable, encoder: JSONEncoder) throws -> Data {
		return try body.getData(encoder: encoder)
	}

	private func encode(queryItems: Encodable, encoder: JSONEncoder) throws -> [URLQueryItem] {

		
		//JSONEncoder only encodes to concrete type therefore we can't directly encode query items without AnyEncodable wrapper
		let data = try queryItems.getData(encoder: encoder)
		guard let json = try JSONSerialization.jsonObject(with: data) as? [String:Any] else {
            let error = "Data is not a valid JSON: \(String(data: data, encoding: .utf8) ?? "nil")"
            throw RequestError.invalidBody(error)
		}

		return try json.compactMap { (key,value) -> URLQueryItem? in
			guard let queryItemJSON = value as? [String:Any] else {
				return URLQueryItem(name: key, value: String(describing: value))
			}

			//if query item value is a json
			do {
				let jsonStringValue = try JSONSerialization.data(withJSONObject: queryItemJSON)
				return URLQueryItem(name: key, value: String(data: jsonStringValue, encoding: .utf8))
			}catch {
                let error = "Skipping encoding data for key:`\(key)` because it's not a valid JSON: " + "\(String(data: data, encoding: .utf8) ?? "nil")"
                throw RequestError.invalideQueryParam(error)
			}
		}
	}
}


