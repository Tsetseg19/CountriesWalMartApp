//
//  MockNetworkManager.swift
//  WallMartUIkit
//
//  Created by Enkhtsetseg Unurbayar on 3/18/25.
//

import Foundation
@testable import CountriesWalMartApp
import Combine

final class MockNetworkServiceManager: NetworkingService {
    var mockData: Data?
    var mockError: Error?
    
    func fetchDataFromAPI<T: Decodable>(from url: URL) -> AnyPublisher<T, Error> {
        // Check if we should return an error
        if let error = mockError {
            return Fail(error: error)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        // Check if we have mock data to return
        if let data = mockData {
            return Just(data)
                .tryMap { mockData -> T in
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: mockData)
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        // If neither error nor data is provided, fall back to the actual network request
        if let path = Bundle(for: type(of: self)).url(forResource: url.absoluteString, withExtension: "json") {
            do {
                let data = try Data(contentsOf: path)
                let jsonDecoder = JSONDecoder()
                let jsonModel = try jsonDecoder.decode(T.self, from: data)
                return Just(jsonModel)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        return Fail(error: NetworkServiceError.noData)
            .eraseToAnyPublisher()
    }
}
extension MockNetworkServiceManager{
    func getMockData(fileName: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: "json"),
              let jsonData = try? Data(contentsOf: url) else {
            return nil
        }
        return jsonData
    }
}
