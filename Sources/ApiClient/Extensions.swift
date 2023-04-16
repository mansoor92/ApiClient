//
//  Extensions.swift
//  
//
//  Created by Mansoor Ali on 16/04/2023.
//

import Foundation

public extension Encodable {

    func getData(encoder: JSONEncoder) throws -> Data {
        return try encoder.encode(self)
    }
}

extension URL {
    func appendingQueryItems(_ items: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            throw RequestError.invalideQueryParam("Can't create `URLComponents` from the url: \(self).")
        }
        guard !items.isEmpty else {
            return self
        }
        
        let existingQueryItems = components.queryItems ?? []
        components.queryItems = existingQueryItems + items

        // Manually replace all occurrences of "+" in the query because it can be understood as a placeholder
        // value for a space. We want to keep it as "+" so we have to manually percent-encode it.
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")

        guard let newURL = components.url else {
            throw RequestError.invalideQueryParam("Can't create a new `URL` after appending query items: \(items).")
        }
        return newURL
    }
}
