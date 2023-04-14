//
//  RequestEncoder.swift
//  Store
//
//  Created by Mansoor Ali on 21/10/2021.
//

import Foundation

public protocol HTTPEncoder {
    var jsonEncoder: JSONEncoder { get }
	func request(from baseURL: URL, endPoint: EndPoint) throws -> URLRequest
}
