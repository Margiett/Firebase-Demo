//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by Kelby Mittan on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    private var selectedImage: UIImage? {
        didSet {
            profileImageView.image = selectedImage
        }
    }
    
    private let storageService = StorageService()
    

    override func viewDidLoad() {
        super.viewDidLoad()

       updateUI()
        displayNameTextField.delegate = self
        
    }
    private func updateUI(){
        guard let user = Auth.auth().currentUser else {
                   return
               }
               emailLabel.text = user.email
               displayNameTextField.text = user.displayName
        profileImageView.kf.setImage(with: user.photoURL)
               //user.displayNAme
               //user.email
               //user.phoneNumer
               //user.photoURL
    }
    
    
    @IBAction func updateProfileButtonPressed(_ sender: UIButton) {
        guard let displayName = displayNameTextField.text, !displayName.isEmpty, let selectedImage = selectedImage else {
            print("missing fields")
            return
        }
        
        guard let user = Auth.auth().currentUser else { return }
        
        // resize image before uploading to Firebase
        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: profileImageView.bounds)
        
        print("original image size: \(selectedImage.size)")
        print("resized image size: \(resizedImage)")
        
        // TODO:
        storageService.uploadPhoto(userId: user.uid, image: resizedImage) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error updating photo", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                request?.displayName = displayName
                request?.photoURL = url
                request?.commitChanges(completion: { [unowned self] (error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Error Updating Profile", message: "Error: \(error.localizedDescription)")
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "That's What's Up", message: "Your profile has been updated.")
                        }
                    }
                    
                })
            }
        }

        
    }
    
       
   
    @IBAction func editProfilePhotoButtonPressed(_ sender: Any) {
        let alertConstroller = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {  alertAction in
            self.imagePickerController.sourceType = .camera
                  self.present(self.imagePickerController, animated: true)
              }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) {
            alertAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
             alertConstroller.addAction(cameraAction)
        }
        alertConstroller.addAction(photoLibraryAction)
        alertConstroller.addAction(cancelAction)
        present(alertConstroller, animated: true)
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
            UIViewController.showViewController(storyboardName: "LoginView", viewControllerId: "LoginViewController")
        }catch {
            DispatchQueue.main.async {
                self.showAlert(title: "Error signing out", message: "\(error.localizedDescription)")
                //showAlert(title: "Error siging out", message: "\(error.localizedDescription)")
            }
        }
    }
    
}




extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        selectedImage = image
        dismiss(animated: true)
    }
    
}
