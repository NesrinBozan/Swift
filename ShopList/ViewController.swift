//
//  ViewController.swift
//  ShopList
//
//  Created by Nesrin Bozan on 2.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedName = ""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:
                                                                                            UIBarButtonItem.SystemItem.add, target: self, action: #selector(tappedAddButton))
    
    getAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector (getAll) , name: "VeriGirildi", object: nil)
    }
    
   @objc func getAll(){
       
       //Dizileri boşalttıktan sonra verileri silme işlemi yapılacak. İki kere gelme işlemi kontrol edilmiş olacak
       nameArray.removeAll(keepingCapacity: false)
       idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext // context e erişim
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem") //
        fetchRequest.returnsObjectsAsFaults = false // Birçok veri ile çalışırken caching mekanizmasından faydalanmak için kullnaıldı.
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in  results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idArray.append(id)
                    }
                }
                tableView.reloadData()
            }
            
       
            
        }catch{
            print("Hata var")
            
        }
        
    }
    
    @objc func tappedAddButton(){
        selectedName = ""
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            // Veri aktarmış oluyoruz.
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectedProductName = selectedName
            destinationVC.selectedProductId = selectedId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedName = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    func tableview (_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            
            let appDeletage = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDeletage.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
            
            let uuidString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString )
            
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                }catch{
                                    
                                }
                                break
                        }
                    }
                }
                
                }
                
            }catch{
                print("Hata")
                
            }
        }
    }
}

