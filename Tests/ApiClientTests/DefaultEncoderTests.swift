import XCTest
@testable import ApiClient

class DefaultEncoderTests: XCTestCase {

    //MARK: - test method
    func test_get_method() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(method: .get)

        let urlRequest = try sut.request(from: URL(string: "https://test-api.aydo.app/api")!, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.httpMethod, "GET")
    }

    func test_post_method() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(method: .post)

        let urlRequest = try sut.request(from: URL(string: "https://test-api.aydo.app/api")!, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.httpMethod, "POST")
    }

    func test_put_method() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(method: .put)

        let urlRequest = try sut.request(from: URL(string: "https://test-api.aydo.app/api")!, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.httpMethod, "PUT")
    }

    func test_delete_method() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(method: .delete)

        let urlRequest = try sut.request(from: URL(string: "https://test-api.aydo.app/api")!, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.httpMethod, "DELETE")
    }

    //MARK: - test url
    func test_url_encoding_with_empty_query_items() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(path: "/jobs", queryItems: [String:String]())

        let urlRequest = try sut.request(from: URL(string: "https://test-api.aydo.app/api")!, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.url, URL(string: "https://test-api.aydo.app/api/jobs"))
    }

    func test_url_encoding_with_query_items_having_space() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(path: "/jobs", queryItems: ["filter type":"2"])

        let urlRequest = try sut.request(from: URL(string: "https://test-api.aydo.app/api")!, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.url, URL(string: "https://test-api.aydo.app/api/jobs?filter%20type=2"))
    }

//    func test_url_encoding_with_two_query_items() throws {
//        let sut = makeSut()
//        let endpoint = makeEndpoint(path: "/jobs", queryItems: ["page": "1","filter type":"2"])
//
//        let urlRequest = try sut.request(from: URL(string: "https://test-api.aydo.app/api")!, endPoint: endpoint, encoder: JSONEncoder())
//
//        XCTAssertEqual(urlRequest.url, URL(string: "https://test-api.aydo.app/api/jobs?page=1&filter%20type=2"))
//    }

    //MARK: - test parameter encoding type
    func test_json_encoding() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(encoding: JSONEncoding.default)

        let urlRequest = try sut.request(from: baseURL, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
    }

    func test_form_url_encoding() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(encoding: FormURLEncoding.default)

        let urlRequest = try sut.request(from: baseURL, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded")
    }

    func test_multipart_encoding() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(encoding: MultipartFormEncoding.default)

        let urlRequest = try sut.request(from: baseURL, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "multipart/form-data")
    }

    //MARK: test body

    func test_nil_body() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(body: nil)

        let urlRequest = try sut.request(from: baseURL, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.httpBody, nil)
    }

    func test_empty_body() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(body: [String:String]())
        let encoder = JSONEncoder()

        let urlRequest = try sut.request(from: baseURL, endPoint: endpoint, encoder: encoder)

        XCTAssertEqual(urlRequest.httpBody, try? encoder.encode([String:String]()))
    }

    func test_body_with_data() throws {
        let sut = makeSut()
        let body = ExampleBody(title: "hero", name: "big")
        let endpoint = makeEndpoint(body: body)
        let encoder = JSONEncoder()

        let urlRequest = try sut.request(from: baseURL, endPoint: endpoint, encoder: encoder)

        XCTAssertEqual(urlRequest.httpBody, try? encoder.encode(body))
    }

    //MARK: test headers
    func test_headers() throws {
        let sut = makeSut()
        let endpoint = makeEndpoint(headers: ["name": "big", "title":"hero"])

        let urlRequest = try sut.request(from: baseURL, endPoint: endpoint, encoder: JSONEncoder())

        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type":"application/json","name":"big","title":"hero"])
    }

    //MARK: - Helpers
    func makeSut() ->  DefaultHTTPEncoder {
        return DefaultHTTPEncoder()
    }

    let baseURL = URL(string: "https://test-api.aydo.app/api")!

    func makeEndpoint(method: HTTPMethod = .get,
                      baseURL: URL = URL(string: "https://test-api.aydo.app/api")!,
                      path: String = "" ,
                      encoding: HTTPEncoding = JSONEncoding.default,
                      queryItems: Encodable = [String:String](),
                      body: Encodable? = [String:String](),
                      headers: [String: String] = [:]) -> EndPoint {
        return EndPoint(method: method, path: path, encoding: encoding, queryItems: queryItems, body: body, headers: headers)
    }

    struct ExampleBody: Encodable {
        let title: String
        let name: String
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
