import Testing
import Foundation
#if os(Linux)
import AsyncHTTPClient
#endif
@testable import AsyncHTTPKit

// MARK: - HTTP Test Case DSL
struct HTTPTestCase {
    private let request: TestRequest
    private let adapter: MockSessionAdapter
    private let httpKit: AsyncHTTPKit
    
    private var expectedStatusCode: Int?
    private var expectedData: Data?
    private var expectedHeaders: [String: String] = [:]
    private var shouldExpectError: Bool = false
    private var expectedErrorType: Any.Type?
    
    private init(request: TestRequest, adapter: MockSessionAdapter) {
        self.request = request
        self.adapter = adapter
        self.httpKit = AsyncHTTPKit(adapter: adapter)
    }
    
    // MARK: - Static Factory Methods
    static func request(_ builder: TestRequestBuilder) -> HTTPTestCase {
        let request = builder.build()
        let adapter = TestAdapterBuilder().build()
        return HTTPTestCase(request: request, adapter: adapter)
    }
    
    static func get(_ url: String) -> HTTPTestCase {
        request(TestRequestBuilder.get(url))
    }
    
    static func post(_ url: String) -> HTTPTestCase {
        request(TestRequestBuilder.post(url))
    }
    
    static func put(_ url: String) -> HTTPTestCase {
        request(TestRequestBuilder.put(url))
    }
    
    static func delete(_ url: String) -> HTTPTestCase {
        request(TestRequestBuilder.delete(url))
    }
    
    static func patch(_ url: String) -> HTTPTestCase {
        request(TestRequestBuilder.patch(url))
    }
    
    static func head(_ url: String) -> HTTPTestCase {
        request(TestRequestBuilder.head(url))
    }
    
    // MARK: - Configuration Methods
    func withBody(_ data: Data) -> HTTPTestCase {
        let newRequest = TestRequestBuilder.request()
            .method(request.method)
            .url(request.url)
            .headers(request.headers)
            .body(data)
            .contentType(request.contentType)
            .build()
        return HTTPTestCase(request: newRequest, adapter: adapter)
    }
    
    func withJSONBody(_ json: String) -> HTTPTestCase {
        withBody(TestData.json(json))
    }
    
    func withTextBody(_ text: String) -> HTTPTestCase {
        withBody(TestData.text(text))
    }
    
    func withHeaders(_ headers: [String: String]) -> HTTPTestCase {
        var builder = TestRequestBuilder.request()
            .method(request.method)
            .url(request.url)
            .headers(headers)
            .contentType(request.contentType)
        
        if let body = request.body {
            builder = builder.body(body)
        }
        
        let newRequest = builder.build()
        return HTTPTestCase(request: newRequest, adapter: adapter)
    }
    
    func withHeader(_ key: String, _ value: String) -> HTTPTestCase {
        var newHeaders = request.headers
        newHeaders[key] = value
        return withHeaders(newHeaders)
    }
    
    // MARK: - Mock Response Configuration
    func returningData(_ data: Data) -> HTTPTestCase {
        let newAdapter = TestAdapterBuilder()
            .data(data)
            .response(adapter.mockResponse)
            .build()
        return HTTPTestCase(request: request, adapter: newAdapter)
    }
    
    func returningJSON(_ json: String) -> HTTPTestCase {
        returningData(TestData.json(json))
    }
    
    func returningText(_ text: String) -> HTTPTestCase {
        returningData(TestData.text(text))
    }
    
    func returningStatus(_ status: Int) -> HTTPTestCase {
        let newResponse = TestResponseBuilder()
            .status(status)
            .url(adapter.mockResponse.url ?? TestURL.example)
            .headers(adapter.mockResponse.allHeaderFields)
            .build()
        
        let newAdapter = TestAdapterBuilder()
            .data(adapter.mockData)
            .response(newResponse)
            .build()
        
        return HTTPTestCase(request: request, adapter: newAdapter)
    }
    
    func returningHeaders(_ headers: [String: String]) -> HTTPTestCase {
        let newResponse = TestResponseBuilder()
            .status(adapter.mockResponse.statusCode)
            .url(adapter.mockResponse.url ?? TestURL.example)
            .headers(headers)
            .build()
        
        let newAdapter = TestAdapterBuilder()
            .data(adapter.mockData)
            .response(newResponse)
            .build()
        
        return HTTPTestCase(request: request, adapter: newAdapter)
    }
    
    func returningError(_ error: Error) -> HTTPTestCase {
        let newAdapter = TestAdapterBuilder()
            .error(error)
            .build()
        return HTTPTestCase(request: request, adapter: newAdapter)
    }
    
