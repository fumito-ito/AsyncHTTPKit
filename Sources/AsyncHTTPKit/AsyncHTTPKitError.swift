//
//  AsyncHTTPKitError.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/06/03.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

/// Errors that can occur when using AsyncHTTPKit.
///
/// All errors include the original request that caused the failure,
/// accessible via the `failedRequest` property.
public enum AsyncHTTPKitError: Error, LocalizedError {
    /// Network request failed to execute.
    ///
    /// This error is thrown when the underlying network operation fails,
    /// such as connection timeouts, DNS resolution failures, or other network-level issues.
    case networkRequestFailed(request: AsyncHTTPRequest)

    /// Response stream contains no data.
    ///
    /// This error is thrown when a streaming response is expected to contain data
    /// but the stream is empty or cannot be created.
    case responseStreamEmpty(request: AsyncHTTPRequest)

    /// Invalid response type received.
    ///
    /// This error is thrown when the response type is not what was expected,
    /// typically when expecting an HTTPURLResponse but receiving a different type.
    case invalidResponse(URLResponse, request: AsyncHTTPRequest)

    public var errorDescription: String? {
        switch self {
        case .networkRequestFailed(let request):
            return "Network request failed to execute: \(request.method.rawValue) \(request.url)"
        case .responseStreamEmpty(let request):
            return "Response stream contains no data for request: \(request.method.rawValue) \(request.url)"
        case .invalidResponse(let response, let request):
            return """
            Invalid response type for request \(request.method.rawValue) \(request.url): expected HTTPURLResponse,
            got \(type(of: response))
            """
        }
    }

    /// The request that caused this error.
    ///
    /// This property provides access to the original request that led to the error,
    /// allowing for detailed error handling and debugging.
    public var failedRequest: AsyncHTTPRequest {
        switch self {
        case .networkRequestFailed(let request),
             .responseStreamEmpty(let request),
             .invalidResponse(_, let request):
            return request
        }
    }
}
