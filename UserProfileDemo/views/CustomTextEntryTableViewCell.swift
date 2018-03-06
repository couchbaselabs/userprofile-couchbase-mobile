//
//  CustomTextEntryTableViewCell.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 3/4/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import UIKit

class CustomTextEntryTableViewCell: UITableViewCell {
    
    
    public var name:String? {
        didSet {
            self.updateUI()
        }
    }
    
    @IBOutlet weak var textEntryName: UILabel!
    @IBOutlet weak var textEntryValue: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateUI()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func updateUI(){
        if let _ = textEntryName, let name = name {
            self.textEntryName.text = name
        }
        
        self.layoutIfNeeded()
    }
    
}
