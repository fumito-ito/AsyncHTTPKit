//
//  AsyncHTTPKit_macOS.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/29.
//
import Foundation

extension AsyncHTTPKit {
    /// The shared singleton session object.
    public static var shared: AsyncHTTPKit {
        .init(adapter: URLSessionAdapter(urlSession: .shared))
    }
}
