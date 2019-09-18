//
//  QuestionViewController.swift
//  ProAndCon
//
//  Created by Роман Кабиров on 10.12.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet weak var textViewQuestion: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewAlign: NSLayoutConstraint!
    var topMargin: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewQuestion.delegate = self
        textViewQuestion.text = ""
        textViewQuestion.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        self.view.addGestureRecognizer(tap)
        
        topMargin = -UIScreen.main.bounds.height * 0.1
        contentViewAlign.constant = topMargin
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if contentViewAlign.constant != topMargin {
            UIView.animate(withDuration: 1.0, animations: {
                self.contentViewAlign.constant = self.topMargin
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 1.0, animations: {
            self.contentViewAlign.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        textViewQuestion.centerVertically()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueArgumentView" {
            if textViewQuestion.text == "" {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueArgumentView" {
            if let v = segue.destination as? ArgumentViewController {
                let q = Question(textViewQuestion.text)
                v.question = q
            }
        }
    }
    
    @IBAction func viewTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
extension QuestionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.centerVertically()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
