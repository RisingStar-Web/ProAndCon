//
//  ArgumentViewController.swift
//  ProAndCon
//
//  Created by Роман Кабиров on 10.12.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit

class ArgumentViewController: UIViewController {

    @IBOutlet weak var textViewArgument: UITextView!
    @IBOutlet weak var labelImportance: UILabel!
    @IBOutlet weak var sliderImportance: UISlider!
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var labelCounts: UILabel!
    
    var question: Question?
    var editMode = false
    
    var removeFromProsIndex: Int = -1
    var removeFromConsIndex: Int = -1
    var editArgument: Argument?

    override func viewDidLoad() {
        super.viewDidLoad()
        textViewArgument.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        self.view.addGestureRecognizer(tap)
        labelQuestion.text = question?.questionText
        if let ea = editArgument {
            textViewArgument.text = ea.name
            sliderImportance.value = Float(ea.weight!)
        } else {
            textViewArgument.text = ""
            sliderImportance.value = 2.0
        }
        updateCounts()
    }
    
    @IBAction func viewTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        textViewArgument.centerVertically()
    }

    @IBAction func sliderChanged(_ sender: Any) {
        labelImportance.text = "Importance:".localized + " \(Int(sliderImportance.value + 0.5))"
    }
    
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFinalView" {
            // Data.questions.append(question!)
            if let ea = editArgument {
                ea.name = textViewArgument.text
                ea.weight = Int(sliderImportance.value + 0.5)
            }
            
            question?.calculateResult()
            if !editMode {
                Data.questions.insert(question!, at: 0)
            }
            Data.save()
            if let c = segue.destination as? FinalViewController {
                c.question = question
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "unwindToMain") && (editMode) {
            dismiss(animated: true, completion: nil)
            return false
        }
        return true
    }
    
    @IBAction func buttonDislikeTap(_ sender: Any) {
        guard textViewArgument.text != "" else { return }
        var doDismiss = false
        if removeFromProsIndex >= 0 {
            question?.pros.remove(at: removeFromProsIndex)
            removeFromProsIndex = -1
            doDismiss = true
        }
        if removeFromConsIndex >= 0 {
            question?.cons.remove(at: removeFromConsIndex)
            removeFromConsIndex = -1
            doDismiss = true
        }

        let c = Argument(name: textViewArgument.text, weight: Int(sliderImportance.value + 0.5))
        question?.cons.append(c)
        textViewArgument.text = ""
        sliderImportance.value = 2
        updateCounts()
        if doDismiss {
            dismiss(animated: true, completion: nil)
            return
        }
        textViewArgument.becomeFirstResponder()
    }
    
    @IBAction func buttonLikeTap(_ sender: Any) {
        guard textViewArgument.text != "" else { return }
        var doDismiss = false

        if removeFromProsIndex >= 0 {
            question?.pros.remove(at: removeFromProsIndex)
            removeFromProsIndex = -1
            doDismiss = true
        }
        if removeFromConsIndex >= 0 {
            question?.cons.remove(at: removeFromConsIndex)
            removeFromConsIndex = -1
            doDismiss = true
        }
        
        let p = Argument(name: textViewArgument.text, weight: Int(sliderImportance.value + 0.5))
        question?.pros.append(p)
        textViewArgument.text = ""
        sliderImportance.value = 2
        updateCounts()
        if doDismiss {
            dismiss(animated: true, completion: nil)
            return
        }
        textViewArgument.becomeFirstResponder()
    }
    
    func updateCounts() {
        let prosCount = (question?.pros.count)!
        let consCount = (question?.cons.count)!
        labelCounts.text = "Pros: ".localized + String(prosCount) + ", cons: ".localized + String(consCount)
        labelImportance.text = "Importance:".localized + " \(Int(sliderImportance.value + 0.5))"
    }
    
}

extension ArgumentViewController: UITextViewDelegate {
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

