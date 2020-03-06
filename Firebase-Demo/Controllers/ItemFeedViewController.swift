//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by Kelby Mittan on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemFeedViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    
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
    
    
}
extension ItemFeedViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
