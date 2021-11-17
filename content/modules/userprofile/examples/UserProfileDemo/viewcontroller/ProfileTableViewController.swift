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
    fileprivate var imageUpdated:Bool = false
    fileprivate var universityLabel:UILabel?
    fileprivate var selectedUniversity:String?
    
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
                return 4
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
        case university
        
        var index:Int {
            switch self {
            case .name:
                return 0
            case .email:
                return 1
            case .address:
                return 2
            case .university:
                return 3
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
        self.userPresenter.fetchRecordForCurrentUserWithLiveModeEnabled(__: true)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectedUniversity = nil
        self.userPresenter.detachPresentingView(self)
    }
    
    private func initializeTable() {
        //    self.tableView.backgroundColor = UIColor.darkGray
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
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
    
    deinit {
        selectedUniversity = nil
        self.userPresenter.detachPresentingView(self)

    }
    
   
}

// MARK: IBActions
extension ProfileTableViewController {
    @IBAction func onDoneTapped(_ sender: UIBarButtonItem) {
        guard var userProfile = record else {return}
        
      //   let image = userImageView.image else {return}
        userProfile.email = self.emailTextEntry?.text
        userProfile.address = self.addressTextEntry?.text
        userProfile.name = self.nameTextEntry?.text
        userProfile.university = self.universityLabel?.text
        
        
        if let imageVal = self.userImageView?.image, let imageData = imageVal.jpegData(compressionQuality: 0.75)  {
            userProfile.imageData = imageData
        }
        
    
        self.userPresenter.setRecordForCurrentUser(userProfile) { [weak self](error) in
            guard let `self` = self else {
                return
            }
            if error != nil {
                self.showAlertWithTitle(NSLocalizedString("Error!", comment: ""), message: (error?.localizedDescription) ?? "Failed to update user record")
            }
            else {
                 self.showAlertWithTitle("", message: "Succesfully updated profile!")
            }
        }
    }
    
    
    @IBAction func onCancelTapped(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(Notification.notificationForLogOut())
    }
}

//MARK:UITableViewDataSource
extension ProfileTableViewController{
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
                cell.delegate = self
                cell.selectionStyle = .none
                userImageView = cell.imageEntryView
                if let imageData = self.record?.imageData{
                    cell.imageBlob  = UIImage.init(data: imageData)
                }
                else {
                    cell.imageBlob  = UIImage.init(imageLiteralResourceName: "default-user-thumbnail")
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
                    
                   if let name = self.record?.name as? String {
                        nameTextEntry?.text = name
                    }
                   else {
                        nameTextEntry?.text = nil
                    }
                    return cell
                
                case BasicRows.email.index :
                    guard let cell = tableView.dequeueReusableCell( withIdentifier: "BasicInfoCell") as? CustomTextEntryTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.textEntryName.text = NSLocalizedString("Email:", comment: "")
                    cell.selectionStyle = .none
                    cell.textEntryValue?.isEditable = false
                    emailTextEntry = cell.textEntryValue
                    emailTextEntry?.delegate = self
                    
                    cell.selectionStyle = .none
                    if let email = self.record?.email as? String {
                        emailTextEntry?.text = email
                    }
                    else {
                        emailTextEntry?.text = nil
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
                    if let address = self.record?.address as? String {
                        addressTextEntry?.text = address
                    }
                    else {
                        addressTextEntry?.text =  nil
                    }
                    return cell
                case BasicRows.university.index :
                    guard let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "UniversitySelectionCell") as? UITableViewCell else {
                        return UITableViewCell()
                    }
                    self.universityLabel = cell.detailTextLabel
                    cell.textLabel?.text = NSLocalizedString("University", comment: "")
                    cell.detailTextLabel?.text = selectedUniversity ?? self.record?.university ?? nil
//                    if let selectedUniversity = selectedUniversity {
//                        cell.detailTextLabel?.text = selectedUniversity
//                    }
//                    else {
//                        cell.detailTextLabel?.text = self.record?.university ?? nil
//                    }
                    
                    cell.selectionStyle = .gray
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                    
                    return cell
                default:
                     return UITableViewCell()
            }
            
        // future
        case Section.extended.index :
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "DefaultCell")
        default:
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "DefaultCell")
            
        }
        
        
    }
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
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
     
        return UITableView.automaticDimension
    }
    
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        var numExtn = 0
        // Future extensions
        if let record = self.record {
            if let extensions = record.extended  {
                numExtn = extensions.count
            }
        }
        return self.baselineProfileSections + numExtn
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        // Profile Image
        case Section.image.index:
            return
            
        // Basic Info
        case Section.basic.index:
            switch indexPath.row {
            case BasicRows.name.index :
                return
            case BasicRows.address.index :
                return
            case BasicRows.email.index :
                return
            case BasicRows.university.index :
                self.navigateToViewControllerOnSelectUniversityAction()
                return
            default:
                return
                
            }
            
        // Extended
        case Section.extended.index:
            return
        default:
            return
            
        }
    }
}


