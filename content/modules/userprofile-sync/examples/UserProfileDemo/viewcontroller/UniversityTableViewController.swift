//
//  UniversityTableViewController.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 5/2/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import Foundation

import Foundation
import UIKit
class UniversityTableViewController:UITableViewController , PresentingViewProtocol{
    
    lazy var universityPresenter:UniversityPresenter = UniversityPresenter()
    var currUniversitySelection:String?
    fileprivate var descriptionSearchBar:UISearchBar!
    fileprivate var locationSearchBar:UISearchBar!
    fileprivate var searchButton:UIButton!
    fileprivate var universities:Universities?
    fileprivate var indexOfSelectedUniverity:IndexPath?
    
    var onDoneBlock : ((String?) -> Void)?
    
    
    fileprivate var selectedUniversity:UniversityRecord?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = NSLocalizedString("Search Universities", comment: "")
        self.initializeTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.universityPresenter.attachPresentingView(self)
        
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.universityPresenter.detachPresentingView(self)
        super.viewDidDisappear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initializeTable() {
        //    self.tableView.backgroundColor = UIColor.darkGray
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 80
        
        self.tableView.sectionHeaderHeight = 10.0
        self.tableView.sectionFooterHeight = 10.0
        self.tableView.tableHeaderView = searchHeaderView()
    }
    
    
    
    private func searchHeaderView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150))
        descriptionSearchBar =  UISearchBar.init(frame: CGRect(x: 0, y: 5, width: self.view.frame.width , height: 40))
        view.backgroundColor = UIColor.white
        descriptionSearchBar.showsCancelButton = true
        descriptionSearchBar.placeholder = NSLocalizedString("Name (Required)", comment: "")
        view.addSubview(descriptionSearchBar)
        descriptionSearchBar.delegate = self
        
        
        locationSearchBar =  UISearchBar.init(frame: CGRect(x: 0, y: 50, width: self.view.frame.width , height: 40))
        view.backgroundColor = UIColor.white
        locationSearchBar.showsCancelButton = true
        locationSearchBar.placeholder = NSLocalizedString("Country (Optional) : Eg.'United States', 'London'", comment: "")
        view.addSubview(locationSearchBar)
        locationSearchBar.delegate = self
        
        
        searchButton =  UIButton.init(type: .custom)
        searchButton.frame =  CGRect(x: 5, y: 100, width: self.view.frame.width - 10, height: 44)
        searchButton.setTitle(NSLocalizedString("Lookup", comment: ""), for: UIControl.State.normal)
        searchButton.setBackgroundImage(#imageLiteral(resourceName: "cyan"), for: UIControl.State.normal)
        searchButton.setTitleColor(UIColor.gray, for: UIControl.State.disabled)
        searchButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        searchButton.addTarget(self, action: #selector(onUniversitiesLookup), for: UIControl.Event.touchUpInside)
        searchButton.isEnabled = false
        view.addSubview(searchButton)
        return view
        
    }
    
    
    @IBAction func onCancelTapped(_ sender: UIBarButtonItem) {
        
        onDoneBlock?(self.currUniversitySelection)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDoneTapped(_ sender: UIBarButtonItem) {
        
        onDoneBlock?(self.selectedUniversity?.name)
        self.dismiss(animated: true, completion: nil)
    }
}

extension UniversityTableViewController {
    @objc func onUniversitiesLookup(sender:UIButton) {
        guard let nameStr = descriptionSearchBar.text else {
            return
        }
        
        let locationStr = self.locationSearchBar.text == "" ? nil : self.locationSearchBar.text
        self.universityPresenter.fetchUniversitiesMatchingName(nameStr, country: locationStr) { [weak self](universities, error) in
            
            guard let `self` = self else {
                return
            }
            switch error {
            case nil:
                self.universities = universities
                self.tableView.reloadData()
            default:
                self.showAlertWithTitle(NSLocalizedString("Failed to University Info!", comment: ""), message: error?.localizedDescription ?? "")
                
                print("Error when fetching hotels \(error?.localizedDescription)")
                
            }
        }
    }
}

// MARK : UniversityPresentingViewProtocol
extension UniversityTableViewController:UniversityPresentingViewProtocol {
    
    func updateUIWithUniversityRecords(_ records: Universities?, error: Error?) {
        switch error {
        case nil:
            self.universities = records
            self.tableView.reloadData()
        default:
            self.universities = records
            self.tableView.reloadData()
            self.showAlertWithTitle(NSLocalizedString("", comment: ""), message: (error?.localizedDescription) ?? "Failed to fetch university record")
        }
    }
}
// MARK:UISearchBarDelegate
extension UniversityTableViewController:UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        print("Query on universities for \(String(describing: searchText))")
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let length = (searchBar.text?.count)! - range.length + text.count
        let nameLength = (searchBar == self.descriptionSearchBar) ? length : self.descriptionSearchBar.text?.count
        
        self.searchButton.isEnabled = (nameLength! > 0 )
        
        return true;
    }
    
    
}

// MARK: - Table view data source
extension UniversityTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.universities?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:UniversityCell = tableView.dequeueReusableCell(withIdentifier: "UniversityCell", for: indexPath) as? UniversityCell else {
            return UITableViewCell()
        }
        
        
        guard let universities = self.universities else {
            return  UITableViewCell()
        }
        if universities.count > indexPath.section {
            if let university = universities[indexPath.section] as? UniversityRecord {
                
                cell.nameValue = university.name ?? NSLocalizedString("Unavailable",comment:"")
                cell.locationValue = university.country ?? NSLocalizedString("Unavailable",comment:"")
                cell.urlValue = university.webPages?[0] ?? NSLocalizedString("Unavailable",comment:"")
            }
        }
        cell.selectionStyle = .blue
        return cell
    }
    
}


// MARK:UITableViewDelegate
extension UniversityTableViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedIndex  = indexOfSelectedUniverity {
            tableView.deselectRow(at: selectedIndex, animated: true)
            indexOfSelectedUniverity = nil
            self.selectedUniversity = nil

        }
        else {
            indexOfSelectedUniverity = indexPath
            self.selectedUniversity = universities?[indexPath.section]
        }
        
    }
    
}
