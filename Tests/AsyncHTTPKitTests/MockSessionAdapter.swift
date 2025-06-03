//
//  MockSessionAdapter.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/06/03.
//

import Foundation
import AsyncHTTPKit

/// A mock implementation of SessionAdapter for testing purposes
public struct MockSessionAdapter: SessionAdapter {
    public typealias ByteSequence = AsyncThrowingStream<UInt8, Error>
    
    public let mockData: Data
    public let mockResponse: AsyncHTTPResponse
    public let mockError: Error?
    
    public init(mockData: Data = Data(), mockResponse: AsyncHTTPResponse? = nil, mockError: Error? = nil) {
        self.mockData = mockData
        self.mockResponse = mockResponse ?? AsyncHTTPResponse(
            statusCode: 200,
            url: URL(string: "https://example.com"),
            allHeaderFields: [:]
        )
        self.mockError = mockError
    }
    
    public func data(for request: AsyncHTTPRequest) async throws -> (Data, AsyncHTTPResponse) {
        if let error = mockError {
            throw error
        }
        return (mockData, mockResponse)
    }
    
    public func stream(for request: AsyncHTTPRequest) async throws -> (AsyncThrowingStream<UInt8, Error>, AsyncHTTPResponse) {
        if let error = mockError {
            throw error
        }
        
        let stream = AsyncThrowingStream<UInt8, Error> { continuation in
            Task {
                for byte in mockData {
                    continuation.yield(byte)
                }
                continuation.finish()
            }
        }
        
        return (stream, mockResponse)
    }
}