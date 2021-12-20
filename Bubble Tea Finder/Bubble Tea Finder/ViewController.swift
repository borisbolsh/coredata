//
//  ViewController.swift
//  Bubble Tea Finder
//
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let filterViewControllerSegueIdentifier = "toFilterViewController"
    private let venueCellIdentifier = "VenueCell"
    
    var coreDataStack: CoreDataStack!
    var fetchRequest: NSFetchRequest<Venue>?
    var venues: [Venue] = []

    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == filterViewControllerSegueIdentifier {
            
        }
    }
}

// MARK: - IBActions
extension ViewController {
    
    @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: venueCellIdentifier, for: indexPath)
        cell.textLabel?.text = "Bubble Tea Venue"
        cell.detailTextLabel?.text = "Price Info"
        return cell
    }
}

// MARK: - Helper methods
extension ViewController {
  func fetchAndReload() {
    guard let fetchRequest = fetchRequest else {
      return
    }

    do {
      venues = try coreDataStack.managedContext.fetch(fetchRequest)
      tableView.reloadData()
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
}
