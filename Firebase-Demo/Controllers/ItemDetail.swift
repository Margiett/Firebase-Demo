//
//  itemDetail.swift
//  Firebase-Demo
//
//  Created by Margiett Gil on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class ItemDetail: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentsConstraints: NSLayoutConstraint!
    
    private var item: Item
    private var originalValueForConstraints: CGFloat = 0
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()
    }
    
    
    
    
    

    @IBAction func sendButton(_ sender: UIButton) {
    }
    
    private func registerKeyboardNotifications() {
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
     
    private func unregisterKeyboardNotifications() {
       
    }
     
    @objc private func keyboardWillShow(_ notification: Notification) {
        print(notification.userInfo) // info key from the userInfo
        guard let ketboardFrame = notification.userInfo?["UIKeyboardBoundUserInfoKey"] as? CGRect else {
            return
            
        }
       
    }
     
    @objc private func keyboardWillHide(_ notification: Notification) {
       
    }

    

}
