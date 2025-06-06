//
//  AsyncHTTPMethod.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/28.
//

/// HTTP methods supported by AsyncHTTPKit.
///
/// This enumeration defines the standard HTTP methods that can be used
/// for making requests through AsyncHTTPKit.
public enum AsyncHTTPMethod: String, Sendable {
    /// GET method - Retrieve data from the server.
    case GET        = "get"
    
    /// POST method - Submit data to the server.
    case POST       = "post"
    
    /// PUT method - Update or create a resource on the server.
    case PUT        = "put"
    
    /// DELETE method - Remove a resource from the server.
    case DELETE     = "delete"
    
    /// HEAD method - Retrieve headers only, without the response body.
    case HEAD       = "head"
    
    /// PATCH method - Apply partial modifications to a resource.
    case PATCH      = "patch"
    
    /// TRACE method - Perform a message loop-back test.
    case TRACE      = "trace"
    
    /// OPTIONS method - Retrieve supported methods and capabilities.
    case OPTIONS    = "options"
    
    /// CONNECT method - Establish a tunnel to the server.
    case CONNECT    = "connect"
}
