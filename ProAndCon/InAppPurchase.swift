//
//  InAppPurchase.swift
//  PowerliftingStats
//
//  Created by Роман Кабиров on 11.10.17.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import Foundation
import StoreKit

struct Purchase {
    static var isFullVersionPurchased: Bool = false
    static var productPriceStr: String = ""
}

extension ViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {

    func purchaseFullVersion(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "Pros and Cons".localized, message: "Buy coffee for the developer (once)?".localized + " " + Purchase.productPriceStr, preferredStyle: .alert)
        let buyAction = UIAlertAction(title: "Buy coffee".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
            self.purchaseMyProduct(product: self.iapProducts[0])
        }
        
        let restore = UIAlertAction(title: "Restore purchase".localized, style: .default, handler: {(_) in
            self.restorePurchase()
        })
        
        let cancelAction = UIAlertAction(title: "Next time".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            viewController.performSegue(withIdentifier: "segueQuestionView", sender: viewController)
        }
        
        alert.addAction(buyAction)
        alert.addAction(restore)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion:nil)
    }
    
    func fetchAvailableProducts()  {
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:
            FULL_PRODUCT_ID
        )
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    
    func restorePurchase() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Purchase.isFullVersionPurchased = true
        UserDefaults.standard.set(Purchase.isFullVersionPurchased, forKey: "FullUnlocked")
        /*
         UIAlertView(title: "Powerlift Stats",
         message: "You've successfully restored your purchase!",
         delegate: nil, cancelButtonTitle: "OK").show()
         */
    }
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            iapProducts = response.products
            
            let secondProd = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            
            // Get its price from iTunes Connect
            numberFormatter.locale = secondProd.priceLocale
            let price2Str = numberFormatter.string(from: secondProd.price)
            
            // Show its description
            // Purchase.productPriceStr = secondProd.localizedDescription + "\nfor  \(price2Str!)"
            Purchase.productPriceStr = "\(price2Str!)"
        }
    }
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            productID = product.productIdentifier
        } else {
            let alert = UIAlertController(title: "Pros and Cons", message: "Purchases are disabled on your device!".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                // print("OK")
            })
            present(alert, animated: true)
        }
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                Purchase.isFullVersionPurchased = true
                UserDefaults.standard.set(Purchase.isFullVersionPurchased, forKey: "FullUnlocked")

                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if productID == FULL_PRODUCT_ID {
                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        Purchase.isFullVersionPurchased = true
                        UserDefaults.standard.set(Purchase.isFullVersionPurchased, forKey: "FullUnlocked")
                        
                        let alert = UIAlertController(title: "Pros and Cons", message: "You've successfully unlocked the full version".localized, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            print("OK")
                        })
                        present(alert, animated: true)
                        
                    }
                    
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }

    
}
