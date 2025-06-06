//
//  HTTPClientAdapter.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/06/03.
//

import AsyncHTTPClient
import NIOCore
import Foundation

/// Session adapter that uses AsyncHTTPClient for Linux platform.
///
/// This adapter provides HTTP functionality on Linux by wrapping
/// the AsyncHTTPClient library, which is optimized for server-side
/// Swift applications.
public struct HTTPClientAdapter: SessionAdapter {
    public typealias ByteSequence = AsyncBytes
    
    private let client: HTTPClient
    
    /// Creates a new HTTPClientAdapter with the specified HTTPClient.
    ///
    /// - Parameter client: The AsyncHTTPClient HTTPClient instance to use
    ///   for making HTTP requests
    public init(client: HTTPClient) {
        self.client = client
    }
    
    /// Executes an HTTP request and returns the complete response data.
    ///
    /// This method performs the HTTP request using AsyncHTTPClient and
    /// collects all response data into memory.
    ///
    /// - Parameter request: The HTTP request to execute
    /// - Returns: A tuple containing the response data and response metadata
    /// - Throws: AsyncHTTPKitError or underlying AsyncHTTPClient errors
    public func data(for request: AsyncHTTPRequest) async throws -> (Data, AsyncHTTPResponse) {
        let httpClientResponse = try await client.execute(request.toHTTPClientRequest, timeout: .seconds(10))
        let (data, response) = try await AsyncHTTPResponse.build(from: httpClientResponse)
        return try request.intercept(object: httpClientResponse, data: data, response: response)
    }
    
    /// Executes an HTTP request and returns a streaming response.
    ///
    /// This method performs the HTTP request using AsyncHTTPClient and
    /// returns the response body as a stream of bytes, which is memory-efficient
    /// for large responses.
    ///
    /// - Parameter request: The HTTP request to execute
    /// - Returns: A tuple containing the byte stream and response metadata
    /// - Throws: AsyncHTTPKitError or underlying AsyncHTTPClient errors
    public func stream(for request: AsyncHTTPRequest) async throws -> (AsyncBytes, AsyncHTTPResponse) {
        var task: Task<Void, Never>?

        let responseStream = AsyncThrowingStream<(ByteBuffer, HTTPClientResponse), Error> { continuation in
            defer {
                continuation.finish()
                let _ = client.shutdown()
                task?.cancel()
            }

            task = Task {
                do {
                    let httpClientRequest = try request.toHTTPClientRequest
                    guard let response = try? await client.execute(httpClientRequest, timeout: .seconds(10)) else {
                        throw AsyncHTTPKitError.networkRequestFailed(request: request)
                    }

                    for try await buffer in response.body {
                        continuation.yield((buffer, response))
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }

        let bufferStream = AsyncThrowingStream<ByteBuffer, Error> { continuation in
            Task {
                do {
                    for try await (buffer, _) in responseStream {
                        continuation.yield(buffer)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }

        guard let (_, reachedResponse) = try await responseStream.first(where: { _ in true }) else {
            throw AsyncHTTPKitError.responseStreamEmpty(request: request)
        }

        let (_, response) = try await AsyncHTTPResponse.build(from: reachedResponse)

        return try request.intercept(object: reachedResponse, stream: AsyncBytes(stream: bufferStream), response: response)
    }
}