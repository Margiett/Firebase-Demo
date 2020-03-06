//
//  StorageService.swift
//  abseil
//
//  Created by Margiett Gil on 3/4/20.
//

import Foundation
import FirebaseStorage

class StorageService {
    //MARK: in our app we will be uploading a photo to storage in two places 1. ProfileViewController and 2. CreateItemViewController
    
    //MARK: we will be creating two different buckets of folders 1. UserProfilePhotos/ 2.ItemsPhotos/
    
    // lets create a reference to the Firebase storage
    private let storageRef = Storage.storage().reference()
    
    // default parameters in swift example userId: String? = nil
    public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result<URL, Error>) -> ()) {
        
        //MARK: 1. convert UIImage to Data because this is the object we are posting to Firebase Storage
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // we need to establish which bucket or collection or folder we will be saving the photo to
        var photoReference: StorageReference!
        
        if let userId = userId { // coming from profilevc
            photoReference = storageRef.child("UserProfilePhotos/\(userId).jpg")
            
        } else if let itemId = itemId { // coming from createitemvc
            photoReference = storageRef.child("ItemsPhotos/\(itemId).jpg")
            
        }
        
        // configure metatdata for the object being uploaded
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpg"
        
        let _ = photoReference.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else if let _ = metadata {
                photoReference.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    }
                }
            }
        }
        
    }
}
