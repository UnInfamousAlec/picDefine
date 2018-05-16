//
//  FeedTableViewCell.swift
//  funnel
//
//  Created by Alec Osborne on 5/16/18.
//  Copyright © 2018 Rodrigo Sagebin. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var commentsTextView: UITextView!
    
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var exclamationButtonOutlet: UIButton!
    @IBOutlet weak var notificationButtonOutlet: UIButton!
    @IBOutlet weak var branchButtonOutlet: UIButton!
    @IBOutlet weak var aprovedButtonOutlet: UIButton!
   
    
    func updateViews() {
        if let post = post {
            self.categoriesLabel.text = post.category
            self.descriptionTextView.text = post.description
        }
    }



}
