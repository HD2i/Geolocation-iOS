//
//  CreateImportWalletViewController.swift
//  Geolocation
//
//  Adapted from PeepethClient by Matter, Inc.
//  Obtained from: https://github.com/matterinc/PeepethClient
//  Obtained on: 01/4/19
//
//  Created by Matt Johnson on 1/4/19.
//  Copyright © 2018 Matt Johnson. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    @IBOutlet weak var createWalletButton: UIButton!
    @IBOutlet weak var importWalletButton: UIButton!
    @IBOutlet weak var wannabetLogo: UIImageView!
    
    var newWalletType: CreationType = .createWallet

    override func viewDidLoad() {
        super.viewDidLoad()
        wannabetLogo.tintColor = UIColor(red:0.79, green:0.62, blue:0.40, alpha:1.0)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createWalletTapped(_ sender: Any) {
        newWalletType = .createWallet
    }
    
    @IBAction func importWalletTapped(_ sender: Any) {
        newWalletType = .importWallet

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createWalletController = segue.destination as? WalletGenerationViewController {
            createWalletController.creationType = newWalletType
        }
    }

}
