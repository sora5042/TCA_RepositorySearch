//
//  APIClient.swift
//  TCA_RepositorySearch
//
//  Created by Sora Oya on 2025/05/05.
//

import Foundation

public protocol APIClient {
    var baseURL: String { get }
    var session: URLSessionProtocol { get }
    func response<Response: Decodable>(method: HTTPMethod, path: String?, parameters: Parameters?) async throws -> Response
}

public typealias Parameters = any Encodable

public extension APIClient {
    func createRequest(method: HTTPMethod, path: String? = nil, parameters: [String: Any]? = nil) -> URLRequest {
        let query = URLQueryBuilder(dictionary: parameters ?? [:]).build()

        var url = URL(string: baseURL)!
        if let path {
            url = url.appendingPathComponent(path)
        }
        if method == .get, !query.isEmpty {
            url = URL(string: url.absoluteString + "?" + query)!
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        if method != .get, !query.isEmpty {
            request.httpBody = query.data(using: .utf8)
        }

        return request
    }

    func data(method: HTTPMethod, path: String? = nil, parameters: Parameters? = nil) async throws -> Data {
        let dictionary = try parameters?.convertToDictionary() ?? [:]
        let request = createRequest(method: method, path: path, parameters: dictionary)
        return try await performRequest(request)
    }

    func performRequest(_ request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    return data
                case 401:
                    throw APIError.unauthorized(data)
                default:
                    throw APIError.data(data, httpResponse.statusCode)
                }
            } else {
                throw APIError.invalidResponse
            }
        } catch {
            switch error {
            case URLError.cancelled:
                throw APIError.cancelled
            default:
                throw error as? APIError ?? APIError.unknown(error)
            }
        }
    }
}

public extension APIClient {
    func response<Response: Decodable>(method: HTTPMethod, path: String?) async throws -> Response {
        try await response(method: method, path: path, parameters: nil)
    }
}

public extension Dictionary {
    static func + (lhs: Self, rhs: Self) -> Self {
        var new = lhs
        for element in rhs {
            new[element.key] = element.value
        }
        return new
    }
}
