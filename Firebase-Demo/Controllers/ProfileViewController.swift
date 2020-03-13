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

enum ViewState {
    case myItems
       case favorites

}


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    
    
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
    
    //MARK: March 10th 2020
    private let databaseService = DatabaseService()
    
    private var viewState: ViewState = .myItems {
        didSet {
            tableView.reloadData()
        }
    }
    
    // favorites data
    private var favorites = [Favorite] () {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    // my items data
    private var myItems = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    private var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       updateUI()
        displayNameTextField.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        tableView.delegate = self
        fetchItem()
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchItem), for: .valueChanged)
        loadData()
    }
    private func loadData() {
        fetchItem()
        fetchFavorites()
    }
    @objc private func fetchItem() {
        guard let user = Auth.auth().currentUser else {
            refreshControl.endRefreshing()
            return
            
        }
        databaseService.fetchUserItems(userId: user.uid) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fetching error", message: error.localizedDescription)
                }
            case .success(let items):
                self?.myItems = items
            }
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func fetchFavorites(){
        databaseService.fetchFavorites { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Failed fetching favorites", message: error.localizedDescription)
                }
            case .success(let favorites):
                self?.favorites = favorites
               
            }
            DispatchQueue.main.async {
                 self?.refreshControl.endRefreshing()
            }
        }
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
        
        
        storageService.uploadPhoto(userId: user.uid, image: resizedImage) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error updating photo", message: "\(error.localizedDescription)")
                }
    
            case .success(let url):
                
                self?.updateDatabaseUser(displayName: displayName, photoURL: url.absoluteString)
                
                //MARK: March 10 202 TODO: refactor into its own function
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

    //MARK: March 10th 2020
    private func updateDatabaseUser(displayName: String, photoURL: String) {
        databaseService.updateDatabaseUser(displayName: displayName, photoURL: photoURL) { (result) in
            switch result {
            case .failure(let error):
               print("failed to update db user: \(error)")
            case .success:
                print("successfully updated db user")
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
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        // toggle current viewState value
        switch sender.selectedSegmentIndex {
        case 0:
            viewState = .myItems
        case 1:
            viewState = .favorites
        default:
            break
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
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewState == .myItems {
            return myItems.count
        } else {
            return favorites.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("could not downcast to itemCell")
            
        }
        if viewState == .myItems {
            let item = myItems[indexPath.row]
            cell.configureCell(for: item)
        } else {
            let favorite = favorites[indexPath.row]
            cell.confirgureCell(for: favorite)
        }
        return cell
    }
}
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
