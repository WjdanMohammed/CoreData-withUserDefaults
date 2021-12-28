//
//  ViewController.swift
//  CoreDataWithUserDefaults_Practice
//
//  Created by WjdanMo on 26/11/2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var listItemArray = [List]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadData()
        
        if defaults.bool(forKey: "SwitchState") != false {
            updateSwitch(value: defaults.bool(forKey: "SwitchState") )
        } else {
            updateSwitch(value: false)
            print(defaults.bool(forKey: "SwitchState"))
        }
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Create New ListItem", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem = List(context: self.context)
            
            newItem.name = textField.text
            self.listItemArray.append(newItem)
            self.saveData()
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Item Here"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func darkModeSwitchAction(_ sender: UISwitch) {
        updateSwitch(value: sender.isOn)
    }
    
}

extension ViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text?.isEmpty == true {
            let alert = UIAlertController(title: "Note", message: "Please enter something", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default , handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            loadData()
        }
        
        else{
            print(searchBar.text!)
            let request = List.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
            
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            do {
                listItemArray = try context.fetch(request)
            } catch {
                print("Error loading data \(error)")
            }
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadData()
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = listItemArray[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Change item Name", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Update Item", style: .default) { (action) in
            self.listItemArray[indexPath.row].setValue(textField.text, forKey: "name")
            self.saveData()
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Item Here"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

            context.delete(listItemArray[indexPath.row])
            listItemArray.remove(at: indexPath.row)
            saveData()
        }
        else if (editingStyle == .none){
            
        }
    }
}


extension ViewController {
    
    func updateSwitch(value : Bool){
        if value {
            defaults.set(true, forKey: "SwitchState")
            overrideUserInterfaceStyle = .dark
            darkModeSwitch.isOn = true
        } else {
            defaults.set(false, forKey: "SwitchState")
            overrideUserInterfaceStyle = .light
            darkModeSwitch.isOn = false
        }
        
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        
        let request : NSFetchRequest<List> = List.fetchRequest()
        
        do {
            listItemArray = try context.fetch(request)
        } catch {
            print("Error loading data \(error)")
        }
        tableView.reloadData()
    }
}
