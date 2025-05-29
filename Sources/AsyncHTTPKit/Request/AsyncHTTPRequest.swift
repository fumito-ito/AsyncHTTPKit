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

/// AsyncHTTPRequest
public protocol AsyncHTTPRequest: Sendable {
    /// HTTP method for request
    var method: AsyncHTTPMethod { get }
    
    /// request headers
    var headers: [String: String] { get }

    /// request body as data
    var body: Data? { get }
    
    /// URL to request
    var url: URL { get }

    /// Content-Type of request
    var contentType: String { get }

#if os(macOS)
    ///
    /// - Parameters:
    ///   - object: Base request object converted to `URLRequest`
    ///   - request: Converted request object used `URLSession.send`
    /// - Returns: Request object to pass `URLSession.send`
    func intercept(object: AsyncHTTPRequest, request: URLRequest) throws -> URLRequest
#elseif os(Linux)
    ///
    /// - Parameters:
    ///   - object: Base request object converted to `HTTPClientRequest`
    ///   - request: Converted request object for `HTTPClient.execute`
    /// - Returns: Request object to pass  `HTTPClient.execute`
    func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest
#endif
    
    ///
    /// - Parameters:
    ///   - object: Native response object such as `URLResponse`
    ///   - data: Response body
    ///   - response: Converted response object from `object`
    /// - Returns: Response object for the resutl of `AsyncHTTPKit.data`
    func intercept(object: Any, data: Data, response: AsyncHTTPResponse) throws -> (Data, AsyncHTTPResponse)
    
    ///
    /// - Parameters:
    ///   - object: Native response object such as `URLResponse`
    ///   - stream: Response stream
    ///   - response: Converted response object from `object`
    /// - Returns: Tuple of `(AsyncSequence<UInt8, Error>, AsyncHTTPResponse)` for the result of `AsyncHTTPKit.bytes`
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
