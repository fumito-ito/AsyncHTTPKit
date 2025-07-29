//
//  AsyncHTTPResponse_linux.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/29.
//
import AsyncHTTPClient
import Foundation
import NIOCore
import NIOFoundationCompat

public extension AsyncHTTPResponse {
    static func build(from response: HTTPClientResponse) async throws -> (Data, AsyncHTTPResponse) {
        return (
            try await response.body.collect(upTo: 1_048_576).getData(),
            AsyncHTTPResponse(
                statusCode: Int(response.status.code),
                url: response.url,
                allHeaderFields: response.headers.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
            )
        )
    }
}

private extension ByteBuffer {
    func getData() -> Data {
        var buf = self
        return buf.readData(length: buf.readableBytes) ?? Data()
    }
}
