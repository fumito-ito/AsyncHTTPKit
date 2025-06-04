import Foundation
#if os(macOS)
#elseif os(Linux)
import AsyncHTTPClient
#endif
@testable import AsyncHTTPKit

// MARK: - Common Test Request Implementation
struct TestRequest: AsyncHTTPRequest {
    let method: AsyncHTTPMethod
    let headers: [String: String]
    let body: Data?
    let url: URL
    let contentType: String
    
    init(
        method: AsyncHTTPMethod,
        url: URL,
        headers: [String: String] = [:],
        body: Data? = nil,
        contentType: String = "application/json"
    ) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.contentType = contentType
    }
    
    #if os(macOS) || os(iOS)
    func intercept(object: AsyncHTTPRequest, request: URLRequest) throws -> URLRequest {
        return request
    }
    #elseif os(Linux)
    func intercept(object: AsyncHTTPRequest, request: HTTPClientRequest) throws -> HTTPClientRequest {
        return request
    }
    #endif
}

// MARK: - Test Data Factory
enum TestData {
    static func json(_ string: String) -> Data {
        string.data(using: .utf8)!
    }
    
    static func text(_ string: String) -> Data {
        string.data(using: .utf8)!
    }
    
    static func binary(size: Int, value: UInt8 = 0x42) -> Data {
        Data(repeating: value, count: size)
    }
    
    static var empty: Data {
        Data()
    }
    
    static var sampleJSON: Data {
        json("""
        {
            "message": "Hello, World!",
            "timestamp": "2025-06-04T08:00:00Z"
        }
        """)
    }
}

// MARK: - Test URL Factory
enum TestURL {
    static let example = URL(string: "https://example.com")!
    static let api = URL(string: "https://api.example.com")!
    
    static func custom(_ string: String) -> URL {
        URL(string: string)!
    }
    
    static func path(_ path: String, base: URL = example) -> URL {
        base.appendingPathComponent(path)
    }
}

// MARK: - Response Builder
struct TestResponseBuilder {
    private var statusCode: Int = 200
    private var url: URL = TestURL.example
    private var headers: [String: String] = [:]
    
    func status(_ code: Int) -> TestResponseBuilder {
        var builder = self
        builder.statusCode = code
        return builder
    }
    
    func url(_ url: URL) -> TestResponseBuilder {
        var builder = self
        builder.url = url
        return builder
    }
    
    func header(_ key: String, _ value: String) -> TestResponseBuilder {
        var builder = self
        builder.headers[key] = value
        return builder
    }
    
    func headers(_ headers: [String: String]) -> TestResponseBuilder {
        var builder = self
        builder.headers.merge(headers) { _, new in new }
        return builder
    }
    
    func contentType(_ type: String) -> TestResponseBuilder {
        header("Content-Type", type)
    }
    
    func contentLength(_ length: Int) -> TestResponseBuilder {
        header("Content-Length", "\(length)")
    }
    
    func build() -> AsyncHTTPResponse {
        AsyncHTTPResponse(
            statusCode: statusCode,
            url: url,
            allHeaderFields: headers
        )
    }
}

// MARK: - Request Builder
struct TestRequestBuilder {
    private var method: AsyncHTTPMethod = .GET
    private var url: URL = TestURL.example
    private var headers: [String: String] = [:]
    private var body: Data? = nil
    private var contentType: String = "application/json"
    
    func method(_ method: AsyncHTTPMethod) -> TestRequestBuilder {
        var builder = self
        builder.method = method
        return builder
    }
    
    func url(_ url: URL) -> TestRequestBuilder {
        var builder = self
        builder.url = url
        return builder
    }
    
    func url(_ string: String) -> TestRequestBuilder {
        var builder = self
        builder.url = URL(string: string)!
        return builder
    }
    
    func header(_ key: String, _ value: String) -> TestRequestBuilder {
        var builder = self
        builder.headers[key] = value
        return builder
    }
    
    func headers(_ headers: [String: String]) -> TestRequestBuilder {
        var builder = self
        builder.headers.merge(headers) { _, new in new }
        return builder
    }
    
    func body(_ data: Data) -> TestRequestBuilder {
        var builder = self
        builder.body = data
        return builder
    }
    
    func jsonBody(_ string: String) -> TestRequestBuilder {
        var builder = self
        builder.body = TestData.json(string)
        builder.contentType = "application/json"
        return builder
    }
    
    func textBody(_ string: String) -> TestRequestBuilder {
        var builder = self
        builder.body = TestData.text(string)
        builder.contentType = "text/plain"
        return builder
    }
    
