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

public struct HTTPEncoding {
    public let headers: [String:String]
    
    public init(headers: [String : String]) {
        self.headers = headers
    }
}

public enum ContentType: String {
    case json = "application/json"
    case form = "application/x-www-form-urlencoded"
}

public struct EndPoint {
	let method: HTTPMethod
	let path: String
	let	queryItems: Encodable
	let body: Encodable?
	let headers: [String:String]

    var isMultipartForm: Bool { headers["Content-Type"]?.contains("multipart/form-data") ?? false }
    
    private init(method: HTTPMethod, path: String, queryItems: Encodable, body: Encodable?, headers: [String:String]) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
    }
    
    public init(method: HTTPMethod, path: String, contentType: ContentType, queryItems: Encodable = [String:String](), body: Encodable? = nil, headers: [String:String] = [:]) {
        
        var endPointHeaders = headers
        endPointHeaders["Content-Type"] = contentType.rawValue
        
        self.init(method: method, path: path, queryItems: queryItems, body: body, headers: endPointHeaders)
	}
    
    public init(method: HTTPMethod, path: String, queryItems: Encodable = [String:String](), multipartForm: MultipartForm?, headers: [String:String] = [:]) {
        
        var endPointHeaders = headers
        endPointHeaders["Content-Type"] = multipartForm?.contentType
        
        self.init(method: method, path: path, queryItems: queryItems, body: multipartForm?.bodyData, headers: endPointHeaders)
    }
}
