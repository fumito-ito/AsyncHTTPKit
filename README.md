# AsyncHTTPKit

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%2015%2B%20%7C%20iOS%2018%2B%20%7C%20Linux-lightgrey.svg?style=flat)](https://github.com/swift-package-manager)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](LICENSE)

**Modern async/await HTTP client for Swift with true cross-platform support and flexible adapter architecture.**

AsyncHTTPKit provides a unified HTTP client experience across macOS, iOS, and Linux using the latest Swift concurrency features. Built with the SessionAdapter pattern for maximum flexibility and testability.

## 🎯 Motivation

This library was created to address the limitations of existing Swift HTTP libraries when developing in Dev Container environments on Linux:

**URLSession Limitations on Linux:**
- Byte streaming APIs are not available on Linux platforms
- URLProtocol-based testing doesn't work reliably on Linux

**[Alamofire](https://github.com/Alamofire/Alamofire) Linux Challenges:**
- While Linux-compatible with byte streaming support, it relies on URLProtocol for mocking in tests
- This dependency causes the same Linux testing issues as URLSession

**[APIKit](https://github.com/ishkawa/APIKit) Compatibility Issues:**
- Provides excellent URLProtocol-independent testing capabilities
- However, lacks Linux platform support entirely

**[AsyncHTTPClient](https://github.com/swift-server/async-http-client) Trade-offs:**
- Full Linux support with robust byte streaming APIs
- URLProtocol-independent testing architecture
- But features a unique API interface that differs from Apple ecosystem conventions

AsyncHTTPKit bridges these gaps by providing a familiar, Apple-style API that works seamlessly across all platforms while maintaining excellent testability without URLProtocol dependencies.

## ✨ Features

- 🚀 **Swift 6.0 native** - Built with modern async/await and Sendable protocols
- 🌍 **True cross-platform** - Seamless experience on macOS, iOS, and Linux
- 🔄 **Flexible adapters** - URLSession (Apple platforms) and AsyncHTTPClient (Linux)
- 📡 **Streaming support** - Memory-efficient byte streaming with `AsyncSequence`
- 🧪 **Testing-first** - Comprehensive mock framework and fluent test DSL
- ⚡ **Type-safe** - Full Swift type system leverage with generics
- 🛡️ **Error handling** - Structured error types with request context

## 🚀 Quick Start

```swift
import AsyncHTTPKit

// Simple GET request
let (data, response) = try await AsyncHTTPKit.shared.data(for: GetUsersRequest())

// Streaming response
let (stream, response) = try await AsyncHTTPKit.shared.bytes(for: DownloadFileRequest())
for try await byte in stream {
    // Process bytes as they arrive
    print(byte)
}
```

## 📦 Installation

### Swift Package Manager

Add AsyncHTTPKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/AsyncHTTPKit.git", from: "0.0.1")
]
```

Or add it through Xcode: File → Add Package Dependencies

## 💡 Usage

### Basic HTTP Requests

Create requests by conforming to `AsyncHTTPRequest`:

```swift
struct GetUsersRequest: AsyncHTTPRequest {
    var method: AsyncHTTPMethod { .GET }
    var url: URL { URL(string: "https://api.example.com/users")! }
    var headers: [String: String] { ["Authorization": "Bearer token"] }
    var body: Data? { nil }
    var contentType: String { "application/json" }
}

// Execute the request
let (data, response) = try await AsyncHTTPKit.shared.data(for: GetUsersRequest())
print("Status: \(response.statusCode)")
```

### POST Requests with Body

```swift
struct CreateUserRequest: AsyncHTTPRequest {
    let userData: Data
    
    var method: AsyncHTTPMethod { .POST }
    var url: URL { URL(string: "https://api.example.com/users")! }
    var headers: [String: String] { [:] }
    var body: Data? { userData }
    var contentType: String { "application/json" }
}

let user = User(name: "John", email: "john@example.com")
let userData = try JSONEncoder().encode(user)
let request = CreateUserRequest(userData: userData)

let (data, response) = try await AsyncHTTPKit.shared.data(for: request)
```

### Streaming Downloads

For large files or real-time data, use the streaming API:

```swift
struct DownloadFileRequest: AsyncHTTPRequest {
    var method: AsyncHTTPMethod { .GET }
    var url: URL { URL(string: "https://example.com/large-file.zip")! }
    var headers: [String: String] { [:] }
    var body: Data? { nil }
    var contentType: String { "application/octet-stream" }
}

let (stream, response) = try await AsyncHTTPKit.shared.bytes(for: DownloadFileRequest())
var downloadedData = Data()

for try await byte in stream {
    downloadedData.append(byte)
    // Update progress, process chunks, etc.
}
```

## 🔧 Advanced Features

### Custom Session Adapters

AsyncHTTPKit uses the SessionAdapter pattern for maximum flexibility:

```swift
// Create custom HTTP client with specific adapter
let customAdapter = URLSessionAdapter(urlSession: .shared)
let httpKit = AsyncHTTPKit(adapter: customAdapter)

let (data, response) = try await httpKit.data(for: request)
```

### Request Interception

Modify requests before execution:

```swift
struct AuthenticatedRequest: AsyncHTTPRequest {
    // ... basic properties ...
    
    func intercept(object: AsyncHTTPRequest, request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return modifiedRequest
    }
}
```

### Response Interception

Process responses before returning:

```swift
func intercept(object: Any, data: Data, response: AsyncHTTPResponse) throws -> (Data, AsyncHTTPResponse) {
    // Log response, decrypt data, etc.
    logger.info("Response: \(response.statusCode)")
    return (data, response)
}
```

## 🧪 Testing

AsyncHTTPKit provides excellent testing support with `MockSessionAdapter` and fluent test DSL:

### Mock Adapter

```swift
import AsyncHTTPKit

let mockAdapter = MockSessionAdapter(
    mockData: """
    {"users": [{"id": 1, "name": "John"}]}
    """.data(using: .utf8)!,
    mockResponse: AsyncHTTPResponse(
        statusCode: 200,
        url: URL(string: "https://api.example.com/users"),
        allHeaderFields: ["Content-Type": "application/json"]
    )
)

let httpKit = AsyncHTTPKit(adapter: mockAdapter)
let (data, response) = try await httpKit.data(for: GetUsersRequest())
```

### Fluent Test DSL

```swift
func testGetUsers() async throws {
    try await HTTPTestCase
        .get("https://api.example.com/users")
        .withHeader("Authorization", "Bearer token")
        .returningJSON("""
        {"users": [{"id": 1, "name": "John"}]}
        """)
        .returningStatus(200)
        .expectingStatus(200)
        .expectingHeader("Content-Type", "application/json")
        .run()
}

func testStreamingDownload() async throws {
    try await HTTPTestCase
        .get("https://example.com/file.txt")
        .returningText("Hello, streaming world!")
        .expectingText("Hello, streaming world!")
        .runStream()
}
```

## 🌍 Platform Support

AsyncHTTPKit provides optimized implementations for each platform:

| Platform | Implementation | Requirements |
|----------|----------------|--------------|
| **macOS** | URLSession | macOS 15.0+ |
| **iOS** | URLSession | iOS 18.0+ |
| **Linux** | AsyncHTTPClient | Swift 6.0+ |

The library automatically selects the appropriate implementation at compile time and excludes unused platform code.

## ⚠️ Error Handling

AsyncHTTPKit provides structured error handling:

```swift
do {
    let (data, response) = try await httpKit.data(for: request)
} catch let error as AsyncHTTPKitError {
    switch error {
    case .networkRequestFailed(let request):
        print("Network failed for: \(request.url)")
    case .responseStreamEmpty(let request):
        print("Empty response from: \(request.url)")
    case .invalidResponse(let response, let request):
        print("Invalid response type: \(type(of: response))")
    }
    
    // Access the failed request
    let failedRequest = error.failedRequest
}
```

## 🏗️ Architecture

AsyncHTTPKit is built around the SessionAdapter pattern:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   AsyncHTTPKit  │───▶│  SessionAdapter  │───▶│ Platform Impl   │
│                 │    │                  │    │                 │
│ • data(for:)    │    │ • data(for:)     │    │ • URLSession    │
│ • bytes(for:)   │    │ • stream(for:)   │    │ • HTTPClient    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

This design provides:
- **Flexibility**: Easy to swap networking backends
- **Testability**: Simple mocking with `MockSessionAdapter`
- **Extensibility**: Add support for new HTTP clients
- **Platform optimization**: Each platform uses its optimal implementation

## 📚 API Reference

### Core Types

- **`AsyncHTTPKit<Adapter>`** - Main HTTP client (generic over adapter type)
- **`AsyncHTTPRequest`** - Protocol for defining HTTP requests
- **`AsyncHTTPResponse`** - Response container with status, headers, and URL
- **`AsyncHTTPMethod`** - HTTP method enumeration
- **`AsyncHTTPKitError`** - Structured error types

### Session Adapters

- **`URLSessionAdapter`** - Apple platforms implementation
- **`HTTPClientAdapter`** - Linux implementation  
- **`MockSessionAdapter`** - Testing implementation

### Testing Utilities

- **`HTTPTestCase`** - Fluent test case builder
- **`TestData`** - Test data utilities
- **`TestRequestBuilder`** - Request builder for tests

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
git clone https://github.com/your-org/AsyncHTTPKit.git
cd AsyncHTTPKit
swift build
swift test
```

## 📄 License

AsyncHTTPKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## 🙏 Acknowledgments

- Built with [AsyncHTTPClient](https://github.com/swift-server/async-http-client) for Linux support
- Inspired by [APIKit](https://github.com/ishkawa/APIKit) adapter pattern
- Leverages Apple's URLSession for iOS/macOS optimization

---

**Ready to make HTTP requests the modern Swift way?** Start with AsyncHTTPKit today! 🚀