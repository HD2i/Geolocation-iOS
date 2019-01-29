//
//  WalletGenerationController.swift
//  WannaBet
//
//  Created by Matt Johnson on 11/27/18.
//  Copyright © 2018 Matt Johnson. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress

class WalletGenerationController {
    
    let localStorage = LocalDatabase()
    let keysService: KeysService = KeysService()
    let web3service: Web3swiftService = Web3swiftService()
    
    func createWallet(with mode: CreationType,
                      password: String?,
                      key: String?,
                      completion: @escaping (Error?) -> Void) {
        guard let password = password else {
            completion(Errors.noPassword)
            return
        }
        switch mode {
        case .createWallet:
            keysService.createNewWallet(password: password) { (wallet, error) in
                if let error = error {
                    completion(error)
                } else {
                    self.localStorage.saveWallet(isRegistered: false, wallet: wallet!) { (error) in
                        completion(error)
                    }
                }
            }
        case .importWallet:
            guard let key = key else {
                completion(Errors.noKey)
                return
            }
            keysService.addNewWalletWithPrivateKey(key: key, password: password) { (wallet, error) in
                if let error = error {
                    completion(error)
                } else {
                    let walletStrAddress = wallet?.address
                    let walletAddress = EthereumAddress(walletStrAddress!)

                    self.localStorage.saveWallet(isRegistered: true, wallet: wallet!) { (error) in
                                completion(error)
                            }
                }
            }
        }
    }
}
