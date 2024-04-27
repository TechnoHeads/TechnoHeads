//
//  BaseViewController.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 14.04.2024.
//


import UIKit

class BaseViewController: UIViewController {
    
    var addCloseButton : Bool = false
    @objc var closeButtonAction : (() -> ())?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Creation
    class var storyboardName: String {
        return String(describing: self)
    }
    
    class func createFromStoryboard() -> Self {
        return createFromStoryboard(named: storyboardName, type: self)
    }
    
    static func createFromStoryboard<T: BaseViewController>(named storyboardName: String?, type: T.Type) -> T {
        return UIStoryboard(name: storyboardName ?? self.storyboardName, bundle: Bundle.main).instantiateInitialViewController() as! T
    }
    
    //MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if addCloseButton == true {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(BaseViewController.closeButtonTapped))
        }
    }
    
    @objc func closeButtonTapped(){
        if let action = self.closeButtonAction {
            action()
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var eventName = (String(describing: type(of: self)))
        if eventName.count >= 40 {
            eventName = eventName.replacingOccurrences(of: "ViewController", with: "VC")
            if eventName.count >= 40 {
                let index = eventName.index(eventName.startIndex, offsetBy: 40)
                eventName = String(eventName[..<index])
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func showAlert(title:String, message:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlert(title: String, message: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
}

//MARK: - Pop and Dismiss
extension BaseViewController {
    
    @IBAction func pop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
