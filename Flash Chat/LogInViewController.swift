//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD


class LogInViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - LogIn functions
    @IBAction func logInPressed(_ sender: AnyObject) {
        
        //MARK: loading indicator
        SVProgressHUD.show()

        //MARK: DB auth
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print("There was some errors!")
                print(error!)
            } else {
                print("Login succesful!")
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
        
    }
    


    
}  
