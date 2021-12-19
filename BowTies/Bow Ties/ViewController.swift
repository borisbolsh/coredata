//
//  ViewController.swift
//  Bow Ties
//
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    var managedContext: NSManagedObjectContext!
    var currentBowTie: Bowtie!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        insertSampleData()

        let request: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
        let firstTitle = segmentedControl.titleForSegment(at: 0) ?? ""
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Bowtie.searchKey), firstTitle])

        do {
          let results = try managedContext.fetch(request)
          if let tie = results.first {
            currentBowTie = tie
            populate(bowtie: tie)
          }
        } catch let error as NSError {
          print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - IBActions
    @IBAction func segmentedControl(_ sender: Any) {
        guard let control = sender as? UISegmentedControl,
              let selectedValue = control.titleForSegment(at: control.selectedSegmentIndex) else {
                  return
              }
                
        let request: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Bowtie.searchKey), selectedValue])

        do {
          let results = try managedContext.fetch(request)
          currentBowTie = results.first
          populate(bowtie: currentBowTie)
        } catch let error as NSError {
          print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func wear(_ sender: Any) {
        currentBowTie.timesWorn += 1
        currentBowTie.lastWorn = Date()

        do {
          try managedContext.save()
          populate(bowtie: currentBowTie)
        } catch let error as NSError {
          print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func rate(_ sender: Any) {
        let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .alert)

            alert.addTextField { textField in
              textField.keyboardType = .decimalPad
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            let saveAction = UIAlertAction(
              title: "Save",
              style: .default
            ) { [unowned self] _ in
              if let textField = alert.textFields?.first {
                self.update(rating: textField.text)
              }
            }

            alert.addAction(cancelAction)
            alert.addAction(saveAction)

            present(alert, animated: true)
    }
    
    func insertSampleData() {
      let fetch: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
      fetch.predicate = NSPredicate(format: "searchKey != nil")

      let tieCount = (try? managedContext.count(for: fetch)) ?? 0

      if tieCount > 0 {
        // SampleData.plist data already in Core Data
        return
      }
      let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
      let dataArray = NSArray(contentsOfFile: path!)!

      for dict in dataArray {
        let entity = NSEntityDescription.entity(forEntityName: "Bowtie", in: managedContext)!
        let bowtie = Bowtie(entity: entity, insertInto: managedContext)
        let btDict = dict as! [String: Any]

        bowtie.id = UUID(uuidString: btDict["id"] as! String)
        bowtie.name = btDict["name"] as? String
        bowtie.searchKey = btDict["searchKey"] as? String
        bowtie.rating = btDict["rating"] as! Double
        let colorDict = btDict["tintColor"] as! [String: Any]
        bowtie.tintColor = UIColor.color(dict: colorDict)

        let imageName = btDict["imageName"] as? String
        let image = UIImage(named: imageName!)
        bowtie.photoData = image?.pngData()
        bowtie.lastWorn = btDict["lastWorn"] as? Date

        let timesNumber = btDict["timesWorn"] as! NSNumber
        bowtie.timesWorn = timesNumber.int32Value
        bowtie.isFavorite = btDict["isFavorite"] as! Bool
        bowtie.url = URL(string: btDict["url"] as! String)
      }
      try? managedContext.save()
    }
    
    func populate(bowtie: Bowtie) {
       guard
         let imageData = bowtie.photoData as Data?,
         let lastWorn = bowtie.lastWorn as Date?,
         let tintColor = bowtie.tintColor else {
         return
       }

       imageView.image = UIImage(data: imageData)
       nameLabel.text = bowtie.name
       ratingLabel.text = "Rating: \(bowtie.rating)/5"

       timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"

       let dateFormatter = DateFormatter()
       dateFormatter.dateStyle = .short
       dateFormatter.timeStyle = .none

       lastWornLabel.text =
         "Last worn: " + dateFormatter.string(from: lastWorn)

       favoriteLabel.isHidden = !bowtie.isFavorite
        view.tintColor = tintColor as? UIColor
     }

     func update(rating: String?) {
       guard
         let ratingString = rating,
         let rating = Double(ratingString) else {
         return
       }

       do {
         currentBowTie.rating = rating
         try managedContext.save()
         populate(bowtie: currentBowTie)
       } catch let error as NSError {
           if error.domain == NSCocoaErrorDomain &&
             (error.code == NSValidationNumberTooLargeError ||
             error.code == NSValidationNumberTooSmallError) {
             rate(currentBowTie)
           } else {
             print("Could not save \(error), \(error.userInfo)")
           }
         }
     }
}

