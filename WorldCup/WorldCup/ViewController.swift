//
//  ViewController.swift
//  WorldCup
//
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Properties
    fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
    var coreDataStack: CoreDataStack!
        
    lazy var fetchedResultsController: NSFetchedResultsController<Team> = {
        // 1
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
        let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
        let nameSort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
        fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort]
        
        // 2
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Team.qualifyingZone),
            cacheName: "worldCup")
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
           try fetchedResultsController.performFetch()
        } catch let error as NSError {
           print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
           if motion == .motionShake {
               addButton.isEnabled = true
           }
       }
}

// MARK: - IBActions
extension ViewController {
    @IBAction func addTeam(_ sender: Any) {
        let alertController = UIAlertController(title: "Секретная команда", message: "Добавить новую команду", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Название команды"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Квалификационная зона"
        }
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [unowned self] action in
            guard let nameTextField = alertController.textFields?.first,
                let zoneTextField = alertController.textFields?.last else {
                    return
            }
            
            let team = Team(context: self.coreDataStack.managedContext)
            team.teamName = nameTextField.text
            team.qualifyingZone = zoneTextField.text
            team.imageName = "swiftlab-flag"
            
            self.coreDataStack.saveContext()
        }
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alertController, animated: true)
    }
}

// MARK: - Internal
extension ViewController {
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
       guard let cell = cell as? TeamCell else {
                   return
               }
               
       let team = fetchedResultsController.object(at: indexPath)
       cell.teamLabel.text = team.teamName
       cell.scoreLabel.text = "Побед: \(team.wins)"
       
       if let imageName = team.imageName {
           cell.flagImageView.image = UIImage(named: imageName)
       } else {
           cell.flagImageView.image = nil
       }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
                   return 0
               }
               
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
        configure(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           let sectionInfo = fetchedResultsController.sections?[section]
           return sectionInfo?.name
       }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let team = fetchedResultsController.object(at: indexPath)
             team.wins = team.wins + 1
             coreDataStack.saveContext()
             
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
            configure(cell: cell, for: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }
}
