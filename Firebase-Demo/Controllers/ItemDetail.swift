//
//  itemDetail.swift
//  Firebase-Demo
//
//  Created by Margiett Gil on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemDetail: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentsConstraints: NSLayoutConstraint!
    
    private var item: Item
    private var originalValueForConstraints: CGFloat = 0
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(dismissKeyboard))
        return gesture
    }()
    private var listener: ListenerRegistration? // when you want to listen for changes,
    
    private var comments = [Comment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, h:mm a"
        return formatter
    }()
    
    private var isFavorite = false {
        didSet {
            if isFavorite {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            } else {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
                
            }
        }
    }
    
    private var databaseService = DatabaseService()
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = item.itemName
        
        tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
        
        originalValueForConstraints = commentsConstraints.constant
        
        textField.delegate = self
        
        view.addGestureRecognizer(tapGesture)
        tableView.dataSource = self
        updateUI()
        navigationItem.title = item.itemName
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        registerKeyboardNotifications()
        
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try Again", message: error.localizedDescription)
                }
            } else if let snapshot = snapshot {
                
                // create comments using dictionary initializer from the comment model
                let comments = snapshot.documents.map { Comment($0.data())}
                self?.comments = comments
                
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()
        listener?.remove()
    }
    
    //remember to call the updateUI in the viewDidload
    private func updateUI() {
        //check if item is a favorite and update heart icon accordingly
        
        databaseService.isItemInFavorites(item: item) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "try again", message: error.localizedDescription)
                }
            case .success(let success):
                if success { // meaning true
                    self?.isFavorite = true
                    
                } else {
                    self?.isFavorite = false
                    
                }
            }
        }
    }
    
    
    
    

    @IBAction func sendButton(_ sender: UIButton) {
        dismissKeyboard()
        //MARK: TODO add comment to the comments collection on this item on firebase
        
        guard let commentText = textField.text, !commentText.isEmpty else {
            showAlert(title: "Missing Field", message: "A comment is required")
            return
        }
        
        postComment(text: commentText)
    }
    
    
    private func postComment(text: String ) {
        databaseService.postComment(item: item, comment: text) { [weak self] (result) in
            switch result {
            case .failure(let error):
            DispatchQueue.main.async {
            self?.showAlert(title: "try again", message: error.localizedDescription)
            }
            case .success:
                DispatchQueue.main.async {
                    self?.showAlert(title: "Comment posted", message: nil)
                }
            }
        }
    }
    private func registerKeyboardNotifications() {
     NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
              NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
          }
          
          private func unregisterKeyboardNotifications() {
              
              
          }
          
          @objc private func keyboardWillShow(_ notification: Notification) {
             // print(notification.userInfo ?? "")
              guard let keyboardFrame = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
                  return
              }
              
              commentsConstraints.constant = (keyboardFrame.height - view.safeAreaInsets.bottom)
          }
          
          @objc private func keyboardWillHide(_ notification: Notification) {
              dismissKeyboard()
          }
          
          @objc private func dismissKeyboard() {
              commentsConstraints.constant = originalValueForConstraints
              textField.resignFirstResponder()
          }
    
    //MARK: March 12 2020
    @IBAction func favoriteButtonPress(_ sender: UIBarButtonItem) {
        if isFavorite { //remove from favorites
            databaseService.removeFromFavorites(item: item) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Failed to remove favorite", message: error.localizedDescription)
                    }
                case .success:
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Item removed", message: nil)
                        self?.isFavorite = false
                    }
                }
                
            }
            
        } else { // add to favorites
            databaseService.addToFavorites(item: item) { [weak self](result) in
                   switch result {
                   case .failure(let error):
                       DispatchQueue.main.async {
                           self?.showAlert(title: "Favoriting error", message: error.localizedDescription)
                       }
                   case .success:
                       DispatchQueue.main.async {
                           self?.showAlert(title: "item favorited", message: nil)
                        self?.isFavorite = true
                       }
                   }
               }
        }
   
        
        
    }

      }
      //MARK: Extention
      extension ItemDetail: UITextFieldDelegate {
          func textFieldShouldReturn(_ textField: UITextField) -> Bool {
              dismissKeyboard()
              return true
          }
      }
      
      extension ItemDetail: UITableViewDataSource {
          func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              return comments.count
              
          }
          
          func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
              let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
              
              let comment = comments[indexPath.row]
              
              let dateString = dateFormatter.string(from: comment.commentDate.dateValue())
              cell.textLabel?.text = comment.text
              cell.detailTextLabel?.text = "@" + comment.commentedBy + " " + dateString
              return cell
          }
      }
     










