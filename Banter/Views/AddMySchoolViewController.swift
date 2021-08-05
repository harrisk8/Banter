//
//  AddMySchoolViewController.swift
//  Banter
//
//  Created by Harris Kapoor on 8/3/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import UIKit

class AddMySchoolViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var schoolListTableView: UITableView!
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var gotItButton: UIButton!
    
    
    
    let data = CollegeDataLoader().collegeData
    var filteredData: [CollegeData]!
    
    var indexPathSelected: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        overrideUserInterfaceStyle = .light
                
        schoolListTableView.backgroundColor = UIColor.white

        instructionsView.frame.origin.y = UIScreen.main.bounds.height
        
        searchBar.delegate = self
        filteredData = data

        
        schoolListTableView.delegate = self
        schoolListTableView.dataSource = self
  
        schoolListTableView.register(UINib(nibName: "SchoolListTableViewCell", bundle: nil), forCellReuseIdentifier: "schoolListCell")
        schoolListTableView.layoutMargins = .zero
        schoolListTableView.separatorInset = .zero

        
        //Updates the data in tableview to be filtered every time something is typed

        setUpUI()
        

        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func gotItButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.instructionsView.frame.origin.y = UIScreen.main.bounds.height
        })
        
        searchBar.isUserInteractionEnabled = true
        schoolListTableView.isUserInteractionEnabled = true
                
    }
    
    //Handles functionality for cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        print(filteredData[indexPath.row])
        
        indexPathSelected = indexPath.row
        
        performSegue(withIdentifier: "addMySchoolToConfirmSchool", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let confirmSchoolVC = segue.destination as? ConfirmSchoolViewController {
            confirmSchoolVC.schoolName = filteredData[indexPathSelected ?? 0].LocationName
        }
    }
    
    
    func setUpUI() {
        
        //Disables user from interacting with search bar/table view until instructions are acknowledged on pop-up
        searchBar.isUserInteractionEnabled = false
        schoolListTableView.isUserInteractionEnabled = false
        
        instructionsView.layer.shadowOpacity = 1.0
        instructionsView.layer.shadowRadius = 3.5
        instructionsView.layer.shadowColor = UIColor.black.cgColor
        instructionsView.layer.masksToBounds = true
        instructionsView.layer.shadowOffset = (CGSize(width: 0.0, height: -1.0))
        instructionsView.layer.cornerRadius = 27.5
        instructionsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        instructionsView.clipsToBounds = true
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.instructionsView.center.y = UIScreen.main.bounds.height/2
        })
        
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredData.count ?? 5
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolListCell", for: indexPath) as! SchoolListTableViewCell
                
        
        cell.schoolNameLabel.text = filteredData[indexPath.row].LocationName
        
        return cell
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
                
        filteredData = []
        
        if searchText == "" {
            
            filteredData = data
            
        }
        else {
            
        for college in data {
            
            if college.LocationName.lowercased().contains(searchText.lowercased()) {
                
                filteredData.append(college)
                
                }
            }
        }
        
        self.schoolListTableView.reloadData()
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
