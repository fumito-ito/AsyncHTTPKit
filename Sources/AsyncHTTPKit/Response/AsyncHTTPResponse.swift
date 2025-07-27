//
//  AsyncHTTPResponse.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//

import Foundation

/// Represents an HTTP response received from a server.
///
/// This structure encapsulates the essential components of an HTTP response
/// including the status code, URL, and headers. It provides a unified
/// representation that works across different platforms and HTTP implementations.
public struct AsyncHTTPResponse: Sendable {
    /// The HTTP status code of the response.
    ///
    /// Standard HTTP status codes such as 200 (OK), 404 (Not Found),
    /// 500 (Internal Server Error), etc.
    public let statusCode: Int

    /// The URL that was used to make the request.
    ///
    /// This may differ from the original request URL if redirects occurred.
    /// Can be nil in some edge cases or testing scenarios.
    public let url: URL?

    /// HTTP headers returned by the server.
    ///
    /// A dictionary containing all header fields from the response,
    /// such as "Content-Type", "Content-Length", "Cache-Control", etc.
    public let allHeaderFields: [String: String]

    /// Creates a new AsyncHTTPResponse.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code
    ///   - url: The request URL (optional)
    ///   - allHeaderFields: Response headers (defaults to empty dictionary)
    public init(
        statusCode: Int,
        url: URL? = nil,
        allHeaderFields: [String: String] = [:]
    ) {
        self.statusCode = statusCode
        self.url = url
        self.allHeaderFields = allHeaderFields
    }
}
