//
//  NetworkServiceManager.swift
//  CountriesWalMartApp
//
//  Created by Enkhtsetseg Unurbayar on 4/22/25.
//

import Foundation
import Combine

class NetworkServiceManager : NetworkingService{
    
    func fetchDataFromAPI<T: Decodable>(from url: URL) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap{result -> Data in
                guard let response = result.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return result.data
                
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
}
