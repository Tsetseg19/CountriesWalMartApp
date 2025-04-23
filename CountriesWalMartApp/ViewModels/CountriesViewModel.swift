//
//  CountriesViewModels.swift
//  CountriesWalMartApp
//
//  Created by Enkhtsetseg Unurbayar on 4/22/25.
//

import Foundation
import UIKit
import Combine


final class CountriesViewModel {

    private var countries: [Country] = []
    private var cancellables: Set<AnyCancellable> = []  // Store subscriptions to manage lifecycle
    
    @Published var filteredCountries: [Country] = []
    @Published var errormessage: NetworkServiceError?
    
    private let networkService: NetworkingService
    
    init(networkService: NetworkingService){
        self.networkService = networkService
        
    }
    
    func fetchCountries() {
        
        guard let url = URL(string: URLConstant.contriesURL) else {
            self.errormessage = .noData
            return
        }
        networkService.fetchDataFromAPI(from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:{completion in
                switch completion {
                case .failure(let error):
                    switch error{
                    case is DecodingError:
                        self.errormessage = .decodingFailed
                    case is URLError:
                        self.errormessage = .urlSessionFailed
                    case NetworkServiceError.urlSessionFailed:
                        self.errormessage = .urlSessionFailed
                    case NetworkServiceError.decodingFailed:
                        self.errormessage = .decodingFailed
                    case NetworkServiceError.noData:
                        self.errormessage = .noData
                    default:
                        self.errormessage = .noData
                    }
            
                case .finished:
                    break
                }
            }, receiveValue:{ (countires: [Country]) in
                self.countries = countires
                self.filteredCountries = countires
            })
            .store(in: &cancellables)
    }
    
    func filterCountries(searchText: String){
        if searchText.isEmpty {
            filteredCountries = countries
        } else {
            filteredCountries = countries.filter{
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.capital.lowercased().contains(searchText.lowercased())
            }
        }
        
    }
    
}
