//
//  AsyncHTTPKit_linux.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/29.
//

import AsyncHTTPClient
import NIOCore
import Foundation

extension HTTPClient: Session {}

extension AsyncHTTPKit {
    /// The shared singleton session object.
    public static var shared: AsyncHTTPKit {
        .init(session: HTTPClient.shared)
    }

    var client: HTTPClient? {
        return session as? HTTPClient
    }

    func response(for request: AsyncHTTPRequest) async throws -> (Data, Response) {
        guard let client else {
            fatalError()
        }

        let httpClientResponse = try await client.execute(request.toHTTPClientRequest, timeout: .seconds(10))
        let (data, response) = try AsyncHTTPResponse.build(from: httpClientResponse)
        return try request.intercept(object: httpClientResponse, data: data, response: response)
    }

    func stream(for request: AsyncHTTPRequest) async throws -> (some AsyncSequence<UInt8, Error>, AsyncHTTPResponse) {
        guard let client else {
            fatalError()
        }

        var task: Task<Void, Never>?

        let responseStream = AsyncThrowingStream<(ByteBuffer, HTTPClientResponse), Error> { continuation in
            defer {
                continuation.finish()
                let _ = client.shutdown()
                task?.cancel()
            }

            task = Task {
                do {
                    let request = try request.toHTTPClientRequest
                    guard let response = try? await client.execute(request, timeout: .seconds(10)) else {
                        fatalError()
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
            fatalError()
        }

        let (_, response) = try AsyncHTTPResponse.build(from: reachedResponse)

        return try request.intercept(object: reachedResponse, stream: AsyncBytes(stream: bufferStream), response: response)
    }
}
