//
//  AsyncHTTPResponse.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//

import Foundation

public struct AsyncHTTPResponse {
    /// Status code of response
    public let statusCode: Int

    /// URL for request
    public let url: URL?

    /// Headers for the response
    public let allHeaderFields: [AnyHashable : Any]
}
