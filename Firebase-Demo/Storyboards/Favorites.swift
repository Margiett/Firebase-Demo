//
//  Favorites.swift
//  Firebase-Demo
//
//  Created by Margiett Gil on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Favorite {
    let itemName: String
    let favoritedDate: Timestamp
    let imageURL: String
    let itemId: String
    let price: Double
    let sellerId: String
    let sellerName: String
    
}

// MARK: today
extension Favorite {
    // failable initializer is shown below
    // all properties need to exist in order for the object to be created
    // the question mark makes it failable
    // failable is better because you dont want things to be created without the objects that we are saying are necessary... So if it not available then it wont work
    init?(_ dictionary: [String: Any]) {
        // below is matched to the one above which is what is availabe on firebase
        guard let itemName = dictionary["itemName"] as? String,
        let favoritedDate = dictionary["favoritedDate"] as? Timestamp,
        let imageURL = dictionary["imageURL"] as? String,
        let itemId = dictionary["itemId"] as? String,
        let price = dictionary["price"] as? Double,
            let sellerName = dictionary["sellerName"] as? String,
            let sellerId = dictionary["sellerId"] as? String else {
                return nil
                // if ANY of the values are missing then it returns nil for all of them and it will fail and not contiue
                // either you have all of the properties or not
        }
        self.itemName = itemName
        self.favoritedDate = favoritedDate
        self.imageURL = imageURL
        self.itemId = itemId
        self.price = price
        self.sellerId = sellerId
        self.sellerName = sellerName
    }
}
