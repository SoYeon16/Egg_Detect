//
//  MainViewController.swift
//  TextDetect
//
//  Created by 이소연 on 06/03/2019.
//  Copyright © 2019 Assignment. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {

    
    @IBOutlet weak var goToInformation: UIButton!
    @IBOutlet weak var goToSearchEgg: UIButton!
    @IBOutlet weak var goToSearchLog: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goToInformation.layer.shadowColor = UIColor.gray.cgColor
        goToInformation.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        goToInformation.layer.masksToBounds = false
        goToInformation.layer.shadowRadius = 1.0
        goToInformation.layer.shadowOpacity = 0.5
        goToInformation.layer.cornerRadius = 10
        
        goToSearchEgg.layer.shadowColor = UIColor.gray.cgColor
        goToSearchEgg.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        goToSearchEgg.layer.masksToBounds = false
        goToSearchEgg.layer.shadowRadius = 1.0
        goToSearchEgg.layer.shadowOpacity = 0.5
        goToSearchEgg.layer.cornerRadius = 10
        
        goToSearchLog.layer.shadowColor = UIColor.gray.cgColor
        goToSearchLog.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        goToSearchLog.layer.masksToBounds = false
        goToSearchLog.layer.shadowRadius = 1.0
        goToSearchLog.layer.shadowOpacity = 0.5
        goToSearchLog.layer.cornerRadius = 10
        
    }
}
