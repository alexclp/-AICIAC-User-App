//
//  DestinationsViewController.swift
//  [AICIAC]User-App
//
//  Created by Alexandru Clapa on 05/03/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import UIKit

class DestinationsViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	
	var rooms = [Room]()
	var filteredRooms = [Room]()
	let searchController = UISearchController(searchResultsController: nil)
	
    override func viewDidLoad() {
        super.viewDidLoad()

        searchForRooms(query: "")
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Destinations"
		navigationItem.searchController = searchController
		definesPresentationContext = true
    }
	
	func searchForRooms(query: String) {
		SearchHelper.shared.searchRoom(query: query) { (response, json) in
			if response == true {
				guard let json = json else { return }
				self.rooms = json
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
	}
	
	// MARK: - Private instance methods
	
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredRooms = rooms.filter({ (room) -> Bool in
			return room.name.lowercased().contains(searchText.lowercased())
		})
		
		tableView.reloadData()
	}
	
	func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
}

extension DestinationsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)
		let room: Room
		if isFiltering() {
			room = filteredRooms[indexPath.row]
		} else {
			room = rooms[indexPath.row]
		}
		cell.textLabel?.text = room.name
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isFiltering() {
			return filteredRooms.count
		}
		return rooms.count
	}
}

extension DestinationsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension DestinationsViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
}
