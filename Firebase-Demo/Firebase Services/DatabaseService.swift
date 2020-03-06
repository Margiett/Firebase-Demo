//
//  DatabaseService.swift
//  Firebase-Demo
//
//  Created by Margiett Gil on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class DatabaseService {
    static let itemsCollection = "items" // collections
    
    // let's get a reference to the firebase firestore database
    private let db = Firestore.firestore()
    //MARK: dont forget the colons : after the completions !!
    // we want to refactor in the result type the Bool to a String because we want the documentId
    public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result <String, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        
        // generate a document id
        let documentRef = db.collection(DatabaseService.itemsCollection).document()
        
        // create a document in our "items" collection
        //MARK: Firebase works with dictonary  (["" : "" ])
        
        /*
         let itemName: String
         let price: Double
         let itemId: String
         let listedDate: Date
         let sellerName: String
         let categoryName: String
         */
        db.collection(DatabaseService.itemsCollection).document(documentRef.documentID).setData(["itemName" :itemName, "price" :price, "itemId" :documentRef.documentID, "listedDate" :Timestamp(date: Date()), "sellerName" :displayName, "sellerId" : user.uid, "categoryName" : category.name]) { (error) in
            if let error = error {
                print ("error creating item: \(error)")
                completion(.failure(error))
                
            } else {
                completion(.success(documentRef.documentID))
            }
            
        }
        
        
    }
}