    func contentType(_ type: String) -> TestRequestBuilder {
        var builder = self
        builder.contentType = type
        return builder
    }
    
    func build() -> TestRequest {
        TestRequest(
            method: method,
            url: url,
            headers: headers,
            body: body,
            contentType: contentType
        )
    }
}

// MARK: - Mock Adapter Builder
struct TestAdapterBuilder {
    private var data: Data = Data()
    private var response: AsyncHTTPResponse = TestResponseBuilder().build()
    private var error: Error? = nil
    
    func data(_ data: Data) -> TestAdapterBuilder {
        var builder = self
        builder.data = data
        return builder
    }
    
    func textData(_ string: String) -> TestAdapterBuilder {
        var builder = self
        builder.data = TestData.text(string)
        return builder
    }
    
    func jsonData(_ string: String) -> TestAdapterBuilder {
        var builder = self
        builder.data = TestData.json(string)
        return builder
    }
    
    func response(_ response: AsyncHTTPResponse) -> TestAdapterBuilder {
        var builder = self
        builder.response = response
        return builder
    }
    
    func response(_ builder: TestResponseBuilder) -> TestAdapterBuilder {
        var builderSelf = self
        builderSelf.response = builder.build()
        return builderSelf
    }
    
    func error(_ error: Error) -> TestAdapterBuilder {
        var builder = self
        builder.error = error
        return builder
    }
    
    func build() -> MockSessionAdapter {
        MockSessionAdapter(
            mockData: data,
            mockResponse: response,
            mockError: error
        )
    }
}

// MARK: - Test Helper Functions
enum TestHelpers {
    static func createHTTPKit(
        data: Data = Data(),
        response: AsyncHTTPResponse? = nil,
        error: Error? = nil
    ) -> AsyncHTTPKit<MockSessionAdapter> {
        let mockResponse = response ?? TestResponseBuilder().build()
        let adapter = MockSessionAdapter(
            mockData: data,
            mockResponse: mockResponse,
            mockError: error
        )
        return AsyncHTTPKit(adapter: adapter)
    }
    
    static func createHTTPKit(adapter: MockSessionAdapter) -> AsyncHTTPKit<MockSessionAdapter> {
        AsyncHTTPKit(adapter: adapter)
    }
}

// MARK: - Convenience Extensions
extension TestResponseBuilder {
    static func response() -> TestResponseBuilder {
        TestResponseBuilder()
    }
    
    static func ok() -> TestResponseBuilder {
        TestResponseBuilder().status(200)
    }
    
    static func created() -> TestResponseBuilder {
        TestResponseBuilder().status(201)
    }
    
    static func noContent() -> TestResponseBuilder {
        TestResponseBuilder().status(204)
    }
    
    static func badRequest() -> TestResponseBuilder {
        TestResponseBuilder().status(400)
    }
    
    static func notFound() -> TestResponseBuilder {
        TestResponseBuilder().status(404)
    }
    
    static func serverError() -> TestResponseBuilder {
        TestResponseBuilder().status(500)
    }
}

extension TestRequestBuilder {
    static func request() -> TestRequestBuilder {
        TestRequestBuilder()
    }
    
    static func get(_ url: String) -> TestRequestBuilder {
        TestRequestBuilder().method(.GET).url(url)
    }
    
    static func post(_ url: String) -> TestRequestBuilder {
        TestRequestBuilder().method(.POST).url(url)
    }
    
    static func put(_ url: String) -> TestRequestBuilder {
        TestRequestBuilder().method(.PUT).url(url)
    }
    
    static func delete(_ url: String) -> TestRequestBuilder {
        TestRequestBuilder().method(.DELETE).url(url)
    }
    
    static func patch(_ url: String) -> TestRequestBuilder {
        TestRequestBuilder().method(.PATCH).url(url)
    }
    
    static func head(_ url: String) -> TestRequestBuilder {
        TestRequestBuilder().method(.HEAD).url(url)
    }
}

extension TestAdapterBuilder {
    static func adapter() -> TestAdapterBuilder {
        TestAdapterBuilder()
    }
    
    static func success(data: Data = Data(), status: Int = 200) -> TestAdapterBuilder {
        TestAdapterBuilder()
            .data(data)
            .response(TestResponseBuilder().status(status).build())
    }
    
    static func error(_ error: Error) -> TestAdapterBuilder {
        TestAdapterBuilder().error(error)
    }
}
