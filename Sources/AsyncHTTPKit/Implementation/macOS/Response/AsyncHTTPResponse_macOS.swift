//
//  AsyncHTTPResponse_macOS.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/29.
//
import Foundation

public extension AsyncHTTPResponse {
    static func build(from response: URLResponse) -> AsyncHTTPResponse {
        guard let response = response as? HTTPURLResponse else {
            fatalError()
        }

        return .init(
            statusCode: response.statusCode,
            url: response.url,
            allHeaderFields: response.allHeaderFields
        )
    }
}
