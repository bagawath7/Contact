

import UIKit
import CoreData

protocol ContactDisplayLogic:AnyObject
{
    func updateContacts(contacts:[NSManagedObject],contactsDictArray:[Dictionary<Character, [NSManagedObject]>.Element])
}

class ContactViewController: UITableViewController, ContactDisplayLogic, UISearchResultsUpdating, AddContactViewControllerDelegate
{
    func updateContacts(contacts: [NSManagedObject], contactsDictArray: [Dictionary<Character, [NSManagedObject]>.Element]) {
        self.contacts = contacts
        self.contactsDictArray = contactsDictArray
    }
    
    func didFinishAddingContact() {
        self.interactor?.fetchContacts()
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(){
            filteredcontacts = contacts.filter({ ( $0.value(forKey: "fullname") as! String).lowercased().contains(searchText)
            })
        }
        print(filteredcontacts)
        self.tableView.reloadData()
    }
    
    var interactor: ContactBusinessLogic?
    private var inSearchMode:Bool{
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    var filteredcontacts:[NSManagedObject] = []
    var contacts:[NSManagedObject] = []
    var contactsDictArray = [Dictionary<Character, [NSManagedObject]>.Element]()
    
    


    
    private let searchController = UISearchController(searchResultsController: nil)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad()
    {
        
        
      super.viewDidLoad()
      setup()
      configureUI()
      self.interactor?.fetchContacts()
    }

  
  // MARK: Setup
  
  private func setup()
  {
    let viewController = self
    let interactor = ContactInteractor()
    let presenter = ContactPresenter()
    viewController.interactor = interactor
    interactor.presenter = presenter
    presenter.viewController = viewController
      
    tableView.register(ContactCell.self, forCellReuseIdentifier: "cell")
    tableView.rowHeight = 60
      
    
      
  }
    
    func fetchContacts(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactInfo")
        do{
            let result = try? context.fetch(fetchRequest)
            contacts = result as! [NSManagedObject]
            
            var contactsDict:[Character:[NSManagedObject]] = [:]
            for cont in contacts {
             let name = cont.value(forKey: "fullname") as! String
             let char = name[name.index(name.startIndex, offsetBy: 0)]
                if let _ = contactsDict[char] {
                    contactsDict[char]?.append(cont)
                    
                }
                else{
                    contactsDict[char] = [cont]
                }
            }
            var dict = contactsDict.sorted ( by: { $0.0 < $1.0 })
             dict = dict.filter { (key,value) in
                !value.isEmpty
            }
            self.contactsDictArray = dict
            }
            

            
            
        }
    
    

    private func configureUI(){
        
        self.title = "Contact"
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addContact))
        
        
 
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .black
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    
    @objc func addContact(){
       
        let vc = AddContactViewController()
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.tintColor = .black
        
        present(navController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let vc = AddContactViewController()
        vc.delegate = self
        
        let contact = inSearchMode ? filteredcontacts[indexPath.row] : contactsDictArray[indexPath.section].value[indexPath.row]
        
        
        vc.fullnameTextfield.text = contact.value(forKey: "fullname") as? String
        vc.mobileNumberTextField.text = contact.value(forKey: "mobileNumber") as? String
        
        vc.updateContact = contact
        
        vc.plushPhotoButton.setImage(UIImage(data: contact.value(forKey: "image") as! Data)?.roundedImage, for: .normal)
        
        present(UINavigationController(rootViewController: vc) , animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return inSearchMode ? filteredcontacts.count : contactsDictArray[section].value.count
      
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return inSearchMode ? 1 : contactsDictArray.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
       return String(contactsDictArray[section].key)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
                  context.delete(contactsDictArray[indexPath.section].value[indexPath.row])
                  contactsDictArray[indexPath.section].value.remove(at: indexPath.row)
                  fetchContacts()
                  tableView.reloadData()
            
            
    

            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
//        let index =  contactsDict.index(contactsDict.startIndex, offsetBy: indexPath.section)
//
        
        
        let contact = inSearchMode ? filteredcontacts[indexPath.row] : contactsDictArray[indexPath.section].value[indexPath.row]
        if let imageData = contact.value(forKey: "image") as? Data {
            cell.profileImageView.image = UIImage(data: imageData)
        }

        cell.fullnameLabel.text = contact.value(forKey: "mobileNumber") as? String
        cell.usernameLabel.text = contact.value(forKey: "fullname") as? String
        return cell

    }
  
  
  

}