    // MARK: - Expectation Methods
    func expectingStatus(_ status: Int) -> HTTPTestCase {
        var testCase = self
        testCase.expectedStatusCode = status
        return testCase
    }
    
    func expectingData(_ data: Data) -> HTTPTestCase {
        var testCase = self
        testCase.expectedData = data
        return testCase
    }
    
    func expectingJSON(_ json: String) -> HTTPTestCase {
        expectingData(TestData.json(json))
    }
    
    func expectingText(_ text: String) -> HTTPTestCase {
        expectingData(TestData.text(text))
    }
    
    func expectingHeader(_ key: String, _ value: String) -> HTTPTestCase {
        var testCase = self
        testCase.expectedHeaders[key] = value
        return testCase
    }
    
    func expectingError<T: Error>(_ errorType: T.Type) -> HTTPTestCase {
        var testCase = self
        testCase.shouldExpectError = true
        testCase.expectedErrorType = errorType
        return testCase
    }
    
    func expectingError() -> HTTPTestCase {
        var testCase = self
        testCase.shouldExpectError = true
        return testCase
    }
    
    // MARK: - Execution Methods
    func run() async throws {
        if shouldExpectError {
            do {
                _ = try await httpKit.data(for: request)
                #expect(Bool(false), "Expected an error but none was thrown")
            } catch {
                if let expectedType = expectedErrorType {
                    #expect(type(of: error) == expectedType, "Expected error of type \(expectedType), got \(type(of: error))")
                }
                // Error was expected and thrown
            }
        } else {
            let (data, response) = try await httpKit.data(for: request)
            
            if let expectedStatus = expectedStatusCode {
                #expect(response.statusCode == expectedStatus, 
                       "Expected status \(expectedStatus), got \(response.statusCode)")
            }
            
            if let expectedData = expectedData {
                #expect(data == expectedData, 
                       "Expected data to match")
            }
            
            for (key, expectedValue) in expectedHeaders {
                let actualValue = response.allHeaderFields[key]
                #expect(actualValue == expectedValue, 
                       "Expected header \(key) to be '\(expectedValue)', got '\(actualValue ?? "nil")'")
            }
        }
    }
    
    func runStream() async throws {
        if shouldExpectError {
            do {
                _ = try await httpKit.bytes(for: request)
                #expect(Bool(false), "Expected an error but none was thrown")
            } catch {
                if let expectedType = expectedErrorType {
                    #expect(type(of: error) == expectedType, "Expected error of type \(expectedType), got \(type(of: error))")
                }
                // Error was expected and thrown
            }
        } else {
            let (stream, response) = try await httpKit.bytes(for: request)
            
            var receivedData = Data()
            for try await byte in stream {
                receivedData.append(byte)
            }
            
            if let expectedStatus = expectedStatusCode {
                #expect(response.statusCode == expectedStatus, 
                       "Expected status \(expectedStatus), got \(response.statusCode)")
            }
            
            if let expectedData = expectedData {
                #expect(receivedData == expectedData, 
                       "Expected data to match")
            }
            
            for (key, expectedValue) in expectedHeaders {
                let actualValue = response.allHeaderFields[key]
                #expect(actualValue == expectedValue, 
                       "Expected header \(key) to be '\(expectedValue)', got '\(actualValue ?? "nil")'")
            }
        }
    }
}

// MARK: - Common Test Scenarios
extension HTTPTestCase {
    static func successfulGET(_ url: String = "https://example.com", data: String = "Success") -> HTTPTestCase {
        get(url)
            .returningText(data)
            .returningStatus(200)
            .expectingStatus(200)
            .expectingText(data)
    }
    
    static func successfulPOST(_ url: String = "https://example.com", responseData: String = "Created") -> HTTPTestCase {
        post(url)
            .returningText(responseData)
            .returningStatus(201)
            .expectingStatus(201)
            .expectingText(responseData)
    }
    
    static func notFoundError(_ url: String = "https://example.com/missing") -> HTTPTestCase {
        get(url)
            .returningText("Not Found")
            .returningStatus(404)
            .expectingStatus(404)
    }
    
    static func serverError(_ url: String = "https://example.com") -> HTTPTestCase {
        get(url)
            .returningText("Internal Server Error")
            .returningStatus(500)
            .expectingStatus(500)
    }
    
    static func noContent(_ url: String = "https://example.com") -> HTTPTestCase {
        delete(url)
            .returningData(Data())
            .returningStatus(204)
            .expectingStatus(204)
            .expectingData(Data())
    }
}
