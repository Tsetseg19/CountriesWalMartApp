//
//  CountriesTableViewController.swift
//  CountriesWalMartApp
//
//  Created by Enkhtsetseg Unurbayar on 4/22/25.
//

import UIKit
import Combine

final class CountriesTableViewController : UIViewController {
    
    
    private let tableView =  UITableView()
    private let searchController = UISearchController()
    private var viewModel: CountriesViewModel!
    private var cancelables : Set<AnyCancellable> = []
    
    init(viewModel: CountriesViewModel){
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUIToData()
        viewModel.fetchCountries()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Countries"
        
        tableView.register(CountriesTabelViewCell.self, forCellReuseIdentifier: CountriesTabelViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Name or Capital"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    
    func bindUIToData() {
        // Subscribe to filteredCountries changes
        viewModel.$filteredCountries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Reload table view when filteredCountries is updated
                self?.tableView.reloadData()
            }
            .store(in: &cancelables)
        
        viewModel.$errormessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.viewModel.errormessage != nil{
                    // displaying error message in alert if occured
                    self?.displayErrorMessage()
                }
            }
            .store(in: &cancelables)
    }
    
    func displayErrorMessage(){
        print(viewModel.errormessage?.localizedDescription ?? "Failed to get data from API")
        let alert = UIAlertController(title: "Error",
                                      message: viewModel.errormessage?.localizedDescription ?? "Failed to get data from API",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
extension CountriesTableViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountriesTabelViewCell.reuseIdentifier, for: indexPath) as? CountriesTabelViewCell else {
            return UITableViewCell()
        }
        let country = viewModel.filteredCountries[indexPath.row]
        cell.configure(with: country)
        return cell
    }
    
}

extension CountriesTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        viewModel.filterCountries(searchText: searchText)
    }
}
