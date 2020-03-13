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
    static let favoritesCollection = "favorites" // sub collection on a user document
    
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
    public func postComment(item: Item, comment: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser,
            let displayName = user.displayName else {
        print("missing user data ")
        return }
        
        // this line of the code, we are getting access to a document
        // getting a document
        let docRef = db.collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsCollection).document()
        
            // and this line is where we are writing in the document
        // using document from above to write to its contents to firebase
        db.collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsCollection).document(docRef.documentID).setData(["text" : comment, " commentDate": Timestamp(date: Date()), "itemName": item.itemName, "itemId": item.itemId, "sellerName": item.sellerName, "commentedBy": displayName]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
    }
    //MARK: MArch 12 2020
    public func addToFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()){
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritesCollection).document(item.itemId).setData(["itemName" : item.itemName, "price": item.price, "imageURL": item.imageURL, "favoritedDate": Timestamp(date: Date()), "itemId": item.itemId, "sellerName": item.sellerName, "sellerId": item.sellerId]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
    }
    
    public func removeFromFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritesCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func isItemInFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()){
        guard let user = Auth.auth().currentUser else { return }
        // in firebase we use the "where" keyword  to query (search) a collection
        
        // addSnapshotlistener - contiunes to listen for modifications to a collection
        // getDocuments - fetches documents Only once
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritesCollection).whereField("itemId", isEqualTo: item.itemId).getDocuments { (snapshot, error) in
            
            if let error = error {
                completion( .failure(error))
            } else if let snapshot = snapshot {
                let count = snapshot.documents.count // check if we have documents 
                if count > 0 {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            }
            
        }

    }
    
    public func fetchUserItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        db.collection(DatabaseService.itemsCollection).whereField(Constants.sellerId, isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                // compact map removes nil value from an array
                //[4, nil, 12, -9, nil] => [4, 12, -9]
                //init?() => Favorites?
                let items = snapshot.documents.map { Item($0.data()) }
                completion(.success(items))
            }
            
            }
        
    }
    
    //MARK: Today
    // can update function to take a user id
    public func fetchFavorites(completion: @escaping (Result<[Favorite], Error>) -> () ) {
        //(Result<[Favorite], Error>) -> () ){
        guard let user = Auth.auth().currentUser else { return }
        // closure capture values
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritesCollection).getDocuments {
            (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot{
                // compact map removes  nil values from an array optionals
                // [4, nil , 12, -9, nil] => [4, 12, -9]
                // init?() => Favorite?
                let favorties = snapshot.documents.compactMap { Favorite($0.data()) }
                completion(.success(favorties))
            }
        }
    }


    
}



