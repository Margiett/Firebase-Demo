//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Kelby Mittan on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth // authentication
import FirebaseFirestore

class CreateItemViewController: UIViewController {
    
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    
    
    
    private var category: Category
    
    // we need to create an instance of our data base service
    private let dbService = DatabaseService()
    private let storageService = StorageService()
    
    private lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self // conform to UIImagePickerController Delegate and UINavigationControllerDelegate
        return picker
    }()
    
    //MARK: Adding a gesture to the picture !!
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(showPhotoOptions)) // adding the gesture to the picture(target)
        
        return gesture
    }()
    //MARK: You call selectedImage in the extensions for UIImagePickerControllerDelegate and UINavigationControllerDelegate
    private var selectedImage: UIImage? {
        didSet{
            itemImageView.image = selectedImage
        }
    }
    
    init?(coder: NSCoder, category: Category){
        self.category = category
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category.name
        
        // add long press gesture to itemImageView
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(longPressGesture)


    }
    
    @objc
    private func showPhotoOptions(){
        let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            alertAction in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let photoLibrary = UIAlertAction(title: " Photo Library", style: .default) {
            alertAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true )
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        if UIImagePickerController.isSourceTypeAvailable(.camera) { // checking if there is a camara avaiable
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        
    }
    
//sellbuttonPressed - Alex
    @IBAction func postItemButtonPressed(_ sender: Any) {
        guard let itemName = itemName.text,
             !itemName.isEmpty,
             let priceText = itemPrice.text,
             !priceText.isEmpty,
             let price = Double(priceText),
             let selectedImage = selectedImage else {
               showAlert(title: "Missing Fields", message: "All fields are required along with a photo.")
               return
           }
           
           guard let displayName = Auth.auth().currentUser?.displayName else {
             showAlert(title: "Incomplete Profile", message: "Please complete your Profile.")
             return
           }
           
           // resize image before uploading to Storage
           let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: itemImageView.bounds)
           
           dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self] (result) in
             switch result {
             case.failure(let error):
               DispatchQueue.main.async {
                 self?.showAlert(title: "Error creating item", message: "Sorry something went wrong: \(error.localizedDescription)")
               }
             case .success(let documentId):
               self?.uploadPhoto(photo: resizedImage, documentId: documentId)
             }
           }
//        guard let itemName = itemName.text,
//            !itemName.isEmpty,
//            let priceText = itemPrice.text,
//            !priceText.isEmpty,
//            let price = Double(priceText) else {
//                let selectedImages = selectedImage else { // making sure there is an image
//
//
//                }
//                showAlert(title: "Missing Fields", message: "All fields are required")
//                return
//        }
//        guard let displayName = Auth.auth().currentUser?.displayName else {
//            showAlert(title: "Incomplete Profile", message: "Please complete your profile")
//
//            return
//        }
//        // resize image before uploading to storage
//        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: itemImageView.bounds)
//
//
//        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self] (result) in
//            switch result {
//            case .failure(let error):
//                self?.showAlert(title: "Error creating items", message: "Sorry something went wrong \(error.localizedDescription)")
//            case .success(let documentId):
//                break
//                self?.uploadPhoto(image: resizedImage, documentId: documentId)
//                self?.showAlert(title: nil, message: "Sucessfully Listed your item")
//                //MARK: TODO: upload photo to storage
//            }
//        }
//       // dismiss(animated: true)
    }
    private func uploadPhoto(photo: UIImage, documentId: String){
        storageService.uploadPhoto(itemId: documentId, image: photo) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error uploading Photo", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                self?.updatItemImageURL(url, documentId: documentId)
            }
        }
    }
    
    private func updatItemImageURL(_ url: URL, documentId: String) {
        // update an existing document on Firebase
        Firestore.firestore().collection(DatabaseService.itemsCollection).document(documentId).updateData(["imageURL" : url.absoluteString ]) { [weak self] (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail to upate item", message: "\(error.localizedDescription)")
                }
            } else {
                // everything went okay
                print("all went well with the update")
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
            
        }
    }
    
}
extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("could not attain orginal image")
        }
        selectedImage = image
        dismiss(animated: true)
    }
}
