//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by Kelby Mittan on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth //MARK: MArch 10 2020

class ItemFeedViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    
    //MARK: March 10 2020
    private let databaseService = DatabaseService()
    
    private var items = [Item]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self 
        
        //MARK: register our custom .xib itemCell class
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")

    }
    
    // setting up the listener
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection)
        .addSnapshotListener({[weak self ](snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Firestore Error", message: "\(error.localizedDescription)")
                }
            } else if let snapshot = snapshot {
                print("there are \(snapshot.documents.count) items for sell")
                let items = snapshot.documents.map {Item($0.data()) }
                // maps for thru each element in the array
                // each element represents $0
                //$0.data is a dictonary
                // for item in item is item and that is $0.data
                self?.items = items
            }
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        listener?.remove() // no longer are we listening for changes from Firebase
    }
}

extension ItemFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("can not downcast to itemcell")
        }
        let item = items[indexPath.row]
        cell.configureCell(for: item)
//        cell.textLabel?.text = item.itemName
//        let price = String(format: "% 2f", item.price)
//        cell.detailTextLabel?.text = "@\(item.sellerName) price: $\(price)"
        return cell
    }
    //MARK: March 10 2020
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //perform deletion on item
            // since we have a listener we just need to delete from the firebase .
            
            // this is where we actually delete
            //perform deletion on item 
            let item = items[indexPath.row]
            databaseService.delete(item: item) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Deletion error", message: error.localizedDescription)
                    }
                case .success:
                    print("deleted successfully")
                }
            }
            
        }
    }
    
    // on the client side meaning the app we will ensure that swipe to delete only works for the user who created the item
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.row]
        guard let user = Auth.auth().currentUser else { return false }
        // ensuring that the person who is deleting is the one who created and selling the item.
        if item.sellerId != user.uid {
            return false // cannot swipe on row to delete
        }
        return true // able to swipe to delete item
    }
    
    //MARK: TODO March 10th 2020 thats not enough to only prevent accidental deletion on the client we need to protect the database as well we will do so using firebase "Security Rules"
    
    
}
extension ItemFeedViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let storyboard = UIStoryboard(name: "MainView", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "ItemDetail") { (coder) in
            return ItemDetail (coder: coder, item: item)
        }
        navigationController?.pushViewController(detailVC, animated: true)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

