//
//  NetworkError.swift
//  CountriesWalMartApp
//
//  Created by Enkhtsetseg Unurbayar on 4/22/25.
//

import Foundation

enum NetworkServiceError: Error {
    case noData
    case decodingFailed
    case urlSessionFailed
}

extension NetworkServiceError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "No data returned from the server."
        case .decodingFailed:
            return "Failed to decode the data returned from the server."
        case .urlSessionFailed:
            return "Failed to perform the URLSession task."
        }
    }
}
