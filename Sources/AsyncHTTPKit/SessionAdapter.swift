//
//  SessionAdapter.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/06/03.
//

import Foundation

/// A protocol that defines the interface for networking adapters in AsyncHTTPKit.
/// This allows for flexible implementation of different networking backends and easy mocking for testing.
public protocol SessionAdapter: Sendable {
    associatedtype ByteSequence: AsyncSequence<UInt8, Error>
    
    /// Downloads the contents of a URL based on the specified URL request and delivers the data asynchronously.
    /// - Parameter request: A URL request object that provides request-specific information such as the URL and body data.
    /// - Returns: An asynchronously-delivered tuple that contains the URL contents as a `Data` instance, and a `AsyncHTTPResponse`.
    func data(for request: AsyncHTTPRequest) async throws -> (Data, AsyncHTTPResponse)
    
    /// Retrieves the contents of a URL based on the specified URL request and delivers an asynchronous sequence of bytes.
    /// - Parameter request: A URL request object that provides request-specific information such as the URL and body data.
    /// - Returns: An asynchronously-delivered tuple that contains a `AsyncSequence<UInt8, Error>` sequence to iterate over, and a `AsyncHTTPResponse`.
    func stream(for request: AsyncHTTPRequest) async throws -> (ByteSequence, AsyncHTTPResponse)
}