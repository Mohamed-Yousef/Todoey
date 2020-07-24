import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    //referral to the class item's object
    var itemArray = [Item]()
    
    //creating selected category var to return the right todos for the selected category by the user, and to traverse from one vc to another and to use relation between CoreData Model queries
    //using did set to make it work iff Category gets a value
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    
    //UserDefaults - and persistent local data storage
    //let defaults = UserDefaults.standard
    
    /*  we dont need this bcuz we integrated the CoreData Model rather than using Filemanager & Codable.
    //CREATING A FILE PATH TO documents folder to avoid storing created and custom properties within the UserDefaults singleton class, as if we stored chuncks on data within UserDefaults that's considered as bad programming approach, rather than doing this we implement something called FileManager and it's also another singleton manipulating data but rather than saving it into memory registers and making axtra load errrtime we use the app that FileManager manipulates the storage of the phone, and all those things trigers some new Data Structures, and it's STANDARIZED,, NO MANUAL WORK FOR THE PROGRAMMER TO SEARCH USING THE EXPLORER TO TRACE FOLDERS AND DIRECTORIES
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    */
    

    //coreData code
    let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        //data retrieval using "encoder singleton"
        //decoding data with NsCoder
        //Loading and reading data within our CoreData Model
        //loadItems()
        
        
//         data retrieval from userDefaults into the tableview
//         if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//         itemArray = items
//        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        //to do checkmark & de-scheckmark CORRESPONDING TO THE NEW ITEM CLASS CHANGES (accessoryType) && instead of having five lines if and else we'll indicate the
        //tenary operator
        //value = condition ? valueIfTrue : valueIfFalse
        //if value meets the condition ? then switch between equivalent values
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //the D in CRUD CONCEPT WHICH IS DESTROY OR DELETE, and the order of writing those two lines matters a big deal as we can't delete backwards
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

        
        //to do checkmark & de-scheckmark CORRESPONDING TO THE NEW ITEM CLASS CHANGES (Logic)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //calling the "saveItems func" to show changes of the checkmark into the "Encoder plist"
        saveItems()
        
        
        //to de-highlight the selected row after selecting it
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    //MARK - ADD New Items
    //coded UI
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen when user clicks the add item button on our uialert
            
            //coreData code
            let newItem = Item(context: self.context)
            //coreData code ended
            
            newItem.title = textField.text!
            newItem.done = false    //must have a value as it's not an optional in our CoreData Model
            //parent categorization
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            //calling the func "saveItems"
            self.saveItems()
            
//            savig updated version of item array inserted by user :: RATHER THAN USING DEFAULTS, we'll implement our "encoder" to be suitable with our "FileManager" Singleton implemented
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")

        }
        
        // to create a textfield in the alert pop-up alert tap
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manipulation Methods
    
    /* that was the code when we was working within the codable {Encodable, NSencoder, Decodable}
     and that corresponded with a deleted model class representing the model blueprint before using coreData.
     
    //saving checkmark into our new "encoder-plist"
    func saveItems() {

        //implementing NSencoder, to work with implemeted Singleton "FileManager" used earlier
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error Encoding Item Array, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //implementing Nsdecoder, to work with implemeted Singleton "FileManager" used earlier
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error Decoding Item Array, \(error)")
            }
            
        }
        
    }
  */
    
    //CoreData Code
    //saving checkmark into our new CoreData Model
    func saveItems() {
        do {
            try context.save()
        } catch {
           print("Error Saving Context \(error)")
        }
        
        self.tableView.reloadData()
    }
    // the Read fn of the CRUD Concept {Create, Read, Update, Destroy}
    //the "with keyword infers an external parameter"
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil) {
        
        //filtering todos to match the category
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        //filter ended
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error Fetching Data From Context \(error)")
        }
        tableView.reloadData()
    }

}

//MARK: - SearchBar METHODS
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        /*translation of the coming line of code :
        NSPredicate : a querying class, A definition of logical conditions used to constrain a search either for a fetch or for in-memory filtering.
        - then we ask if what we got contains what we're asking for!! untill we get the correct result.
        - and the [CD] typed as this "NSPredicate" is Case Sensitive and we need to avoid this to avoid errors
        */
        let predicate = NSPredicate(format: "title CONTAINS[CD] %@", searchBar.text!)
        //sorting returned data from querying
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    //Delegate methods to manipulate Exiting the search bar after finding results "searchBar life cycle"
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            //going back from searching to the main thread "tableView"
            //working on threading with the main thread as we don't wanna our app to freeze meanwhile searching take place
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}




