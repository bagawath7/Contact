//
//  AddContactViewController.swift
//  Contact
//
//  Created by zs-mac-4 on 19/12/22.
//

import UIKit
import CoreData

protocol AddContactViewControllerDelegate : AnyObject{
    func didFinishAddingContact()
}

class AddContactViewController: UIViewController {
    
    
    
    lazy var plushPhotoButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleProfileImage) , for: .touchUpInside)
        return button
    }()
    
    var delegate:AddContactViewControllerDelegate?
    var viewmodel = contact.ViewModel()
    let fullnameTextfield: UITextField = CustomTextField(placeholder: "Fullname")
    let mobileNumberTextField:UITextField = CustomTextField(placeholder: "Mobile Number")
    var profileImage:UIImage?
    
    var updateContact: NSManagedObject?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        observeChanges()
        
    }
    
    func configureUI(){
        title = "Add Contacts "
        self.view.backgroundColor = .white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(handleBackButton) )
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleAddContact) )
        
        if updateContact == nil{
            navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            navigationItem.rightBarButtonItem?.isEnabled = true

        }

        
        view.addSubview(plushPhotoButton)
        plushPhotoButton.centerX(inView: view)
        plushPhotoButton.setDimensions(height: 140, width: 140)
        plushPhotoButton.anchor(top:  view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        
        
        //MARK: Text Field stack
        
        let stack = UIStackView(arrangedSubviews: [fullnameTextfield,mobileNumberTextField])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        
        stack.anchor(top: plushPhotoButton.bottomAnchor,left: view.leadingAnchor,right: view.trailingAnchor,paddingTop: 32,paddingLeft: 32,paddingRight: 32)
        
    }
    @objc func handleProfileImage(){
        presentPhotoActionSheet()
    }
    
    @objc func handleBackButton(){
        self.dismiss(animated: true)
    }
    
    @objc func handleAddContact(){
        guard let fullname = fullnameTextfield.text else { return }
        guard let mobileNumber = mobileNumberTextField.text else { return }
        let profileImage = self.profileImage ?? UIImage(systemName: "person")!
        guard let imageData = profileImage.jpegData(compressionQuality: 0.75)
 else {
            print("No Image data")
            return }
        
        let entity = NSEntityDescription.entity(forEntityName: "ContactInfo",
                                                   in: context)!
        
        if let updateContact = updateContact{
            updateContact.setValue(fullname, forKey:"fullname")
            updateContact.setValue(mobileNumber, forKey:"mobileNumber")
            updateContact.setValue(imageData, forKey:"image")
        }else{
            let contact = NSManagedObject(entity: entity,
                                             insertInto: context)
            contact.setValue(fullname, forKey:"fullname")
            contact.setValue(mobileNumber, forKey:"mobileNumber")
            contact.setValue(imageData, forKey:"image")
            
        }
        
        
    
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        delegate?.didFinishAddingContact()
        dismiss(animated: true)
        
    }

    
    
    func observeChanges(){
        fullnameTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        mobileNumberTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
    }
    
    @objc func textDidChange(sender:UITextField){
    
            viewmodel.fullname = fullnameTextfield.text
            viewmodel.mobileNumber = mobileNumberTextField.text
        
        
        if(viewmodel.fullname?.isEmpty == false && viewmodel.mobileNumber?.isEmpty == false ){
            navigationItem.rightBarButtonItem?.isEnabled = true
        }else{
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
       
        
    
    
    
    func presentPhotoActionSheet(){
            
            let actionSheet = UIAlertController(title: "Profile Picture", message: "how would you select profile picture", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel,handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default,handler: { [weak self] _ in
                self?.presentCamera()
            }))
            actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default,handler: { [weak self] _ in
                self?.presentPhotoPicker()
            }))
            present(actionSheet,animated: true)
            
            
            
        }
        
        private func presentCamera(){
            let vc=UIImagePickerController()
            vc.sourceType = .camera
            vc.delegate = self
            vc.allowsEditing = true
            present(vc,animated: true)
        }
        
        
        private func presentPhotoPicker(){
            let vc=UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.delegate = self
            vc.allowsEditing = true
            present(vc,animated: true)
        }

    

}
extension AddContactViewController:UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImage = image
            plushPhotoButton.backgroundColor = .white
            plushPhotoButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            plushPhotoButton.imageView?.contentMode = .scaleAspectFit
            plushPhotoButton.layer.cornerRadius = plushPhotoButton.frame.size.width / 2
            plushPhotoButton.layer.masksToBounds = true
            plushPhotoButton.layer.borderColor = UIColor.white.cgColor
            plushPhotoButton.layer.borderWidth = 2
           
        }
        self.dismiss(animated: true, completion: nil)
    }
}