// MARK: Navigation
extension ProfileTableViewController {
    fileprivate func navigateToViewControllerOnSelectUniversityAction() {
        if let destNVC = storyboard?.instantiateViewController(withIdentifier: "UniversityNVC") as? UINavigationController {
            if let destVC = destNVC.topViewController as? UniversityTableViewController {
                destVC.modalPresentationStyle = .formSheet
                destVC.currUniversitySelection = self.universityLabel?.text
                destVC.onDoneBlock = onUniversitySelectionMade
                self.present(destNVC, animated: true, completion: {
                    
                })
            }
        }
    }
    
    public func onUniversitySelectionMade(_ university:String?) {
        print("UNiversity \(university) selected")
        self.selectedUniversity = university
        tableView.reloadRows(at: [IndexPath.init(row: BasicRows.university.index, section: Section.basic.index)], with: .automatic)
        self.doneButton.isEnabled = true
    }
    
}

// MARK : CustomImageEntryTableViewCellProtocol
extension ProfileTableViewController:CustomImageEntryTableViewCellProtocol {
    func onUploadImage() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.modalPresentationStyle = .popover
        
        let albumAction = UIAlertAction(title: NSLocalizedString("Select From Photo Album", comment: ""), style: .default) { action in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary;
            
            imagePickerController.modalPresentationStyle = .overCurrentContext
            
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let cameraAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default) { [unowned self] action in
                
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = false
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera;
                imagePickerController.cameraDevice = UIImagePickerController.CameraDevice.front;
                
                imagePickerController.modalPresentationStyle = .overCurrentContext
                
                self.present(imagePickerController, animated: true, completion: nil)
                
            }
            alert.addAction(cameraAction)
            
        }
        alert.addAction(albumAction)
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        present(alert, animated: true, completion: nil)
        
    }
}


extension ProfileTableViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.userImageView.image = image
            self.imageUpdated = true
            self.doneButton.isEnabled = true

            picker.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
// MARK : UserPresentingViewProtocol
extension ProfileTableViewController {
    func updateUIWithUserRecord(_ record: UserRecord?, error: Error?) {
        switch error {
        case nil:
            self.record = record
            self.selectedUniversity = self.selectedUniversity ?? record?.university 
            self.tableView.reloadData()
        default:
            self.showAlertWithTitle(NSLocalizedString("Error!", comment: ""), message: (error?.localizedDescription) ?? "Failed to fetch date user record")
        }
    }
}

// MARK: UITextViewDelegate
extension ProfileTableViewController:UITextViewDelegate {

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            switch textView {
            case self.nameTextEntry!:
                self.addressTextEntry?.becomeFirstResponder()
            case self.addressTextEntry!:
                textView.resignFirstResponder()
            default:
                textView.resignFirstResponder()
                
            }
        }
        let length = (textView.text?.count)! - range.length + text.count
        let addressEntryLength = (textView == self.addressTextEntry ) ? length : self.addressTextEntry?.text?.count ?? 0
        let nameTextEntryLength = (textView == self.nameTextEntry) ? length : self.nameTextEntry?.text?.count ?? 0
        let emailEntryLength = (textView == self.emailTextEntry ) ? length : self.emailTextEntry?.text?.count ?? 0
        self.doneButton.isEnabled = imageUpdated || emailEntryLength > 0 || nameTextEntryLength > 0 || addressEntryLength > 0
       
        return true
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
