//
//  ViewController.swift
//  Bubble Tea Finder
//
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let filterViewControllerSegueIdentifier = "toFilterViewController"
    private let venueCellIdentifier = "VenueCell"
    
    var coreDataStack: CoreDataStack!
    var fetchRequest: NSFetchRequest<Venue>?
    var venues: [Venue] = []
    
    var asyncFetchRequest: NSAsynchronousFetchRequest<Venue>?
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let batchUpdate = NSBatchUpdateRequest(entityName: "Venue")
        batchUpdate.propertiesToUpdate = [#keyPath(Venue.favorite): true]
        batchUpdate.affectedStores = coreDataStack.managedContext.persistentStoreCoordinator?.persistentStores
        batchUpdate.resultType = .updatedObjectsCountResultType
        
        do {
            let batchResult = try coreDataStack.managedContext.execute(batchUpdate) as? NSBatchUpdateResult
            print("Records updated \(String(describing: batchResult?.result))")
        } catch let error as NSError {
            print("Could not update \(error), \(error.userInfo)")
        }
        
        let venueFetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
        fetchRequest = venueFetchRequest
        
        asyncFetchRequest = NSAsynchronousFetchRequest<Venue>(
            fetchRequest: venueFetchRequest
        ) { [unowned self] result in
            guard let venues = result.finalResult else {
                return
            }
            
            self.venues = venues
            self.tableView.reloadData()
        }
        
        do {
            guard let asyncFetchRequest = asyncFetchRequest else {
                return
            }
            try coreDataStack.managedContext.execute(asyncFetchRequest)
            // Returns immediately, cancel here if you want
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == filterViewControllerSegueIdentifier,
              let navController = segue.destination as? UINavigationController,
              let filterVC = navController.topViewController as? FilterViewController else {
                  return
              }
        
        filterVC.coreDataStack = coreDataStack
        filterVC.delegate = self
    }
    
}



// MARK: - IBActions
extension ViewController {
    
    @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
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

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: venueCellIdentifier, for: indexPath)
        
        let venue = venues[indexPath.row]
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
        return cell
    }
}

// MARK: - FilterViewControllerDelegate
extension ViewController: FilterViewControllerDelegate {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
        guard let fetchRequest = fetchRequest else {
            return
        }
        
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = nil
        fetchRequest.predicate = predicate
        
        if let sort = sortDescriptor {
            fetchRequest.sortDescriptors = [sort]
        }
        
        fetchAndReload()
    }
}
