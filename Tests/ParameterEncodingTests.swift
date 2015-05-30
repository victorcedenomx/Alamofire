// ParameterEncodingTests.swift
//
// Copyright (c) 2014–2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Alamofire
import Foundation
import XCTest

class ParameterEncodingTestCase: BaseTestCase {
    let URLRequest = NSURLRequest(URL: NSURL(string: "http://example.com/")!)
}

// MARK: -

/**
    The URL parameter encoding tests cover a variety of cases for encoding query parameters in addition to percent escaping reserved characters. The percent escaping implementation follows RFC 3986 - Sections 2.2, 2.4 and 3.4. All reserved characters are percent encoded with the exception of the "?" and "/" characters. This exception was made to allow other URIs to be included as query parameters without issue. See RFC 3986 - Section 3.4 for more details.
*/
class URLParameterEncodingTestCase: ParameterEncodingTestCase {
    // MARK: Properties

    let encoding: ParameterEncoding = .URL

    // MARK: Tests

    func testURLParameterEncodeNilParameters() {
        // Given
        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: nil)

        // Then
        XCTAssertNil(URLRequest.URL?.query, "query should be nil")
    }

    func testURLParameterEncodeOneStringKeyStringValueParameter() {
        // Given
        let parameters = ["foo": "bar"]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo=bar", "query is incorrect")
    }

    func testURLParameterEncodeOneStringKeyStringValueParameterAppendedToQuery() {
        // Given
        var mutableURLRequest = self.URLRequest.mutableCopy() as! NSMutableURLRequest
        let URLComponents = NSURLComponents(URL: mutableURLRequest.URL!, resolvingAgainstBaseURL: false)!
        URLComponents.query = "baz=qux"
        mutableURLRequest.URL = URLComponents.URL

        let parameters = ["foo": "bar"]

        // When
        let (URLRequest, error) = self.encoding.encode(mutableURLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "baz=qux&foo=bar", "query is incorrect")
    }

    func testURLParameterEncodeTwoStringKeyStringValueParameters() {
        // Given
        let parameters = ["foo": "bar", "baz": "qux"]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "baz=qux&foo=bar", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyIntegerValueParameter() {
        // Given
        let parameters = ["foo": 1]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyDoubleValueParameter() {
        // Given
        let parameters = ["foo": 1.1]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo=1.1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyBoolValueParameter() {
        // Given
        let parameters = ["foo": true]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyArrayValueParameter() {
        // Given
        let parameters = ["foo": ["a", 1, true]]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo%5B%5D=a&foo%5B%5D=1&foo%5B%5D=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyDictionaryValueParameter() {
        // Given
        let parameters = ["foo": ["bar": 1]]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo%5Bbar%5D=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyNestedDictionaryValueParameter() {
        // Given
        let parameters = ["foo": ["bar": ["baz": 1]]]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo%5Bbar%5D%5Bbaz%5D=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyNestedDictionaryArrayValueParameter() {
        // Given
        let parameters = ["foo": ["bar": ["baz": ["a", 1, true]]]]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo%5Bbar%5D%5Bbaz%5D%5B%5D=a&foo%5Bbar%5D%5Bbaz%5D%5B%5D=1&foo%5Bbar%5D%5Bbaz%5D%5B%5D=1", "query is incorrect")
    }

    func testURLParameterEncodeStringWithAmpersandKeyStringWithAmpersandValueParameter() {
        // Given
        let parameters = ["foo&bar": "baz&qux", "foobar": "bazqux"]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo%26bar=baz%26qux&foobar=bazqux", "query is incorrect")
    }

    func testURLParameterEncodeStringWithQuestionMarkKeyStringWithQuestionMarkValueParameter() {
        // Given
        let parameters = ["?foo?": "?bar?"]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "?foo?=?bar?", "query is incorrect")
    }

    func testURLParameterEncodeStringWithSlashKeyStringWithQuestionMarkValueParameter() {
        // Given
        let parameters = ["foo": "/bar/baz/qux"]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "foo=/bar/baz/qux", "query is incorrect")
    }

    func testURLParameterEncodeStringWithSpaceKeyStringWithSpaceValueParameter() {
        // Given
        let parameters = [" foo ": " bar "]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "%20foo%20=%20bar%20", "query is incorrect")
    }

    func testURLParameterEncodeStringWithPlusKeyStringWithPlusValueParameter() {
        // Given
        let parameters = ["+foo+": "+bar+"]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "%2Bfoo%2B=%2Bbar%2B", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyAllowedCharactersStringValueParameter() {
        // Given
        let parameters = ["allowed": " =\"#%<>@\\^`{}[]|&"]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "allowed=%20%3D%22%23%25%3C%3E%40%5C%5E%60%7B%7D%5B%5D%7C%26", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyPercentEncodedStringValueParameter() {
        // Given
        let parameters = ["percent": "%25"]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "percent=%2525", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyNonLatinStringValueParameter() {
        // Given
        let parameters = [
            "french": "français",
            "japanese": "日本語",
            "arabic": "العربية",
            "emoji": "😃"
        ]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "arabic=%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9&emoji=%F0%9F%98%83&french=fran%C3%A7ais&japanese=%E6%97%A5%E6%9C%AC%E8%AA%9E", "query is incorrect")
    }

    func testURLParameterEncodeStringForRequestWithPrecomposedQuery() {
        // Given
        let URL = NSURL(string: "http://example.com/movies?hd=[1]")!
        let parameters = ["page": "0"]

        // When
        let (URLRequest, error) = self.encoding.encode(NSURLRequest(URL: URL), parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "hd=%5B1%5D&page=0", "query is incorrect")
    }

    func testURLParameterEncodeStringWithPlusKeyStringWithPlusValueParameterForRequestWithPrecomposedQuery() {
        // Given
        let URL = NSURL(string: "http://example.com/movie?hd=[1]")!
        let parameters = ["+foo+": "+bar+"]

        // When
        let (URLRequest, error) = self.encoding.encode(NSURLRequest(URL: URL), parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "hd=%5B1%5D&%2Bfoo%2B=%2Bbar%2B", "query is incorrect")
    }

    func testURLParameterEncodeGETParametersInURL() {
        // Given
        var mutableURLRequest = self.URLRequest.mutableCopy() as! NSMutableURLRequest
        mutableURLRequest.HTTPMethod = Method.GET.rawValue
        let parameters = ["foo": 1, "bar": 2]

        // When
        let (URLRequest, error) = self.encoding.encode(mutableURLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.URL?.query ?? "", "bar=2&foo=1", "query is incorrect")
        XCTAssertNil(URLRequest.valueForHTTPHeaderField("Content-Type"), "Content-Type should be nil")
        XCTAssertNil(URLRequest.HTTPBody, "HTTPBody should be nil")
    }

    func testURLParameterEncodePOSTParametersInHTTPBody() {
        // Given
        var mutableURLRequest = self.URLRequest.mutableCopy() as! NSMutableURLRequest
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        let parameters = ["foo": 1, "bar": 2]

        // When
        let (URLRequest, error) = self.encoding.encode(mutableURLRequest, parameters: parameters)

        // Then
        XCTAssertEqual(URLRequest.valueForHTTPHeaderField("Content-Type") ?? "", "application/x-www-form-urlencoded", "Content-Type should be application/x-www-form-urlencoded")
        XCTAssertNotNil(URLRequest.HTTPBody, "HTTPBody should not be nil")

        if let HTTPBody = URLRequest.HTTPBody,
            decodedHTTPBody = NSString(data: HTTPBody, encoding: NSUTF8StringEncoding)
        {
            XCTAssertEqual(decodedHTTPBody, "bar=2&foo=1", "HTTPBody is incorrect")
        } else {
            XCTFail("decoded http body should not be nil")
        }
    }
}

// MARK: -

class JSONParameterEncodingTestCase: ParameterEncodingTestCase {
    // MARK: Properties

    let encoding: ParameterEncoding = .JSON

    // MARK: Tests

    func testJSONParameterEncodeNilParameters() {
        // Given
        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: nil)

        // Then
        XCTAssertNil(error, "error should be nil")
        XCTAssertNil(URLRequest.URL?.query, "query should be nil")
        XCTAssertNil(URLRequest.valueForHTTPHeaderField("Content-Type"), "Content-Type should be nil")
        XCTAssertNil(URLRequest.HTTPBody, "HTTPBody should be nil")
    }

    func testJSONParameterEncodeComplexParameters() {
        // Given
        let parameters = [
            "foo": "bar",
            "baz": ["a", 1, true],
            "qux": [
                "a": 1,
                "b": [2, 2],
                "c": [3, 3, 3]
            ]
        ]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertNil(error, "error should be nil")
        XCTAssertNil(URLRequest.URL?.query, "query should be nil")
        XCTAssertNotNil(URLRequest.valueForHTTPHeaderField("Content-Type"), "Content-Type should not be nil")
        XCTAssertEqual(URLRequest.valueForHTTPHeaderField("Content-Type") ?? "", "application/json", "Content-Type should be application/json")
        XCTAssertNotNil(URLRequest.HTTPBody, "HTTPBody should not be nil")

        if let HTTPBody = URLRequest.HTTPBody,
            JSON = NSJSONSerialization.JSONObjectWithData(HTTPBody, options: .AllowFragments, error: nil) as? NSObject
        {
            XCTAssertEqual(JSON, parameters as NSObject, "HTTPBody JSON does not equal parameters")
        } else {
            XCTFail("JSON should not be nil")
        }
    }
}

// MARK: -

class PropertyListParameterEncodingTestCase: ParameterEncodingTestCase {
    // MARK: Properties

    let encoding: ParameterEncoding = .PropertyList(.XMLFormat_v1_0, 0)

    // MARK: Tests

    func testPropertyListParameterEncodeNilParameters() {
        // Given
        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: nil)

        // Then
        XCTAssertNil(error, "error should be nil")
        XCTAssertNil(URLRequest.URL?.query, "query should be nil")
        XCTAssertNil(URLRequest.valueForHTTPHeaderField("Content-Type"), "Content-Type should be nil")
        XCTAssertNil(URLRequest.HTTPBody, "HTTPBody should be nil")
    }

    func testPropertyListParameterEncodeComplexParameters() {
        // Given
        let parameters = [
            "foo": "bar",
            "baz": ["a", 1, true],
            "qux": [
                "a": 1,
                "b": [2, 2],
                "c": [3, 3, 3]
            ]
        ]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertNil(error, "error should be nil")
        XCTAssertNil(URLRequest.URL?.query, "query should be nil")
        XCTAssertNotNil(URLRequest.valueForHTTPHeaderField("Content-Type"), "Content-Type should not be nil")
        XCTAssertEqual(URLRequest.valueForHTTPHeaderField("Content-Type") ?? "", "application/x-plist", "Content-Type should be application/x-plist")
        XCTAssertNotNil(URLRequest.HTTPBody, "HTTPBody should not be nil")

        if let HTTPBody = URLRequest.HTTPBody,
            let plist = NSPropertyListSerialization.propertyListWithData(HTTPBody, options: 0, format: nil, error: nil) as? NSObject
        {
            XCTAssertEqual(plist, parameters as NSObject, "HTTPBody plist does not equal parameters")
        } else {
            XCTFail("plist should not be nil")
        }
    }

    func testPropertyListParameterEncodeDateAndDataParameters() {
        // Given
        let date: NSDate = NSDate()
        let data: NSData = "data".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

        let parameters = [
            "date": date,
            "data": data
        ]

        // When
        let (URLRequest, error) = self.encoding.encode(self.URLRequest, parameters: parameters)

        // Then
        XCTAssertNil(error, "error should be nil")
        XCTAssertNil(URLRequest.URL?.query, "query should be nil")
        XCTAssertNotNil(URLRequest.valueForHTTPHeaderField("Content-Type"), "Content-Type should not be nil")
        XCTAssertEqual(URLRequest.valueForHTTPHeaderField("Content-Type") ?? "", "application/x-plist", "Content-Type should be application/x-plist")
        XCTAssertNotNil(URLRequest.HTTPBody, "HTTPBody should not be nil")

        if let HTTPBody = URLRequest.HTTPBody,
            let plist = NSPropertyListSerialization.propertyListWithData(HTTPBody, options: 0, format: nil, error: nil) as? NSObject
        {
            XCTAssertTrue(plist.valueForKey("date") is NSDate, "date is not NSDate")
            XCTAssertTrue(plist.valueForKey("data") is NSData, "data is not NSData")
        } else {
            XCTFail("plist should not be nil")
        }
    }
}

// MARK: -

class CustomParameterEncodingTestCase: ParameterEncodingTestCase {
    // MARK: Tests

    func testCustomParameterEncode() {
        // Given
        let encodingClosure: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = { URLRequest, parameters in
            let mutableURLRequest = URLRequest.URLRequest.mutableCopy() as! NSMutableURLRequest
            mutableURLRequest.setValue("Xcode", forHTTPHeaderField: "User-Agent")
            return (mutableURLRequest, nil)
        }

        // When
        let encoding: ParameterEncoding = .Custom(encodingClosure)

        // Then
        let URL = NSURL(string: "http://example.com")!
        let URLRequest = NSURLRequest(URL: URL)
        let parameters: [String: AnyObject] = [:]

        XCTAssertEqual(encoding.encode(URLRequest, parameters: parameters).0, encodingClosure(URLRequest, parameters).0, "URLRequest should be equal")
    }
}
