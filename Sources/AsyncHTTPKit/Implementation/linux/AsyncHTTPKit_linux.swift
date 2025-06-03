//
//  AsyncHTTPKit_linux.swift
//  AsyncHTTPKit
//
//  Created by 伊藤史 on 2025/05/29.
//

import AsyncHTTPClient
import NIOCore
import Foundation

extension AsyncHTTPKit where Adapter == HTTPClientAdapter {
    /// The shared singleton session object.
    public static var shared: AsyncHTTPKit<HTTPClientAdapter> {
        .init(adapter: HTTPClientAdapter(client: .shared))
    }
}
