//
//  AsyncHTTPKit_macOS.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/29.
//
import Foundation

extension URLSession: Session {}

extension AsyncHTTPKit {
    /// The shared singleton session object.
    public static var shared: AsyncHTTPKit {
        .init(session: URLSession.shared)
    }

    var urlSession: URLSession? {
        return session as? URLSession
    }

    func response(for request: AsyncHTTPRequest) async throws -> (Data, Response) {
        guard let urlSession else {
            fatalError()
        }

        let (data, response) = try await urlSession.data(for: try request.toURLRequest)
        return try request.intercept(object: response, data: data, response: AsyncHTTPResponse.build(from: response))
    }

    func stream(for request: AsyncHTTPRequest) async throws -> (some AsyncSequence<UInt8, Error>, AsyncHTTPResponse) {
        guard let urlSession else {
            fatalError()
        }

        let (stream, response) = try await urlSession.bytes(for: try request.toURLRequest)

        return try request.intercept(object: response, stream: stream, response: AsyncHTTPResponse.build(from: response))
    }
}
