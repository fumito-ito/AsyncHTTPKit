import Testing
import Foundation
import AsyncHTTPClient
@testable import AsyncHTTPKit

@Test("200 OK response handling")
func test200OKResponse() async throws {
    let responseData = "Success response".data(using: .utf8)!
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://example.com"),
        allHeaderFields: ["Content-Type": "text/plain", "Content-Length": "16"]
    )
    
    let adapter = MockSessionAdapter(mockData: responseData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct SuccessRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = SuccessRequest()
    let (data, response) = try await httpKit.data(for: request)
    
    #expect(data == responseData)
    #expect(response.statusCode == 200)
    #expect(response.allHeaderFields["Content-Type"] == "text/plain")
    #expect(response.allHeaderFields["Content-Length"] == "16")
}

@Test("201 Created response handling")
func test201CreatedResponse() async throws {
    let responseData = """
    {
        "id": 123,
        "message": "Resource created successfully"
    }
    """.data(using: .utf8)!
    
    let mockResponse = AsyncHTTPResponse(
        statusCode: 201,
        url: URL(string: "https://api.example.com/resources"),
        allHeaderFields: [
            "Content-Type": "application/json",
            "Location": "https://api.example.com/resources/123"
        ]
    )
    
    let adapter = MockSessionAdapter(mockData: responseData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct CreateRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .POST }
        var headers: [String: String] { ["Content-Type": "application/json"] }
        var body: Data? { "{\"name\": \"Test Resource\"}".data(using: .utf8) }
        var url: URL { URL(string: "https://api.example.com/resources")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = CreateRequest()
    let (data, response) = try await httpKit.data(for: request)
    
    #expect(response.statusCode == 201)
    #expect(response.allHeaderFields["Location"] == "https://api.example.com/resources/123")
    #expect(data == responseData)
}

@Test("204 No Content response handling")
func test204NoContentResponse() async throws {
    let mockResponse = AsyncHTTPResponse(
        statusCode: 204,
        url: URL(string: "https://example.com"),
        allHeaderFields: [:]
    )
    
    let adapter = MockSessionAdapter(mockData: Data(), mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct NoContentRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .DELETE }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/resource/123")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = NoContentRequest()
    let (data, response) = try await httpKit.data(for: request)
    
    #expect(response.statusCode == 204)
    #expect(data.isEmpty)
}

@Test("400 Bad Request error response")
func test400BadRequestResponse() async throws {
    let errorData = """
    {
        "error": "Bad Request",
        "message": "Invalid input parameters"
    }
    """.data(using: .utf8)!
    
    let mockResponse = AsyncHTTPResponse(
        statusCode: 400,
        url: URL(string: "https://api.example.com"),
        allHeaderFields: ["Content-Type": "application/json"]
    )
    
    let adapter = MockSessionAdapter(mockData: errorData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct BadRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .POST }
        var headers: [String: String] { ["Content-Type": "application/json"] }
        var body: Data? { "invalid json".data(using: .utf8) }
        var url: URL { URL(string: "https://api.example.com")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = BadRequest()
    let (data, response) = try await httpKit.data(for: request)
    
    #expect(response.statusCode == 400)
    #expect(data == errorData)
    #expect(response.allHeaderFields["Content-Type"] == "application/json")
}

@Test("404 Not Found error response")
func test404NotFoundResponse() async throws {
    let errorData = "Resource not found".data(using: .utf8)!
    let mockResponse = AsyncHTTPResponse(
        statusCode: 404,
        url: URL(string: "https://example.com/missing"),
        allHeaderFields: ["Content-Type": "text/plain"]
    )
    
    let adapter = MockSessionAdapter(mockData: errorData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct NotFoundRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/missing")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = NotFoundRequest()
    let (data, response) = try await httpKit.data(for: request)
    
    #expect(response.statusCode == 404)
    #expect(data == errorData)
}

@Test("500 Internal Server Error response")
func test500InternalServerErrorResponse() async throws {
    let errorData = "Internal server error occurred".data(using: .utf8)!
    let mockResponse = AsyncHTTPResponse(
        statusCode: 500,
        url: URL(string: "https://api.example.com"),
        allHeaderFields: ["Content-Type": "text/plain"]
    )
    
    let adapter = MockSessionAdapter(mockData: errorData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct ServerErrorRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://api.example.com/error")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = ServerErrorRequest()
    let (data, response) = try await httpKit.data(for: request)
    
    #expect(response.statusCode == 500)
    #expect(data == errorData)
}

@Test("Empty response body")
func testEmptyResponseBody() async throws {
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://example.com"),
        allHeaderFields: ["Content-Length": "0"]
    )
    
    let adapter = MockSessionAdapter(mockData: Data(), mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct EmptyBodyRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/empty")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = EmptyBodyRequest()
    let (data, response) = try await httpKit.data(for: request)
    
    #expect(response.statusCode == 200)
    #expect(data.isEmpty)
    #expect(response.allHeaderFields["Content-Length"] == "0")
}

@Test("Large response body")
func testLargeResponseBody() async throws {
    // Create 100KB of test data
    let largeData = Data(repeating: 0x41, count: 102400) // 'A' repeated 100KB times
    let mockResponse = AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://example.com"),
        allHeaderFields: [
            "Content-Type": "application/octet-stream",
            "Content-Length": "102400"
        ]
    )
    
    let adapter = MockSessionAdapter(mockData: largeData, mockResponse: mockResponse)
    let httpKit = AsyncHTTPKit(adapter: adapter)
    
    struct LargeDataRequest: AsyncHTTPRequest {
        var method: AsyncHTTPMethod { .GET }
        var headers: [String: String] { [:] }
        var body: Data? { nil }
        var url: URL { URL(string: "https://example.com/large")! }
        var contentType: String { "application/json" }

        func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
            return request
        }
    }
    
    let request = LargeDataRequest()
    let (data, response) = try await httpKit.data(for: request)
    
    #expect(response.statusCode == 200)
    #expect(data.count == 102400)
    #expect(data == largeData)
    #expect(response.allHeaderFields["Content-Length"] == "102400")
}