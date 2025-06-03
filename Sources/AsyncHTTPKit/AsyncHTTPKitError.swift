//
//  AsyncHTTPKitError.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/06/03.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public enum AsyncHTTPKitError: Error, LocalizedError {
    case networkRequestFailed(request: AsyncHTTPRequest)
    case responseStreamEmpty(request: AsyncHTTPRequest)
    case invalidResponse(URLResponse, request: AsyncHTTPRequest)
    
    public var errorDescription: String? {
        switch self {
        case .networkRequestFailed(let request):
            return "Network request failed to execute: \(request.method.rawValue) \(request.url)"
        case .responseStreamEmpty(let request):
            return "Response stream contains no data for request: \(request.method.rawValue) \(request.url)"
        case .invalidResponse(let response, let request):
            return "Invalid response type for request \(request.method.rawValue) \(request.url): expected HTTPURLResponse, got \(type(of: response))"
        }
    }
    
    /// 問題が発生したリクエストを取得
    public var failedRequest: AsyncHTTPRequest {
        switch self {
        case .networkRequestFailed(let request),
             .responseStreamEmpty(let request),
             .invalidResponse(_, let request):
            return request
        }
    }
}