//
//  AsyncHTTPResponse_macOS.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/29.
//
import Foundation

public extension AsyncHTTPResponse {
    static func build(from response: URLResponse, for request: AsyncHTTPRequest) throws -> AsyncHTTPResponse {
        guard let response = response as? HTTPURLResponse else {
            throw AsyncHTTPKitError.invalidResponse(response, request: request)
        }

        let allHeaderFields = response.allHeaderFields
            .compactMapValues { $0 as? String }
            .reduce(into: [String: String]()) { dict, pair in dict[pair.key as? String ?? ""] = pair.value }

        return .init(
            statusCode: response.statusCode,
            url: response.url,
            allHeaderFields: allHeaderFields
        )
    }
}
