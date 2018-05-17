//
//  PostController.swift
//  funnel
//
//  Created by Drew Carver on 5/15/18.
//  Copyright © 2018 Rodrigo Sagebin. All rights reserved.
//

import UIKit
import CloudKit

class PostController {

    let ckManager = CloudKitManager()
    
    static let shared = PostController()
    
    // Possibly use NSPredicate in CKManager to specific time frame, etc. Or implement infinite scroll.
    
    // Use notification center to notifiy feed view/following view when posts have been loaded to refresh the tableview
    

    // No touchy - mock data
    var mockFeedPosts = [MockPost(), MockPost(), MockPost()]
    
    var feedPosts = [Post]()
    var followingPosts = [Post]()
    
    
    func createPost(user: User, description: String, image: UIImage, category: String) {
        
        // TODO: Look into a more efficient way to get record ID without having to create a new CK record every time.
        
        // Create CKAsset from image
        
        // Write image to disk as a temprary file in order to create CKAsset
        let imageAsJpeg = UIImageJPEGRepresentation(image, 5.0)
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
    
        do {
            try imageAsJpeg?.write(to: url)
        } catch {
            print("Couldn't write temporary image to file: \(error)")
            return
        }
        
        let asset = CKAsset(fileURL: url)
        
        let creatorReference = CKReference(recordID: user.ckRecordID ?? user.ckRecord.recordID, action: .deleteSelf)
        let post = Post(user: user, description: description, imageAsCKAsset: asset, category: category, creatorRef: creatorReference)
        
        ckManager.save(records: [post.ckRecord], perRecordCompletion: nil) { (record, error) in
            if let error = error {
                print("Error saving post to CloudKit: \(error)")
                return
            }
            
            // Delete temporary image after creating CKAsset and saving new post
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Error deleting temporary image file: \(error)")
                return
            }
        }

    }
    
    
    func fetchFeedPosts() {
        let predicate = NSPredicate(value: true)
        
        ckManager.fetch(type: Post.typeKey, predicate: predicate) { (records, error) in
            if let error = error {
                print("Error fetching posts from CloudKit: \(error.localizedDescription)")
                return
            }
            
            guard let records = records else {
                print("Found nil for records fetched from CloudKit.")
                return
            }
            
            let recordsArray = records.compactMap( {Post(cloudKitRecord: $0) })
            
            self.feedPosts = recordsArray
        }
    }
    
    func fetchFollowingPosts(user: User) {
        
        // FIXME: This predicate needs to be updated to only pull posts that the person is following
        let predicate = NSPredicate(format: "following == %@", user.following)
        
        ckManager.fetch(type: Post.typeKey, predicate: predicate) { (records, error) in
            if let error = error {
                print("Error fetching posts from CloudKit: \(error.localizedDescription)")
                return
            }
            
            guard let records = records else {
                print("Found nil for records fetched from CloudKit.")
                return
            }
            
            let recordsArray = records.compactMap( {Post(cloudKitRecord: $0) })
            
            self.followingPosts = recordsArray
        }
    }
        

    
    init() {
        
        // No touchy - mock data
//        let user = User(username: "testing", name: "test2", email: "test@test.com", appleUserRef: nil)
//        let post = Post(user: user, description: "Image description.", image: UIImage(named: "settings")!, category: "Test category", creatorRef: CKReference(record: user.ckRecord, action: .deleteSelf))
//        let post2 = Post(user: user, description: "Image description 2.", image: UIImage(named: "settings")!, category: "Test category", creatorRef: CKReference(record: user.ckRecord, action: .deleteSelf))
//        self.mockFeedPosts = [post, post2]

    }
    
}

extension UIImage {
    convenience init?(ckAsset: CKAsset) {
        var imageData = Data()
        
        do {
            let data = try Data(contentsOf: ckAsset.fileURL)
            imageData = data
        } catch {
            print("Error re-creating data from CKAsset: \(error)")
        }
        
        self.init(data: imageData)
    }
}
