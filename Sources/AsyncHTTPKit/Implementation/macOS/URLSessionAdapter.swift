//
//  URLSessionAdapter.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/06/03.
//

import Foundation

public struct URLSessionAdapter: SessionAdapter {
    public typealias ByteSequence = URLSession.AsyncBytes
    
    private let urlSession: URLSession
    
    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    public func data(for request: AsyncHTTPRequest) async throws -> (Data, AsyncHTTPResponse) {
        let (data, response) = try await urlSession.data(for: try request.toURLRequest)
        return try request.intercept(object: response, data: data, response: try AsyncHTTPResponse.build(from: response, for: request))
    }
    
    public func stream(for request: AsyncHTTPRequest) async throws -> (URLSession.AsyncBytes, AsyncHTTPResponse) {
        let (stream, response) = try await urlSession.bytes(for: try request.toURLRequest)
        return try request.intercept(object: response, stream: stream, response: try AsyncHTTPResponse.build(from: response, for: request))
    }
}