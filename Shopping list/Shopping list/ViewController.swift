//
//  ViewController.swift
//  Shopping list
//
//  Created by TC on 12/12/2019.
//  Copyright © 2019 TC. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sList : [NSManagedObject] = []
   
    @IBOutlet weak var shoppingTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "myCell")
        let item = sList[indexPath.row]
        cell.textLabel!.text =  item.value(forKeyPath: "item") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
             if editingStyle == .delete {
                let item = sList[indexPath.row]
                deleteItem(item: item)
                sList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
         }
     }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      
      let managedContext = appDelegate.persistentContainer.viewContext
      
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Items")
      
      do {
        sList = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }

    @IBOutlet weak var item: UITextField!
    
    @IBAction func addButton(_ sender: Any) {
        if item.text != nil {
            let itemText = item.text!
            save(item: itemText)
            shoppingTable.reloadData()
        }
    }
    
    //saves items to core data
    func save(item: String) {
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
        
      let managedContext = appDelegate.persistentContainer.viewContext
      let entity = NSEntityDescription.entity(forEntityName: "Items", in: managedContext)!
      let itemList = NSManagedObject(entity: entity,insertInto: managedContext)
      itemList.setValue(item, forKeyPath: "item")
        
      do {
        try managedContext.save()
        sList.append(itemList)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func deleteItem(item: NSManagedObject) {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        let theItemName = item.value(forKey: "item") as! String
        fetchRequest.predicate = NSPredicate(format: "item == %@", theItemName)
        do {
            let fetched = try managedContext.fetch(fetchRequest)
            let itemToDelete = fetched[0] as! NSManagedObject
            managedContext.delete(itemToDelete)
            do {
                try managedContext.save()
            }
            catch {
                print("error")
            }
        }
        catch {
            print("error")
        }
    }
    
}
