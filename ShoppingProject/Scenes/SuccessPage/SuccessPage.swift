//
//  SuccessPage.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 15.04.2024.
//

import UIKit

class SuccessPage: BaseViewController {

    @IBOutlet weak var btnGoHome: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnGoHome.layer.cornerRadius = btnGoHome.frame.height / 2
        btnGoHome.clipsToBounds = true
    }
    
    @IBAction func goHomeButtonTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Dashboard" , bundle: Bundle.main).instantiateInitialViewController() as! UITabBarController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false)
    }
    
}
