//
//  ProfileViewController.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 2/19/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import Foundation

import UIKit

class ProfileTableViewController:UITableViewController, UserPresentingViewProtocol {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    fileprivate var record:UserRecord?
    
    lazy var userPresenter:UserPresenter = UserPresenter()
    
    fileprivate var nameTextEntry:UITextView?
    fileprivate var emailTextEntry:UITextView?
    fileprivate var addressTextEntry:UITextView?
    fileprivate var userImageView: UIImageView!
    
    
    let  baselineProfileSections:Int = 3
    
    enum Section {
        case image
        case basic
        case extended
        
        var index:Int {
            switch self {
            case .image:
                return 0
            case .basic:
                return 1
            case .extended:
                return 2
            }
        }
        
        var numRows:Int {
            switch self {
            case .image:
                return 1
            case .basic:
                return 3
            case .extended:
                return 0 // This can grow dynamically
            }
        }
        
        var rowHeight:CGFloat {
            switch self {
            case .image:
                return 200.0
            case .basic:
                return 50.0
            case .extended:
                return 0 // This can grow dynamically
            }
        }
    }
    
    enum BasicRows {
        case name
        case email
        case address
        
        var index:Int {
            switch self {
            case .name:
                return 0
            case .email:
                return 1
            case .address:
                return 2
            }
        }
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Your Profile", comment: "")
        self.initializeTable()
        self.registerCells()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.userPresenter.attachPresentingView(self)
        self.userPresenter.fetchRecordForCurrentUser(handler: { [weak self](record, error) in
            switch error {
            case nil:
                self?.record = record
                self?.tableView.reloadData()
            default:
                self?.showAlertWithTitle(NSLocalizedString("Error!", comment: ""), message: (error?.localizedDescription)!)
            }
        })
        
    }
    
    
    private func initializeTable() {
        //    self.tableView.backgroundColor = UIColor.darkGray
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.sectionHeaderHeight = 10.0
        self.tableView.sectionFooterHeight = 10.0
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
    }
    
    private func registerCells() {
        let basicInfoNib = UINib(nibName: "CustomTextEntryTableViewCell", bundle: Bundle.main)
        self.tableView?.register(basicInfoNib, forCellReuseIdentifier: "BasicInfoCell")
        
        let imageNib = UINib(nibName: "CustomImageEntryTableViewCell", bundle: Bundle.main)
        self.tableView?.register(imageNib, forCellReuseIdentifier: "ImageCell")
        
    }
}

