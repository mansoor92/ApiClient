//
//  File.swift
//  
//
//  Created by Mansoor Ali on 11/03/2023.
//

import Foundation

public enum RequestError: Error {
    case unknown
    case badResponse(Int, Data, HTTPURLResponse)
    case invalidBody(String)
    case invalideQueryParam(String)
}
