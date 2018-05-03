//
//  UniversityCell.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 5/2/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import UIKit

class UniversityCell: UITableViewCell {
    
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var url:UILabel!
    @IBOutlet weak var location:UILabel!
    var nameValue:String? {
        didSet {
            updateUI()
        }
    }
    var urlValue:String? {
        didSet {
            updateUI()
        }
    }
    var locationValue:String? {
        didSet {
            updateUI()
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func updateUI() {
        if let nameValue = nameValue {
            self.name.text = nameValue
        }
        
        if let locationValue = locationValue {
            self.location.text = locationValue
        }
        
        if let urlValue = urlValue {
            self.url.text = urlValue
        }
    }
    
}