// MARK: IBActions
extension ProfileTableViewController {
    @IBAction func onDoneTapped(_ sender: UIBarButtonItem) {
        guard var userProfile = record else {return}
      //   let image = userImageView.image else {return}
      
        userProfile[UserRecordKeys.email.rawValue] = self.emailTextEntry?.text
        userProfile[UserRecordKeys.address.rawValue] = self.addressTextEntry?.text
        userProfile[UserRecordKeys.name.rawValue] = self.nameTextEntry?.text
        
        self.userPresenter.setRecordForCurrentUser(userProfile) { [weak self](error) in
            guard let `self` = self else {
                return
            }
            if error != nil {
                self.showAlertWithTitle(NSLocalizedString("Error!", comment: ""), message: (error?.localizedDescription)!)
            }
        }
    }
    
    
    @IBAction func onCancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:UITableViewDataSource
extension ProfileTableViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.basic.index:
            return Section.basic.numRows
        case Section.extended.index:
            return Section.extended.numRows
        case Section.image.index:
            return Section.image.numRows
        default:
            return 0
        }
    }
    
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(#function)
        
        switch indexPath.section {
            // Profile Image
            case Section.image.index:
                guard let cell = tableView.dequeueReusableCell( withIdentifier: "ImageCell") as? CustomImageEntryTableViewCell else {
                    return UITableViewCell()
                }
                if let imageData = self.record?[UserRecordKeys.name.rawValue] as? Data {
                    // TODO : Extract image data 
                    cell.imageBlob = UIImage.init(imageLiteralResourceName: "logo")
                    
                    cell.selectionStyle = .none
                    
                }
            return cell
            
            // Basic Info
            case Section.basic.index :
                switch indexPath.row {
                case BasicRows.name.index :
                    guard let cell = tableView.dequeueReusableCell( withIdentifier: "BasicInfoCell") as? CustomTextEntryTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.textEntryName.text = NSLocalizedString("Name:", comment: "")
                    cell.selectionStyle = .none
                    
                    nameTextEntry = cell.textEntryValue
                    nameTextEntry?.isEditable = true
                    nameTextEntry?.delegate = self
                    
                    cell.selectionStyle = .none
                    
                   if let name = self.record?[UserRecordKeys.name.rawValue] as? String {
                    
                        nameTextEntry?.text = name
                    
                    }
                    return cell
                
                case BasicRows.email.index :
                    guard let cell = tableView.dequeueReusableCell( withIdentifier: "BasicInfoCell") as? CustomTextEntryTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.textEntryName.text = NSLocalizedString("Email:", comment: "")
                    cell.selectionStyle = .none
                    
                    emailTextEntry = cell.textEntryValue
                    emailTextEntry?.isEditable = true
                    emailTextEntry?.delegate = self
                    
                    cell.selectionStyle = .none
                    if let email = self.record?[UserRecordKeys.email.rawValue] as? String {
                        emailTextEntry?.text = email
                      
                    }
                    return  cell
                case BasicRows.address.index :
                    guard let cell = tableView.dequeueReusableCell( withIdentifier: "BasicInfoCell") as? CustomTextEntryTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.textEntryName.text = NSLocalizedString("Address:", comment: "")
                    cell.selectionStyle = .none
                    
                    addressTextEntry = cell.textEntryValue
                    addressTextEntry?.isEditable = true
                    addressTextEntry?.delegate = self
                    
                    cell.selectionStyle = .none
                    if let address = self.record?[UserRecordKeys.address.rawValue] as? String {
                        addressTextEntry?.text = address
                
                        
                    }
                    return cell
                    
                default:
                     return UITableViewCell()
            }
            
        // future
        case Section.extended.index :
            return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "DefaultCell")
        default:
            return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "DefaultCell")
            
        }
        
        return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "DefaultCell")
        
    }
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            // Profile Image
            case Section.image.index:
                return Section.image.rowHeight
        
            // Basic Info
            case Section.basic.index:
                return Section.basic.rowHeight
        
            // Extended
            case Section.extended.index:
                return Section.extended.rowHeight
            default:
                return 0
            
        }
     
        return UITableViewAutomaticDimension
    }
    
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        var numExtn = 0
        // Future extensions
        if let record = self.record {
            if let extensions = record[UserRecordKeys.extended.rawValue] as? [[String:Any] ] {
                numExtn = extensions.count
            }
        }
        return self.baselineProfileSections + numExtn
    }
}


// MARK : UserPresentingViewProtocol
extension ProfileTableViewController {
    func updateUIWithUserRecord(_ record: UserRecord?, error: Error?) {
        switch error {
        case nil:
            self.record = record
            self.tableView.reloadData()
        default:
            self.showAlertWithTitle(NSLocalizedString("Error!", comment: ""), message: (error?.localizedDescription)!)
        }
        
    }
}

// MARK: UITextViewDelegate
extension ProfileTableViewController:UITextViewDelegate {

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let length = (textView.text?.characters.count)! - range.length + text.characters.count
        let addressEntryLength = (textView == self.addressTextEntry ) ? length : self.addressTextEntry?.text?.characters.count ?? 0
        let nameTextEntryLength = (textView == self.nameTextEntry) ? length : self.nameTextEntry?.text?.characters.count ?? 0
        let emailEntryLength = (textView == self.emailTextEntry ) ? length : self.emailTextEntry?.text?.characters.count ?? 0
        

        self.doneButton.isEnabled = emailEntryLength > 0 || nameTextEntryLength > 0 || addressEntryLength > 0
        
        return true
    }
    
}


