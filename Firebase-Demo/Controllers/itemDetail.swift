//
//  itemDetail.swift
//  Firebase-Demo
//
//  Created by Margiett Gil on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class itemDetail: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    private var item: Item
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func sendButton(_ sender: UIButton) {
    }
    
    

}
