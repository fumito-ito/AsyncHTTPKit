//
//  AsyncHTTPRequest_macOS.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//
import Foundation

public extension AsyncHTTPRequest {
    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        urlRequest
    }

    var toURLRequest: URLRequest {
        get throws {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.httpBody = body
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")

            return try intercept(object: self, request: request)
        }
    }
}
