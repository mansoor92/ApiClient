//
//  EndPoint.swift
//  Store
//
//  Created by Mansoor Ali on 21/10/2021.
//

import Foundation
public enum HTTPMethod : String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
}

public protocol HTTPEncoding {
	var headers: [String:String] {get}
}

public struct EncodingType: HTTPEncoding {
    
    public let headers: [String:String]
    
    public init(headers: [String:String]) {
        self.headers = headers
    }
    
    public static var json: HTTPEncoding { EncodingType(headers: ["Content-Type" : "application/json"]) }
    public static var multipart: HTTPEncoding { EncodingType(headers: ["Content-Type" : "multipart/form-data"]) }
    public static var form: HTTPEncoding { EncodingType(headers: ["Content-Type" : "application/x-www-form-urlencoded"]) }
}

public struct EndPoint {
	let method: HTTPMethod
	/// this baseURL overrides baseURL  of Client
	let baseURL: URL?
	let path: String
	let	queryItems: Encodable
	let body: Encodable?
	let headers: [String:String]
	let encoding: HTTPEncoding

	public init(method: HTTPMethod, baseURL: URL? = nil, path: String, encoding: HTTPEncoding, queryItems: Encodable = [String:String](), body: Encodable? = nil, headers: [String:String] = [:]) {
		self.method = method
		self.baseURL = baseURL
		self.path = path
		self.queryItems = queryItems
		self.body = body
		self.headers = headers
		self.encoding = encoding
	}
}
