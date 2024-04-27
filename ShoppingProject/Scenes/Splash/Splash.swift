//
//  Splash.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 14.04.2024.
//

import UIKit

class Splash: BaseViewController {
    
    @IBOutlet weak var act: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        act.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.act.stopAnimating()
            let vc = UIStoryboard(name: "Dashboard" , bundle: Bundle.main).instantiateInitialViewController() as! UITabBarController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
    
}
