//
//  APIEndpoint.swift
//  TCA_RepositorySearch
//
//  Created by Sora Oya on 2025/05/05.
//

import Foundation

public protocol APIEndpoint {
    var apiClient: APIClient { get }
    var path: String { get }
}
