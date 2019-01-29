//
//  Alerts.swift
//  WannaBet
//
//  Created by Matt Johnson on 11/29/18.
//  Copyright © 2018 Matt Johnson. All rights reserved.
//

import UIKit

class Alerts {
    func show(_ error: Error?, for controller: UIViewController) {
        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    func show(_ title: String?, with message: String?, for controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showTx(_ title: String?, txhash: String, with message: String?, for controller: UIViewController, dismissOnCompletion: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let oasisBlockExplorerLink = UIAlertAction(title: "Check in Oasis Block Explorer", style: .default, handler: { (action:UIAlertAction!) -> Void in
            UIApplication.shared.open(URL(string: "\(Web3swiftService.oasisBlockExplorerString)\(txhash)")!, options: [:], completionHandler: nil)
        })
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            if dismissOnCompletion {
                controller.dismiss(animated: true, completion: nil)
            }
        })
        alert.addAction(oasisBlockExplorerLink)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    
}
