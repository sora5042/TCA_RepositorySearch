//
//  URLSessionProtocol.swift
//  TCA_RepositorySearch
//
//  Created by Sora Oya on 2025/05/05.
//

import Foundation

public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
