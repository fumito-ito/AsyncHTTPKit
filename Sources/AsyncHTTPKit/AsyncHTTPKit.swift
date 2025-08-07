// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct AsyncHTTPKit {
    public typealias Response = AsyncHTTPResponse

    public let adapter: any SessionAdapter

    /// Initializes an AsyncHTTPKit instance with a custom session adapter.
    /// - Parameter adapter: The session adapter to use for network requests
    public init(adapter: any SessionAdapter) {
        self.adapter = adapter
    }

    /// Downloads the contents of a URL based on the specified URL request and delivers the data asynchronously.
    /// - Parameter request: A URL request object that provides request-specific information
    ///                      such as the URL and body data.
    /// - Returns: An asynchronously-delivered tuple that contains the URL contents as a `Data` instance,
    ///            and a `AsyncHTTPResponse`.
    public func data(for request: AsyncHTTPRequest) async throws -> (Data, Response) {
        try await adapter.data(for: request)
    }

    /// Retrieves the contents of a URL based on the specified request and delivers an asynchronous sequence of bytes.
    /// - Parameter request: A URL request object that provides request-specific information
    ///                      such as the URL and body data.
    /// - Returns: An asynchronously-delivered tuple that contains a `AsyncSequence<UInt8, Error>` sequence to iterate
    ///            over, and a `AsyncHTTPResponse`.
    public func bytes(
        for request: AsyncHTTPRequest
    ) async throws -> (any AsyncByteSequence, AsyncHTTPResponse) {
        try await adapter.stream(for: request)
    }
}
