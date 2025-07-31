//
//  MockSessionAdapter.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/06/03.
//

import Foundation
import AsyncHTTPKit

/// A mock byte sequence that conforms to AsyncByteSequence
public struct MockByteSequence: AsyncByteSequence {
    public typealias Element = UInt8
    public typealias AsyncIterator = MockAsyncIterator
    
    private let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public func makeAsyncIterator() -> MockAsyncIterator {
        return MockAsyncIterator(data: data)
    }
}

/// A mock async iterator for byte sequence
public struct MockAsyncIterator: AsyncIteratorProtocol {
    public typealias Element = UInt8
    
    private let data: Data
    private var currentIndex: Data.Index
    
    public init(data: Data) {
        self.data = data
        self.currentIndex = data.startIndex
    }
    
    public mutating func next() async throws -> UInt8? {
        guard currentIndex < data.endIndex else {
            return nil
        }
        
        let byte = data[currentIndex]
        currentIndex = data.index(after: currentIndex)
        return byte
    }
}

/// A mock implementation of SessionAdapter for testing purposes
public struct MockSessionAdapter: SessionAdapter {
    public typealias ByteSequence = MockByteSequence

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

    public func stream(
        for request: AsyncHTTPRequest
    ) async throws -> (MockByteSequence, AsyncHTTPResponse) {
        if let error = mockError {
            throw error
        }

        let sequence = MockByteSequence(data: mockData)
        return (sequence, mockResponse)
    }
}
