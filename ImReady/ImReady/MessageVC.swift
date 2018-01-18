//
//  MessageVC.swift
//  ImReady
//
//  Created by Inholland on 12/13/17.
//  Copyright © 2017 Inholland. All rights reserved.
//

import UIKit

class MessageVC: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var messageId: String!
    var message: Message!
    var messages: [Message] = []
    var currentUser = LoggedInUser().getLoggedInUser()
    var chats : [Chat] = []
    var chat = Chat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension
        sendButton.layer.cornerRadius = 5.0
        loadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(messages.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Message") as? MessagesCell {
            cell.configCell(message: message)
            
            return(cell)
        }
        
        else {
            return MessagesCell()
        }
    }
    
    private func loadData() {
        if(currentUser.user_type == .Client) {
            activateIndicator_Activity(onViewController: self, onView: view)
            chatService.getOrCreateChat(ofSenderId: currentUser.id!,
                                        toReceiverId: currentUser.caretakerId!,
                                        onSuccess: { (chat) in
                                            self.chat = chat
                                            self.messages = self.chat.messages
                                            self.tableView.reloadData()
                                            deactivateIndicator_Activity()
                },
                                        onFailure: {
                                            print("Could not retrieve or create chat")
                                            deactivateIndicator_Activity()
                                            
            })
        }
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        activateIndicator_Activity(onViewController: self, onView: view)
        message = Message()
        
        if(textField.text != "") {
            message.content = textField.text!
            message.senderId = currentUser.id!
            
            if(chat.receiverId == currentUser.id) {
                message.receiverId = chat.senderId
            }
            else { message.receiverId = chat.receiverId }
            
            textField.text = ""
            
            chatService.send(sentMessage: message,
                             onSuccess: { (message) in
                                self.chat.messages.append(message)
                                self.messages = self.chat.messages
                                self.tableView.reloadData()
                                deactivateIndicator_Activity()
                },
                             onFailure: {
                                print("Could not send message")
                                deactivateIndicator_Activity()
                                
            })
            
        }
    }
}
