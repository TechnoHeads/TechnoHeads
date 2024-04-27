//
//  ProductDetail.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 14.04.2024.
//

import UIKit
import Kingfisher

class ProductDetail: BaseViewController {

    var product:Products = Products(id: "", name: "", photo: "", amount: "", stock: "", createDate: "")
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productAmount: UILabel!
    @IBOutlet weak var productStock: UILabel!
    @IBOutlet weak var btnAddCart: UIButton!
    
    var isAlreadyExistInCart:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Product Detail"
        
        productImage.kf.setImage(with: URL(string: product.photo))
        productName.text = "Product Name : \(product.name)"
        productAmount.text = "Price : \(product.amount) ₺"
        productStock.text = "Stock : \(product.stock)"
        
        btnAddCart.layer.cornerRadius = btnAddCart.frame.height / 2
        btnAddCart.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isExist()
    }
    
    func isExist(){
        let userid = UserDefaults.standard.string(forKey: "userid")!
        let request = NSMutableURLRequest(url: URL(string: "\(Bundle.main.apiBaseURL)existInCart.php")!)
        request.httpMethod = "POST"
        var isRemove = "0"
        if(self.isAlreadyExistInCart){
            isRemove = "1"
        }
        let postString = "userid=\(userid)&productid=\(product.id)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil && data != nil else {
                print("error=(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is (httpStatus.statusCode)")
                print("response = (String(describing: response))")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            let jsonDecoder = JSONDecoder()
            let result = try? jsonDecoder.decode(ServiceResponse.self, from: data!)
            let code = result?.result?.code
            let message = result?.result?.message
            let isexist = result?.result?.exist
            if(code == "200"){
                DispatchQueue.main.async {
                    if(isexist == "false"){
                        self.isAlreadyExistInCart = false
                        self.btnAddCart.setTitle("Add Cart", for: .normal)
                    }else{
                        self.isAlreadyExistInCart = true
                        self.btnAddCart.setTitle("Remove From Cart", for: .normal)
                    }
                }
            }else{
                self.showAlert(title: "Error", message: message ?? "")
            }
        }
        task.resume()
        
    }
    
    @IBAction func addCartTapped(_ sender: Any) {
        if (UserDefaults.standard.string(forKey: "Login") != nil && UserDefaults.standard.string(forKey: "Login") == "true"){
            let userid = UserDefaults.standard.string(forKey: "userid")!
            let request = NSMutableURLRequest(url: URL(string: "\(Bundle.main.apiBaseURL)addCart.php")!)
            request.httpMethod = "POST"
            var isRemove = "0"
            if(self.isAlreadyExistInCart){
                isRemove = "1"
            }
            let postString = "userid=\(userid)&productid=\(product.id)&remove=\(isRemove)"
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                guard error == nil && data != nil else {
                    print("error=(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is (httpStatus.statusCode)")
                    print("response = (String(describing: response))")
                }
                
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                let jsonDecoder = JSONDecoder()
                let result = try? jsonDecoder.decode(ServiceResponse.self, from: data!)
                let code = result?.result?.code
                let message = result?.result?.message
                let userid = result?.result?.userid
                let name = result?.result?.name
                let photo = result?.result?.photo
                if(code == "200"){
                    DispatchQueue.main.async {
                        if(self.isAlreadyExistInCart){
                            if let tabItems = self.tabBarController?.tabBar.items {
                                let tabItem = tabItems[1]
                                tabItem.badgeValue = nil
                            }
                            self.isAlreadyExistInCart = false
                            self.btnAddCart.setTitle("Add Cart", for: .normal)
                        }else{
                            if let tabItems = self.tabBarController?.tabBar.items {
                                let tabItem = tabItems[1]
                                tabItem.badgeValue = "1"
                            }
                            self.isAlreadyExistInCart = true
                            self.btnAddCart.setTitle("Remove From Cart", for: .normal)
                        }
                    }
                }else{
                    self.showAlert(title: "Error", message: message ?? "")
                }
            }
            task.resume()
            
        }else{
            self.showAlert(title: "Error", message: "Please sign in app")
        }
    }
    
}
