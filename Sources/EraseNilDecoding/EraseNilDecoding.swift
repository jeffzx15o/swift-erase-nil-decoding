//
//  Copyright (c) 2022 Junfeng Zhang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public protocol EraseNilDecodable {
    
    associatedtype ErasedValue: Decodable
    
    static var erasedValue: ErasedValue { get }
}

@propertyWrapper
public struct EraseNilDecoding<Wrapped: EraseNilDecodable> {
    
    public typealias Value = Wrapped.ErasedValue
    
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension EraseNilDecoding: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension EraseNilDecoding: Encodable where Value: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {
    
    public func decode<T>(_ type: EraseNilDecoding<T>.Type,
                          forKey key: Key) throws -> EraseNilDecoding<T> {
        try decodeIfPresent(type, forKey: key) ?? .init(wrappedValue: T.erasedValue)
    }
}

extension EraseNilDecoding: Equatable where Value: Equatable {}

extension EraseNilDecoding: Hashable where Value: Hashable {}
