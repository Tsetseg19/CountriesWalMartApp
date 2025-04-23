//
//  NetworkProtocol.swift
//  CountriesWalMartApp
//
//  Created by Enkhtsetseg Unurbayar on 4/22/25.
//

import Foundation
import Combine

protocol NetworkingService {
    
    func fetchDataFromAPI<T: Decodable>(from url: URL) -> AnyPublisher<T, Error>
    
}

