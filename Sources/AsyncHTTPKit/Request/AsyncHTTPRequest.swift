//
//  AsyncHTTPRequest.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//
import Foundation
#if os(Linux)
import AsyncHTTPClient
#endif

/// Protocol defining the requirements for HTTP requests in AsyncHTTPKit.
///
/// This protocol provides a unified interface for creating HTTP requests
/// that work seamlessly across different platforms (macOS, iOS, and Linux).
/// Conforming types define the essential components of an HTTP request
/// and can optionally implement interception methods for customizing
/// request and response behavior.
public protocol AsyncHTTPRequest: Sendable {
    /// The HTTP method to use for this request.
    ///
    /// Specifies the type of HTTP operation to perform (GET, POST, PUT, etc.).
    var method: AsyncHTTPMethod { get }
    
    /// HTTP headers to include with the request.
    ///
    /// A dictionary of header field names and values to be sent with the request.
    /// Common headers include "Authorization", "Content-Type", "User-Agent", etc.
    var headers: [String: String] { get }

    /// The request body data.
    ///
    /// Optional data to be sent as the request body. For methods like POST and PUT,
    /// this typically contains the payload (JSON, form data, etc.). For methods
    /// like GET and DELETE, this is usually nil.
    var body: Data? { get }
    
    /// The target URL for the request.
    ///
    /// The complete URL including scheme, host, path, and any query parameters.
    var url: URL { get }

    /// The MIME type of the request body.
    ///
    /// Specifies the media type of the request body content.
    /// Common values include "application/json", "application/x-www-form-urlencoded",
    /// "multipart/form-data", etc.
    var contentType: String { get }

#if os(macOS) || os(iOS)
    /// Intercepts and modifies the URLRequest before execution on Apple platforms.
    ///
    /// This method allows you to customize the URLRequest after it has been
    /// created from the AsyncHTTPRequest properties but before it's sent
    /// via URLSession.
    ///
    /// - Parameters:
    ///   - object: The original AsyncHTTPRequest object
    ///   - request: The URLRequest created from the AsyncHTTPRequest
    /// - Returns: The modified URLRequest to be executed
    /// - Throws: Any error that occurs during request modification
    func intercept(object: AsyncHTTPRequest, request: URLRequest) throws -> URLRequest
#elseif os(Linux)
    /// Intercepts and modifies the HTTPClientRequest before execution on Linux.
    ///
    /// This method allows you to customize the HTTPClientRequest after it has been
    /// created from the AsyncHTTPRequest properties but before it's sent
    /// via AsyncHTTPClient.
    ///
    /// - Parameters:
    ///   - object: The original AsyncHTTPRequest object
    ///   - request: The HTTPClientRequest created from the AsyncHTTPRequest
    /// - Returns: The modified HTTPClientRequest to be executed
    /// - Throws: Any error that occurs during request modification
    func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest
#endif
    
    /// Intercepts and modifies the response data and metadata.
    ///
    /// This method allows you to process the response data and headers
    /// after they have been received but before they are returned to the caller.
    /// Common use cases include decryption, decompression, or logging.
    ///
    /// - Parameters:
    ///   - object: The native response object (URLResponse on Apple platforms)
    ///   - data: The response body data
    ///   - response: The AsyncHTTPResponse created from the native response
    /// - Returns: A tuple containing the modified data and response
    /// - Throws: Any error that occurs during response processing
    func intercept(object: Any, data: Data, response: AsyncHTTPResponse) throws -> (Data, AsyncHTTPResponse)
    
    /// Intercepts and modifies the response stream and metadata.
    ///
    /// This method allows you to process the response stream and headers
    /// after they have been received but before they are returned to the caller.
    /// This is useful for streaming transformations like decryption or decompression.
    ///
    /// - Parameters:
    ///   - object: The native response object (URLResponse on Apple platforms)
    ///   - stream: The response body as an async sequence of bytes
    ///   - response: The AsyncHTTPResponse created from the native response
    /// - Returns: A tuple containing the modified stream and response
    /// - Throws: Any error that occurs during stream processing
    func intercept<S: AsyncSequence>(object: Any, stream: S, response: AsyncHTTPResponse) throws -> (S, AsyncHTTPResponse) where S.Element == UInt8, S.Failure == Error
}

public extension AsyncHTTPRequest {
    /// Note:
    /// `intercept(object:request:)` interfaces for request are implemented on each platform specified code.
    /// For more information, see Implementation/{macOS/linux}/Request/AsyncHTTPRequest_{macOS/linux}.swift

    func intercept(object: Any, data: Data, response: AsyncHTTPResponse) throws -> (Data, AsyncHTTPResponse) {
        return (data, response)
    }

    func intercept<S: AsyncSequence>(object: Any, stream: S, response: AsyncHTTPResponse) throws -> (S, AsyncHTTPResponse) where S.Element == UInt8, S.Failure == Error {
        return (stream, response)
    }
}

#if os(macOS) || os(iOS)
public extension AsyncHTTPRequest {
    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        urlRequest
    }
}
#elseif os(Linux)
public extension AsyncHTTPRequest {
    func intercept(httpClientRequest request: HTTPClientRequest) throws -> HTTPClientRequest {
        return request
    }
}
#endif
