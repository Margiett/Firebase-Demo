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
    static let userCollection = "user"
    
    static let commentsCollection = "comments" // sub-collection on the item  document
    
    // review - firebase firestore hierachy
    //top level
    //collection -> document - > collection -> document -> .......
    
    
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
    //MARK: March 10th
    public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let email = authDataResult.user.email else {
            return
        }
        // What is this line of code doing ???
        // is like creating the users id and personalizing it, so each use has there own id
        // each user would have a collection
        // this gets lets you see your own post the items you put for sell as well as to see the collection of items that other uses post .
        
        // this would help you save and access the users information easily and full information for example before you were unable to see the users pictures 
      db.collection(DatabaseService.userCollection).document(authDataResult.user.uid).setData(["email" : email, "createdData": Timestamp(date: Date()), "userId": authDataResult.user.uid]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
    }
    func updateDatabaseUser(displayName: String, photoURL: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection(DatabaseService.userCollection).document(user.uid).updateData(["photoURL" : photoURL, "displayName": displayName]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
        
    }
    
    public func delete(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        db.collection(DatabaseService.itemsCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
    }
}



