//
//  AsyncHTTPResponse_linux.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/29.
//
import AsyncHTTPClient
import Foundation

public extension AsyncHTTPResponse {
    static func build(from response: HTTPClientResponse) throws -> (Data, AsyncHTTPResponse) {
        response.status.code
        response.headers
        response.url
        response.body
        return (Data(), AsyncHTTPResponse(statusCode: 0, url: URL(string: "")!, allHeaderFields: [:]))
    }
}
