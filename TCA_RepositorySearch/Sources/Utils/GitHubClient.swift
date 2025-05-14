//
//  GitHubClient.swift
//  TCA_RepositorySearch
//
//  Created by Sora Oya on 2025/05/14.
//

import API
import Foundation

struct GitHubClient: APIClient {
    init(
        session: URLSessionProtocol = URLSession.shared
    ) {
        self.session = session
    }

    var baseURL: String = "https://api.github.com"
    var session: URLSessionProtocol
    private let decoder: JSONDecoder = .init()

    func data(method: HTTPMethod, path: String? = nil, parameters: Parameters? = nil) async throws -> Data {
        let dictionary = try (parameters?.convertToDictionary() ?? [:])
        var request = createRequest(method: method, path: path, parameters: dictionary)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        if let token = getGitHubToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.cancelled
        }

        return try await performRequest(request)
    }

    func response<Response: Decodable>(method: HTTPMethod, path: String?, parameters: Parameters?) async throws -> Response {
        do {
            let data = try await data(method: method, path: path, parameters: parameters)
            return try decode(data)
        } catch {
            throw error
        }
    }

    private func decode<Response: Decodable>(_ data: Data) throws -> Response {
        do {
            let decoded = try decoder.decode(Response.self, from: data)
            return decoded
        } catch {
            throw APIError.decodeError(data, error)
        }
    }

    func getGitHubToken() -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
              let token = dict["GitHubAPIToken"] as? String
        else {
            return nil
        }
        return token
    }
}
