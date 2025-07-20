//
//  AsyncHTTPRequest_linux.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//
import AsyncHTTPClient
import NIOCore

public extension AsyncHTTPRequest {
    func intercept(httpClientRequest request: HTTPClientRequest) throws -> HTTPClientRequest {
        request
    }

    func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
        request
    }

    var toHTTPClientRequest: HTTPClientRequest {
        get throws {
            var request = HTTPClientRequest(url: url.absoluteString)
            request.method = .init(rawValue: method.rawValue)
            if let body {
                request.body = .bytes(body)
            }
            headers.forEach { request.headers.add(name: $0.key, value: $0.value) }
            request.headers.add(name: "Content-Type", value: contentType)

            return try intercept(object: self, request: request)
        }
    }
}
