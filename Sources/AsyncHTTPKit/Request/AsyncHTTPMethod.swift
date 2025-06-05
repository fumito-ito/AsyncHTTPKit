//
//  AsyncHTTPMethod.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//

/// HTTP methods for request.
public enum AsyncHTTPMethod: String, Sendable {
    case GET        = "get"
    case POST       = "post"
    case PUT        = "put"
    case DELETE     = "delete"
    case HEAD       = "head"
    case PATCH      = "patch"
    case TRACE      = "trace"
    case OTIONS     = "options"
    case CONNECT    = "connect"
}
