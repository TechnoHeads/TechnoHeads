//
//  Home.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 14.04.2024.
//

import UIKit
import Kingfisher

class Home: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblList: UITableView!
    
    var productArray:[Products] = [Products]()
    var selectedProduct:Products = Products(id: "", name: "", photo: "", amount: "", stock: "", createDate: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getList()
    }
    
    func getList(){
        productArray.removeAll()
        DispatchQueue.main.async {
            let jsonUrl = "\(Bundle.main.apiBaseURL)getProducts.php"
            let session = URLSession.shared
            let encodedUrl = jsonUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: encodedUrl)
            let task = session.dataTask(with: url! as URL){
                (data,response,error) -> Void in
                do{
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    let results = jsonData["Products"] as! Array<Dictionary<String,AnyObject>>
                    for item in results {
                        let product = Products(id: item["id"] as! String, name: item["name"] as! String, photo: item["photo"] as! String, amount: item["amount"] as! String, stock: item["stock"] as! String, createDate: item["createDate"] as! String)
                        self.productArray.append(product)
                    }
                    
                    DispatchQueue.main.async {
                        self.tblList.reloadData()
                    }
                } catch {}
            }
            task.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "promote", for: indexPath) as! PromoCell
            
            cell.promoImage.backgroundColor = .lightGray
            cell.promoImage.layer.cornerRadius = 10
            cell.promoImage.clipsToBounds = true
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath) as! ProductCell
            let array = productArray[indexPath.row-1]
            cell.productImage.layer.cornerRadius = 10
            cell.productImage.clipsToBounds = true
            cell.productName.text = array.name
            cell.productImage.kf.setImage(with: URL(string: array.photo))
            cell.amount.text = "\(array.amount) ₺"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row > 0){
            selectedProduct = productArray[indexPath.row-1]
            self.performSegue(withIdentifier: "productDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "productDetail"){
            let detailVC = segue.destination as! ProductDetail
            detailVC.product = selectedProduct
        }
    }

}
