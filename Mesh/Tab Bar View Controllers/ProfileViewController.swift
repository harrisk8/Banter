//
//  ProfileViewController.swift
//  Mesh
//
//  Created by Harris Kapoor on 12/6/20.
//  Copyright © 2020 Avidi Technologies. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTransparentNavigationBarWithWhiteText()
    }
    

 

}



extension UIViewController {
    func setupTransparentNavigationBarWithBlackText() {
        setupTransparentNavigationBar()
        //Status bar text and back(item) tint to black
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = .black
    }

    func setupTransparentNavigationBarWithWhiteText() {
        setupTransparentNavigationBar()
        //Status bar text and back(item) tint to white
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.tintColor = .white
    }

    func setupTransparentNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.isTranslucent = true
    }
}
