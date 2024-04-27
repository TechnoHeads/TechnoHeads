//
//  Cart.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 15.04.2024.
//

import UIKit
import Kingfisher

class Cart: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var btnOrder: UIButton!
    
    var cartArray:[Products] = [Products]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnOrder.layer.cornerRadius = btnOrder.frame.height / 2
        btnOrder.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCart()
    }
    
    func getCart(){
        cartArray.removeAll()
        DispatchQueue.main.async {
            let userid = UserDefaults.standard.string(forKey: "userid")!
            let jsonUrl = "\(Bundle.main.apiBaseURL)getCart.php?userid=\(userid)"
            let session = URLSession.shared
            let encodedUrl = jsonUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: encodedUrl)
            let task = session.dataTask(with: url! as URL){
                (data,response,error) -> Void in
                do{
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    let results = jsonData["Cart"] as! Array<Dictionary<String,AnyObject>>
                    var totalAmount = 0
                    for item in results {
                        let product = Products(id: item["id"] as! String, name: item["name"] as! String, photo: item["photo"] as! String, amount: item["amount"] as! String, stock: item["stock"] as! String, createDate: item["createDate"] as! String)
                        self.cartArray.append(product)
                        totalAmount += Int(product.amount) ?? 0
                    }
                    
                    DispatchQueue.main.async {
                        if(self.cartArray.count == 0){
                            self.btnOrder.isHidden = true
                            self.totalPriceLabel.text = ""
                        }else{
                            self.btnOrder.isHidden = false
                            self.totalPriceLabel.text = "Total price : \(totalAmount) ₺"
                        }
                        self.tableView.reloadData()
                    }
                } catch {}
            }
            task.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cartArray.count == 0 {
            tableView.setEmptyView(title: "Your card is empty",
                                           message: "Please choose a product and add it to the cart.")
            self.tableView.isHidden = false
        } else {
            tableView.restore()
        }
        return cartArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cart") as! CartCell
        let array = cartArray[indexPath.row]
        cell.productName.text = array.name
        cell.price.text = "\(array.amount) ₺"
        cell.productImage.kf.setImage(with: URL(string: array.photo))
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            let objID = self.cartArray[indexPath.row].id
            self.removeProduct(objID)
            self.cartArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteButton.backgroundColor = UIColor.red
        return [deleteButton]
    }
    
    func removeProduct(_ id:String){
        let userid = UserDefaults.standard.string(forKey: "userid")!
        let request = NSMutableURLRequest(url: URL(string: "\(Bundle.main.apiBaseURL)addCart.php")!)
        request.httpMethod = "POST"
        var isRemove = "1"
        let postString = "userid=\(userid)&productid=\(id)&remove=\(isRemove)"
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
            if(code == "200"){
                DispatchQueue.main.async {
                    self.getCart()
                }
            }else{
                self.showAlert(title: "Error", message: message ?? "")
            }
        }
        task.resume()
    }
    
    @IBAction func btnOrderButtonTapped(_ sender: Any) {
        let userid = UserDefaults.standard.string(forKey: "userid")!
        let request = NSMutableURLRequest(url: URL(string: "\(Bundle.main.apiBaseURL)order.php")!)
        request.httpMethod = "POST"
        let postString = "userid=\(userid)"
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
            if(code == "200"){
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "completeOrder", sender: self)
                }
            }else{
                self.showAlert(title: "Error", message: message ?? "")
            }
        }
        task.resume()
    }
}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x,
                                             y: self.center.y,
                                             width: self.bounds.size.width,
                                             height: self.bounds.size.height))
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .systemFont(ofSize: 17, weight: .medium)
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20)
        ])
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
