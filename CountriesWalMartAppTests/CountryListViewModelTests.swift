//
//  CountryListViewModelTests.swift
//  WallMartUIkit
//
//  Created by Enkhtsetseg Unurbayar on 4/22/25.
//

import Combine
import XCTest
@testable import CountriesWalMartApp

final class CountryListViewModelTests: XCTestCase {
    
    var viewModel: CountriesViewModel!
    var mockNetworkManager: MockNetworkServiceManager!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkServiceManager()
        viewModel = CountriesViewModel(networkService: mockNetworkManager)
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        mockNetworkManager = nil
        cancellables.removeAll()
    }
    
    func testFetchCountriesSuccess() {
        
        //Given
        // Load the mock data
        if let jsonData = mockNetworkManager.getMockData(fileName: "MockData"){
            mockNetworkManager.mockData = jsonData
        }
        
        
        let expectation = self.expectation(description: "Fetch countries success")
        
        //when
        viewModel.fetchCountries()
        
        viewModel.$filteredCountries
            .dropFirst()
            .sink { countries in
                if countries.count == 2 {
                    //then
                    XCTAssertEqual(countries[0].name, "Afghanistan")
                    XCTAssertEqual(countries[1].name, "Albania")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchCountriesFailure() {
        
        //Given
        mockNetworkManager.mockError = NetworkServiceError.noData
        
        let expectation = self.expectation(description: "Fetch countries failure")
        
        //when
        viewModel.fetchCountries()

        viewModel.$errormessage
            .dropFirst()
            .sink { error in
                //then
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error, NetworkServiceError.noData)

                    expectation.fulfill()
            }
            .store(in: &cancellables)
        
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchCountriesFailureForParsingIssue() {
        
        //Given
        // Load the mock data
        if let jsonData = mockNetworkManager.getMockData(fileName: "MockDataParsingIssue"){
            mockNetworkManager.mockData = jsonData
        }
        
        let expectation = self.expectation(description: "Fetch countries failure with decoding eror")
        
        //when
        viewModel.fetchCountries()
        
        viewModel.$errormessage
            .dropFirst()
            .sink { error in
                //then
                XCTAssertNotNil(error)
                XCTAssertEqual(error, NetworkServiceError.decodingFailed)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchCountriesFailureForIFUrlSessionFailed() {
        
        //Given
        mockNetworkManager.mockError = NetworkServiceError.urlSessionFailed
        
        let expectation = self.expectation(description: "Fetch countries failure with urlSessionFailed eror")
        
        //when
        viewModel.fetchCountries()
        
        viewModel.$errormessage
            .dropFirst()
            .sink { error in
                //then
                XCTAssertNotNil(error)
                XCTAssertEqual(error, NetworkServiceError.urlSessionFailed)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFilterCountriesWithCapitalSearch() {
        
        //Given
        // Load the mock data
        if let jsonData = mockNetworkManager.getMockData(fileName: "MockData"){
            mockNetworkManager.mockData = jsonData
        }
        
        
        let expectation = self.expectation(description: "Filter countries")
        
        
        //when
        viewModel.fetchCountries()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        //Then
            self.viewModel.filterCountries(searchText: "Tir")
           
            XCTAssertEqual(self.viewModel.filteredCountries.count, 1)
            XCTAssertEqual(self.viewModel.filteredCountries[0].name, "Albania")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
