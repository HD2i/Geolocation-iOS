//
//  ProfileViewController.swift
//  WannaBet
//
//  Created by Matt Johnson on 11/29/18.
//  Copyright © 2018 Matt Johnson. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import QRCoder

class ProfileViewController: UIViewController {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UITextView!
    @IBOutlet weak var publicKeyQRImageView: UIImageView!
    @IBOutlet weak var amountBet: UILabel!
    @IBOutlet weak var gamesLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var lossesLabel: UILabel!
    @IBOutlet weak var betBackground: UIImageView!
    @IBOutlet weak var gamesBackground: UIImageView!
    @IBOutlet weak var agreeBackground: UIImageView!
    @IBOutlet weak var disagreeBackground: UIImageView!
    
    
    let service = Web3swiftService()
    let keysService = KeysService()
    let localDatabase = LocalDatabase()
    let alerts = Alerts()
    var myAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideSelectionWhenTappedAround()
        getUntrustedAddress()
        service.getETHbalance { (result, _) in
            DispatchQueue.main.async {
                let ethUnits = Web3Utils.formatToEthereumUnits(result!, toUnits: .eth, decimals: 6, decimalSeparator: ".")
                self.balanceLabel.text = "DEV Balance: \n" + ethUnits!
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
   
    
    func getUntrustedAddress() {
        let generator = QRCodeGenerator()
        //Default correction level is M
        generator.correctionLevel = .H
        
        service.getUntrustedAddress(completion: { (address) in
            DispatchQueue.main.async {
                if address != nil {
                    self.myAddress = address
                    self.addressLabel.text = "Address: \n\(address!)"
                    let image: QRImage = generator.createImage(value: address!, size: self.publicKeyQRImageView.frame.size)!
                    self.publicKeyQRImageView.image = image
                    
                } else {
                    self.getUntrustedAddress()
                }
            }
            
        })
    }
    
    func privateKeyAlert(privateKey: String) {
        let alert = UIAlertController(title: "Private key", message: privateKey, preferredStyle: UIAlertController.Style.alert)
        
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (_) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = privateKey
        }
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel) { (_) in
        }
        alert.addAction(copyAction)
        alert.addAction(closeAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func showPrivateKey(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Show private key", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter your password"
        }
        
        let enterPasswordAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            let passwordTextField = alert.textFields![0] as UITextField
            if let privateKey = self.keysService.getWalletPrivateKey(password: passwordTextField.text!) {
                self.privateKeyAlert(privateKey: privateKey)
                
            } else {
                self.alerts.show("Wrong Password", with: "Wrong Password", for: self)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        
        alert.addAction(enterPasswordAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func switchNetwork(_ sender: Any) {
        
    }
    
    
   
    
    
   
    @IBAction func logout(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you would like to log out? You will have to create a new wallet or import an existing one again.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            
        
        self.localDatabase.deleteWallet { (error) in
            if error == nil {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

                let landingViewController = mainStoryboard.instantiateViewController(withIdentifier: "landing") as! LandingViewController
                self.present(landingViewController, animated: false, completion: nil)
            } else {
                self.alerts.show(error, for: self)
            }
        }
        }
        alert.addAction(cancel)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    @IBAction func addBalance(_ sender: Any) {
        let alert = UIAlertController(title: "Add Balance to your Wallet?", message: "Clicking Ok will open a link to the Oasis Devnet Faucet in Safari and copy your wallet address to your pasteboard for signup.", preferredStyle: .alert)

        let enterPasswordAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.myAddress!
            guard let url = URL(string: "https://faucet.oasiscloud.io/") else { return }
            UIApplication.shared.open(url)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        
        alert.addAction(enterPasswordAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
       
    }
    
}
