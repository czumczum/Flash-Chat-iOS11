//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK: - Instance variables
    var messageArray : [Message] = [Message] ()
    

    //MARK: - Outlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    //MARK: - Loading the view methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        
        
        //tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        
        //adding custom cells' layout
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String? {
            cell.messageBackground.backgroundColor = UIColor(gradientStyle : UIGradientStyle.topToBottom,
                                           withFrame : CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height),
                                           andColors:[UIColor.flatSkyBlue(), UIColor.flatMint()])
            cell.avatarImageView.backgroundColor = UIColor.flatPlum()
        } else {
            cell.messageBackground.backgroundColor = UIColor(gradientStyle : UIGradientStyle.topToBottom,
                                                             withFrame : CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height),
                                                             andColors:[UIColor.flatGray(), UIColor.flatSand()])
             cell.avatarImageView.backgroundColor = UIColor.flatLime()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendPressed(self)
        return true
    }
    
    ///////////////////////////////////////////
    
    
    //tableViewTapped method for custom Gesture
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    //configureTableView
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    //MARK: - TextField Delegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        SVProgressHUD.show()
        
        
        //MARK: Send the message to Firebase and save it in the database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                  "MessageBody": messageTextfield.text!]
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, refrence) in
            if error != nil {
                print("error")
                SVProgressHUD.dismiss()
            } else {
                print("Message sent succesfuly")
                SVProgressHUD.dismiss()
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""

            }
        }
        
        
    }
    
    //MARK: - retrieveMessages method
    func retrieveMessages() {
        let messagesDB = Database.database().reference().child("Messages")
        messagesDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
            
            self.scrolltoBottom()
        }
    }
    
    
    func scrolltoBottom() {
        let sectionIndex = self.messageTableView.numberOfSections - 1
        let itemIndex = self.messageTableView.numberOfRows(inSection: sectionIndex) - 1
        let lastIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
        messageTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
    }

     ///////////////////////////////////////////
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("There was an error")
        }
        
    }
    


}
