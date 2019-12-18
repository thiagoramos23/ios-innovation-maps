//
//  HomeViewController.swift
//  InnovationTaskMaps
//
//  Created by Thiago Ramos on 16/12/19.
//  Copyright © 2019 Thiago Ramos. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : UIViewController {
    
    @IBOutlet weak var orderFoodButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderFoodButton.layer.cornerRadius = 5.0
    }
    
    @IBAction func tappedOrderFood(_ sender: Any) {
        let mapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MapViewController")
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
}
