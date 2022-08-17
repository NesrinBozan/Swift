//
//  DetailsViewController.swift
//  ShopList
//
//  Created by Nesrin Bozan on 2.08.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    
    var selectedProductName = ""
    var selectedProductId: UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedProductName != "" {
            addButton.isHidden = true//
            // Core Data seçilen ürün bilgilerini göster
            
            if let uuidString = selectedProductId?.uuidString{ // Opsiyonelden çıkarıp string olarak alma
              
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
                
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString) //NSPredicate sınırlar verilecek ve arama ona göre yapılacak, id si şuna eşit olanları getir
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0 {
                        for result in results  as! [NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String {
                                nameTextField.text = name
                                
                            }
                            if let price = result.value(forKey: "price") as? Int{
                                priceTextField.text = String(price)
                            }
                            if let size = result.value(forKey: "size") as? String{
                                sizeTextField.text = size
                            }
                            if let imageData = result.value(forKey: "image") as? Data{
                                let image = UIImage(data: imageData) // UIimage e çevirme
                                imageView.image = image
                            }
                        }
                    }
                }catch{
                print("Hata var")
            }
            
        }else{
            addButton.isHidden = false
            addButton.isEnabled = false
            nameTextField.text = ""
            priceTextField.text = ""
            sizeTextField.text = ""
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closedKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        }}
    
    @objc func selectImage (){
    
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        addButton.isEnabled = true // Ne zamanki görsel seçilir kaydet butonu görünür olacak
        self.dismiss(animated: true)
    }
    @objc func closedKeyboard(){
        
        view.endEditing(true)
    }
    @IBAction func addButton(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let listItem = NSEntityDescription.insertNewObject(forEntityName:"ListItem" , into: context)
        
        listItem.setValue(nameTextField.text!, forKey: "name")
        
        if let price = Int(priceTextField.text!){
            listItem.setValue(price, forKey: "price")}
            
            listItem.setValue(UUID(), forKey: "id")
            
            let data = imageView.image!.jpegData(compressionQuality: 0.5)
            
            
            listItem.setValue(data, forKey: "image")
            
        
        
       
            do{
                try context.save()
            }catch{
                print("Hata var")
            }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VeriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
