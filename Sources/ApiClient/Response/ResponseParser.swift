//
//  File.swift
//  
//
//  Created by Mansoor Ali on 16/04/2023.
//

import Foundation

class ResponseParser {
    
    func parse<T: Decodable>(data: Data, response: URLResponse, decoder: JSONDecoder) throws -> Response<T> {
        let validatedData = try validate(data: data, response: response)
        let value: T
        if let decodedValue = (validatedData as? T) {
            value = decodedValue
        } else {
            value = try decoder.decode(T.self, from: validatedData)
        }
        return Response(value: value, response: response)
    }
    
    func parse(data: Data, response: URLResponse) throws -> Response<Data> {
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
