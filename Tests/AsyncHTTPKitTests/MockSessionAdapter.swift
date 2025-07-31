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
    
    public var byteLines: any AsyncByteLineSequence<MockByteSequence> {
        return MockLinesCollection(byteSequence: self)
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

/// A mock lines collection that conforms to AsyncByteLineSequence
public struct MockLinesCollection: AsyncByteLineSequence, AsyncSequence, Sendable {
    public typealias Element = String
    public typealias Base = MockByteSequence
    
    private let byteSequence: MockByteSequence
    
    init(byteSequence: MockByteSequence) {
        self.byteSequence = byteSequence
    }
    
    public func makeAsyncIterator() -> MockLinesIterator {
        return MockLinesIterator(bytesIterator: byteSequence.makeAsyncIterator())
    }
}

/// A mock lines iterator
public struct MockLinesIterator: AsyncIteratorProtocol {
    public typealias Element = String
    
    private var bytesIterator: MockAsyncIterator
    private var lineBuffer: [UInt8] = []
    
    init(bytesIterator: MockAsyncIterator) {
        self.bytesIterator = bytesIterator
    }
    
    public mutating func next() async throws -> String? {
        while let byte = try await bytesIterator.next() {
            // Check for line feed (LF)
            if byte == 10 { // LF (Line Feed)
                // Remove carriage return if present (CRLF support)
                let line: [UInt8]
                if lineBuffer.last == 13 { // CR (Carriage Return)
                    line = Array(lineBuffer.dropLast())
                } else {
                    line = lineBuffer
                }
                // Reset buffer and return string
                lineBuffer.removeAll()
                return String(bytes: line, encoding: .utf8) ?? ""
            } else {
                lineBuffer.append(byte)
            }
        }
        
        // Return remaining content if any
        if !lineBuffer.isEmpty {
            let line = lineBuffer
            lineBuffer.removeAll()
            return String(bytes: line, encoding: .utf8) ?? ""
        }
        
        return nil
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
