//
//  Profile.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 14.04.2024.
//

import UIKit

class Profile: BaseViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var inLoginView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnOrder: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if (UserDefaults.standard.string(forKey: "Login") != nil && UserDefaults.standard.string(forKey: "Login") == "true"){
            inLoginView.isHidden = false
            loginView.isHidden = true
            DispatchQueue.main.async {
                self.profileName.text = UserDefaults.standard.string(forKey: "name")
                self.profileImage.kf.setImage(with: URL(string: UserDefaults.standard.string(forKey: "photo") ?? ""))
            }
        }else{
            inLoginView.isHidden = true
            loginView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        btnLogout.layer.cornerRadius = btnLogout.frame.height / 2
        btnLogout.clipsToBounds = true
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2
        btnLogin.clipsToBounds = true
        btnOrder.layer.cornerRadius = btnOrder.frame.height / 2
        btnOrder.layer.borderWidth = 0.8
        btnOrder.layer.borderColor = UIColor.black.cgColor
        btnOrder.clipsToBounds = true
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let request = NSMutableURLRequest(url: URL(string: "\(Bundle.main.apiBaseURL)login.php")!)
        request.httpMethod = "POST"
        let postString = "email=\(email.text!)&password=\(password.text!)"
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
                    self.profileName.text = name ?? ""
                    self.profileImage.kf.setImage(with: URL(string: photo!))
                    self.login(userid: userid ?? "",name: name ?? "", photo: photo ?? "")
                }
            }else{
                self.showAlert(title: "Error", message: message ?? "")
            }
        }
        task.resume()
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        logout()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func login(userid:String,name:String, photo:String){
        loginView.isHidden = true
        inLoginView.isHidden = false
        UserDefaults.standard.setValue("true", forKey: "Login")
        UserDefaults.standard.setValue(userid, forKey: "userid")
        UserDefaults.standard.setValue(name, forKey: "name")
        UserDefaults.standard.setValue(photo, forKey: "photo")
        UserDefaults.standard.synchronize()
    }
    
    func logout(){
        email.text = ""
        password.text = ""
        loginView.isHidden = false
        inLoginView.isHidden = true
        UserDefaults.standard.setValue(nil, forKey: "Login")
        UserDefaults.standard.setValue(nil, forKey: "userid")
        UserDefaults.standard.synchronize()
    }
    
}
