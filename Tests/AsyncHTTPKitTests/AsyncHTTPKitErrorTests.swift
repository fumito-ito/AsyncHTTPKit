import Testing
import Foundation
import AsyncHTTPClient
@testable import AsyncHTTPKit

@Test("AsyncHTTPKitError.networkRequestFailed")
func testNetworkRequestFailedError() async throws {
    struct NetworkError: Error {}
    let networkError = NetworkError()
    
    let adapter = MockSessionAdapter(mockError: networkError)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = TestRequest()
    
    await #expect(throws: NetworkError.self) {
        try await httpKit.data(for: request)
    }
}

@Test("AsyncHTTPKitError properties and error description")
func testAsyncHTTPKitErrorProperties() throws {
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/test")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = TestRequest()
    
    // Test networkRequestFailed error
    let networkError = AsyncHTTPKitError.networkRequestFailed(request: request)
    #expect(networkError.failedRequest.url == request.url)
    #expect(networkError.failedRequest.method.rawValue == "get")
    #expect(networkError.errorDescription?.contains("Network request failed") == true)
    #expect(networkError.errorDescription?.contains("get") == true)
    #expect(networkError.errorDescription?.contains("https://example.com/test") == true)
    
    // Test responseStreamEmpty error
    let streamError = AsyncHTTPKitError.responseStreamEmpty(request: request)
    #expect(streamError.failedRequest.url == request.url)
    #expect(streamError.errorDescription?.contains("Response stream contains no data") == true)
}

@Test("Error thrown during data request")
func testErrorThrownDuringDataRequest() async throws {
    struct CustomError: Error, Equatable {
        let message: String
    }
    let customError = CustomError(message: "Custom network error")
    
    let adapter = MockSessionAdapter(mockError: customError)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .POST }
        var headers: [String: String] { ["Content-Type": "application/json"] }
        var body: Data? { "test".data(using: .utf8) }
        var url: URL { URL(string: "https://api.example.com")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = TestRequest()
    
    await #expect(throws: CustomError.self) {
        try await httpKit.data(for: request)
    }
}

@Test("Error thrown during stream request")
func testErrorThrownDuringStreamRequest() async throws {
    struct StreamError: Error {}
    let streamError = StreamError()
    
    let adapter = MockSessionAdapter(mockError: streamError)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/stream")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = TestRequest()
    
    await #expect(throws: StreamError.self) {
        try await httpKit.bytes(for: request)
    }
}

@Test("Multiple different error types")
func testMultipleDifferentErrorTypes() async throws {
    struct NetworkTimeoutError: Error {}
    struct DNSResolutionError: Error {}
    struct SSLError: Error {}
    
    let errors: [Error] = [
        NetworkTimeoutError(),
        DNSResolutionError(),
        SSLError()
    ]
    
    struct TestRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = TestRequest()
    
    for error in errors {
        let adapter = MockSessionAdapter(mockError: error)
        let httpKit = AsyncHTTPKit(adapter: adapter)
        
        await #expect(throws: (any Error).self) {
            try await httpKit.data(for: request)
        }
    }
}