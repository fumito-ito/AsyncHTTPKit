//
//  URLSessionAdapter.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/06/03.
//

import Foundation

/// Session adapter that uses URLSession for Apple platforms.
///
/// This adapter provides HTTP functionality on macOS and iOS by wrapping
/// Foundation's URLSession, which is optimized for Apple platforms.
public struct URLSessionAdapter: SessionAdapter {
    public typealias ByteSequence = URLSession.AsyncBytes

    private let urlSession: URLSession

    /// Creates a new URLSessionAdapter with the specified URLSession.
    ///
    /// - Parameter urlSession: The Foundation URLSession instance to use
    ///   for making HTTP requests
    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    /// Executes an HTTP request and returns the complete response data.
    ///
    /// This method performs the HTTP request using URLSession and
    /// collects all response data into memory.
    ///
    /// - Parameter request: The HTTP request to execute
    /// - Returns: A tuple containing the response data and response metadata
    /// - Throws: AsyncHTTPKitError or underlying URLSession errors
    public func data(for request: AsyncHTTPRequest) async throws -> (Data, AsyncHTTPResponse) {
        let (data, response) = try await urlSession.data(for: try request.toURLRequest)
        return try request
            .intercept(
                object: response,
                data: data,
                response: try AsyncHTTPResponse.build(from: response, for: request)
            )
    }

    /// Executes an HTTP request and returns a streaming response.
    ///
    /// This method performs the HTTP request using URLSession and
    /// returns the response body as a stream of bytes, which is memory-efficient
    /// for large responses.
    ///
    /// - Parameter request: The HTTP request to execute
    /// - Returns: A tuple containing the byte stream and response metadata
    /// - Throws: AsyncHTTPKitError or underlying URLSession errors
    public func stream(for request: AsyncHTTPRequest) async throws -> (URLSession.AsyncBytes, AsyncHTTPResponse) {
        let (stream, response) = try await urlSession.bytes(for: try request.toURLRequest)
        return try request
            .intercept(
                object: response,
                stream: stream,
                response: try AsyncHTTPResponse.build(from: response, for: request)
            )
    }
}
