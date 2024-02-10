//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        Message(sender: "1@2.com", body: "Hey!"),
        Message(sender: "a@12.com", body: "Hello!"),
        Message(sender: "sanil@123.com", body: "What's up?")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerXIB()
        navigationItem.hidesBackButton = true
        title = K.appName
        tableView.dataSource = self
        loadMessages()
    }
    
    func loadMessages() {
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapShot, error) in
            if let error = error {
                print("Not able to get data from firestore!!! \(error)")
            } else {
                self.messages.removeAll()
                if let snapShotDocuments = querySnapShot?.documents {
                    for doc in snapShotDocuments {
                        let data = doc.data()
                        if let body = data[K.FStore.bodyField] as? String, let sender = data[K.FStore.senderField] as? String, !body.isEmpty, !sender.isEmpty {
                            let message = Message(sender: sender, body: body)
                            self.messages.append(message)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
//        db.collection(K.FStore.collectionName).getDocuments { (querySnapShot, error) in
//            if let error = error {
//                print("Not able to get data from firestore!!! \(error)")
//            } else {
//                if let snapShotDocuments = querySnapShot?.documents {
//                    for doc in snapShotDocuments {
//                        let data = doc.data()
//                        if let body = data[K.FStore.bodyField] as? String, let sender = data[K.FStore.senderField] as? String, !body.isEmpty, !sender.isEmpty {
//                            let message = Message(sender: sender, body: body)
//                            self.messages.append(message)
//                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email, !messageBody.isEmpty, !messageSender.isEmpty {
            db.collection(K.FStore.collectionName).addDocument(data:
                [K.FStore.senderField: messageSender,
                 K.FStore.bodyField: messageBody,
                 K.FStore.dateField: Date().timeIntervalSince1970
                ]) { (error) in
                if let error = error {
                    print("There was an issue saving data to firestore, \(error)")
                } else {
                    self.messageTextfield.text = ""
                    print("Successfully saved data.")
                }
            }
        }
    }
    
    @IBAction func onClickLogOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func registerXIB() {
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].body
        return cell
    }
}
