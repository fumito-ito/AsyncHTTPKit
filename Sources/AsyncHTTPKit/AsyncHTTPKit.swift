// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct AsyncHTTPKit {
    public typealias Response = AsyncHTTPResponse

    public let session: Session
    
    /// Downloads the contents of a URL based on the specified URL request and delivers the data asynchronously.
    /// - Parameter request: A URL request object that provides request-specific information such as the URL and body data.
    /// - Returns: An asynchronously-delivered tuple that contains the URL contents as a `Data` instance, and a `AsyncHTTPResponse`.
    public func data(for request: AsyncHTTPRequest) async throws -> (Data, Response) {
        try await response(for: request)
    }
    
    /// Retrieves the contents of a URL based on the specified URL request and delivers an asynchronous sequence of bytes.
    /// - Parameter request: A URL request object that provides request-specific information such as the URL and body data.
    /// - Returns: An asynchronously-delivered tuple that contains a `AsyncSequence<UInt8, Error>` sequence to iterate over, and a `AsyncHTTPResponse`.
    public func bytes(for request: AsyncHTTPRequest) async throws -> (some AsyncSequence<UInt8, Error>, AsyncHTTPResponse) {
        try await stream(for: request)
    }
}
