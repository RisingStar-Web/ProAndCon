//
//  ViewController.swift
//  ProAndCon
//
//  Created by Роман Кабиров on 10.12.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelEmpty: UILabel!
    
    // in-app purchase code start
    let FULL_PRODUCT_ID = "logicalmind.dev.ProAndCon.Full"
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    // in-app purchase code end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Data.load()

        Purchase.isFullVersionPurchased = UserDefaults.standard.bool(forKey: "FullUnlocked")
        fetchAvailableProducts()

        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.bottom = 100
        
        let runCnt = UserDefaults.standard.integer(forKey: "run-count") + 1
        if runCnt % 20 == 0 {
            SKStoreReviewController.requestReview()
        }
        UserDefaults.standard.set(runCnt, forKey: "run-count")
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueQuestionView" {
            if (!Purchase.isFullVersionPurchased) && (Data.questions.count > 2) && (Purchase.productPriceStr != "") {
                purchaseFullVersion(self)
                return false
            }
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = Data.questions.count == 0
        labelEmpty.isHidden = Data.questions.count > 0
        tableView.reloadData()
    }
    
    @IBAction func unwindToMain(_ sender: UIStoryboardSegue) { }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as? HistoryTableViewCell else { return UITableViewCell() }
        
        let q = Data.questions[indexPath.row]
        cell.load(date: q.date!, name: q.questionText!, result: q.result!)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let c = storyboard?.instantiateViewController(withIdentifier: "FinalViewController") as? FinalViewController else { return }
        guard indexPath.row >= 0 else { return }
        c.question = Data.questions[indexPath.row]
        present(c, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Data.questions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.isHidden = Data.questions.count == 0
            labelEmpty.isHidden = Data.questions.count > 0
            Data.save()
        }
    }

}
