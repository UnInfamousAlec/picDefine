//
//  UserController.swift
//  funnel
//
//  Created by Drew Carver on 5/15/18.
//  Copyright © 2018 Rodrigo Sagebin. All rights reserved.
//

import Foundation
import CloudKit


class UserController {
    
    var mockUser = MockUser()
    
    let ckManager = CloudKitManager()
    
    static let shared = UserController()
    
    var loggedInUser: User?
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        
        ckManager.getUserRecordID { (userRecordID, error) in
            if let error = error {
                print("Error getting user's Apple ID: \(error)")
                completion(false)
                return
            }
            
            guard let userRecordID = userRecordID else { return }
            
            let predicate = NSPredicate(format: "appleUserRef == %@", userRecordID)
            
            self.ckManager.fetch(type: User.typeKey, predicate: predicate, sortDescriptor: nil, completion: { (records, error) in
                if let error = error {
                    print("There was an error fetcing user by appleUserRef: \(error)")
                    completion(false)
                    return
                }
                
                guard let records = records,
                    let loggedInUserRecord = records.first else {
                        completion(false)
                        return
                }
                
                guard let loggedInUser = User(cloudKitRecord: loggedInUserRecord) else {
                    completion(false)
                    return
                }
                
                self.loggedInUser = loggedInUser
                completion(true)
                
            })
            
        }
        
    }
    
    func createNewUserWith(username: String, name: String, email: String, completion: @escaping (Bool) -> Void) {
        ckManager.getUserRecordID { (userRecordID, error) in
            if let error = error {
                print("Error getting Apple record ID: \(error)")
                completion(false)
                return
            }
            
            guard let userRecordID = userRecordID else {
                completion(false)
                return
            }
            
            let reference = CKReference(recordID: userRecordID, action: .deleteSelf)
            
            let newUser = User(username: username, name: name, email: email, appleUserRef: reference)
            
            self.loggedInUser = newUser
            
            self.ckManager.save(records: [newUser.ckRecord], perRecordCompletion: nil, completion: { (_, error) in
                if let error = error {
                    print("Error saving new user to CloudKit: \(error)")
                    completion(false)
                }
            })
            
            completion(true)
            
        }
    }
    
    func fetchUser(ckRecordID: CKRecordID) -> User? {
        
        var user: User?
        
        ckManager.fetchSingleRecord(ckRecordID: ckRecordID) { (record, error) in
            if let error = error {
                print("Error fetching a single user record: \(error)")
                user = nil
                return
            }
            
            guard let record = record else {
                user = nil
                return
            }
            
            let fetchedUser = User(cloudKitRecord: record)
            user = fetchedUser
            return
        }
        
        return user
    }
    
    func block(userRecordID: CKRecordID) {
        let reference = CKReference(recordID: userRecordID, action: .none)
        
        guard let loggedInUser = UserController.shared.loggedInUser else { return }
        
        loggedInUser.blockedUsers.append(reference)
        
        ckManager.save(records: [loggedInUser.ckRecord], perRecordCompletion: nil) { (records, error) in
            if let error = error {
                print("Error saving user after adding a blocked user: \(error)")
                return
            }
        }
    }
    
}