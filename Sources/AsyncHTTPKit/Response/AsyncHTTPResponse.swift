//
//  AsyncHTTPResponse.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//

import Foundation

public struct AsyncHTTPResponse: Sendable {
    /// Status code of response
    public let statusCode: Int

    /// URL for request
    public let url: URL?

    /// Headers for the response
    public let allHeaderFields: [String : String]

    public init(
        statusCode: Int,
        url: URL? = nil,
        allHeaderFields: [String : String] = [:]
    ) {
        self.statusCode = statusCode
        self.url = url
        self.allHeaderFields = allHeaderFields
    }
}
