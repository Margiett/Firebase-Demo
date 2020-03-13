//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Margiett Gil on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCell: UITableViewCell {

    @IBOutlet weak var itemImageView: DesignableImageView!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(_:)))
        return gesture
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sellerNameLabel.textColor = .systemOrange
        sellerNameLabel.addGestureRecognizer(tapGesture)
        sellerNameLabel.isUserInteractionEnabled = true
        
    }
    
    @objc
    // MARK: remember a space between the _ and the word 
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        print("was tapped handleTap")
    }
    
    public func configureCell(for item: Item){
        updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerName: item.sellerName, date: item.listedDate, price: item.price)
      
    }
    public func confirgureCell(for favorites: Favorite) {
        updateUI(imageURL: favorites.imageURL, itemName: favorites.itemName, sellerName: favorites.sellerName, date: favorites.favoritedDate.dateValue(), price: favorites.price)
        
    }
    
    private func updateUI(imageURL: String, itemName: String, sellerName: String, date: Date, price: Double) {
        //MARK: Setup image import kingfisher install kingfisher via pods
              itemImageView.kf.setImage(with: URL(string: imageURL))
              
              itemNameLabel.text = itemName
              sellerNameLabel.text = "@\(sellerName)"
        dateLabel.text = date.description
          
          // what does % 2f means ?? what does it do??
              let price = String(format: "% 2f", price)
              priceLabel.text = "$\(price)"
    }
}
