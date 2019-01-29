//
//  Web3SwiftService.swift
//  Geolocation
//
//  Adapted from PeepethClient by Matter, Inc.
//  Obtained from: https://github.com/matterinc/PeepethClient
//  Obtained on: 01/21/19
//
//  Created by Matt Johnson on 1/21/19.
//  Copyright © 2018 Matt Johnson. All rights reserved.
//



import Foundation
import Web3swift
import EthereumAddress
import BigInt

class Web3swiftService {
    
    static let localStorage = LocalDatabase()
    static let keyservice = KeysService()
    
    static var web3instance: web3 {
        let web3 = Web3.new(URL(string: "https://web3.oasiscloud.io")!)!
        web3.addKeystoreManager(self.keyservice.keystoreManager()!)
        return web3
    }
    
    static var oasisBlockExplorerString: String {
        return "https://blockexplorer.oasiscloud.io/tx/"
    }
        
    static var currentAddress: EthereumAddress? {
        let wallet = self.keyservice.selectedWallet()
        guard let address = wallet?.address else { return nil }
        let ethAddressFrom = EthereumAddress(address)
        return ethAddressFrom
    }
    
    static var geoLocationContract: web3.web3contract? {
        do {
            let contract = try Web3swiftService.web3instance.contract(geoABI, at: ethContractAddress)
            return contract
        } catch {
            return nil
        }
    }
    
    
    func isEthAddressValid(address: String)->Bool{
        if EthereumAddress(address) != nil{
            return true
        }
        return false
    }
    
    /***************************
     Participant Methods
     **************************/
    func getParticipantID(completion: @escaping ([String: Any]) -> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
        
        DispatchQueue.global().async {
            
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeystoreManager.defaultManager)
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethContractAddress
            options.value = 0 // or any other value you want to send
            
            guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.method("getParticipantID", transactionOptions: options) else {return}
            let result = try? transaction.call(transactionOptions: options)
            DispatchQueue.main.async {
                completion(result ?? [:])
            }
        }
    }
    
    
    func getShareStatus(completion: @escaping ([String: Any]) -> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
        
        DispatchQueue.global().async {
            
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeystoreManager.defaultManager)
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethContractAddress
            options.value = 0 // or any other value you want to send
            
            guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.method("getParticipantSharingStatus", transactionOptions: options) else {return}
            let result = try? transaction.call(transactionOptions: options)
            DispatchQueue.main.async {
                completion(result ?? [:])
            }
        }
    }

    func setSharingStatus(enableSharing: Bool, password: String, completion: @escaping (TransactionSendingResult?) -> Void)  {
        DispatchQueue.global().async {
            var options = TransactionOptions.defaultOptions
            options.callOnBlock = .pending
            options.nonce = .pending
            options.gasLimit = .automatic
            options.gasPrice = .automatic
            options.from = EthereumAddress(KeysService().selectedWallet()!.address)!
            
            guard let contractAddressLocal = EthereumAddress(contractAddress) else {return}
            guard let amount = Web3.Utils.parseToBigUInt("0", units: .eth) else {return}
            guard let selectedKey = KeysService().selectedWallet()?.address else {return}
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeysService().keystoreManager())
            guard let ethAddressFrom = EthereumAddress(selectedKey) else {return}
            guard let contract = web3.contract(geoABI, at: contractAddressLocal, abiVersion: 2) else {return}
            let params: [AnyObject] = [] as [AnyObject]
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            guard let writeTX = contract.write("postParticipantSharingPreference",
                                               parameters: params,
                                               transactionOptions: options) else {
                                                completion(nil)
                                                return}
            writeTX.transactionOptions.from = ethAddressFrom
            writeTX.transactionOptions.value = amount
            
            let result = try? writeTX.send(password: password, transactionOptions: options)
            DispatchQueue.main.async {
                completion(result)
            }
            return
        }
    }
    
    func getNumberOfParticipantsLocations(completion: @escaping ([String: Any]) -> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}

        DispatchQueue.global().async {

            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeystoreManager.defaultManager)
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethContractAddress
            options.value = 0 // or any other value you want to send
            
            guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.method("getParticipantNumberOfLocations", transactionOptions: options) else {return}
            let result = try? transaction.call(transactionOptions: options)
            DispatchQueue.main.async {
                completion(result ?? [:])
            }
        }
    }
    
    func getEachDateTime(index: BigUInt, completion: @escaping ([String:Any])-> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
        
        DispatchQueue.global().async {

        let web3 = Web3swiftService.web3instance
        web3.addKeystoreManager(KeystoreManager.defaultManager)
        
        var options = TransactionOptions.defaultOptions
        options.from = ethAddressFrom
        options.to = ethContractAddress
        options.value = 0 // or any other value you want to send
        
        guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
        options.gasPrice = TransactionOptions.GasPricePolicy.automatic
        options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
        contract.transactionOptions = options
        guard let transaction = contract.read("getParticipantDateTimeOfLocation", parameters: [index] as [AnyObject], transactionOptions: options) else { return}
        let result = try? transaction.call(transactionOptions: options)
        DispatchQueue.main.async {
            completion(result ?? [:])
        }
        }
    }
    
    func getParticipantCategory(dateTime: BigUInt, completion: @escaping ([String:Any])-> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
        
        DispatchQueue.global().async {
            
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeystoreManager.defaultManager)
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethContractAddress
            options.value = 0 // or any other value you want to send
            
            guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.read("getParticipantCategory", parameters: [dateTime] as [AnyObject], transactionOptions: options) else { return}
            let result = try? transaction.call(transactionOptions: options)
            DispatchQueue.main.async {
                completion(result ?? [:])
            }
        }
        
    }
    
    
    
    func postParticipantLocation(dateTime: TimeInterval, lat: Double, long: Double, password: String, completion: @escaping (TransactionSendingResult?) -> Void) {
        DispatchQueue.global().async {
            let date = BigUInt(round(dateTime))
            let latitude = lat.convertCoordinate(toDecimals: 4)
            let longitude = long.convertCoordinate(toDecimals: 4)
            var options = TransactionOptions.defaultOptions
            options.callOnBlock = .pending
            options.nonce = .pending
            options.gasLimit = .automatic
            options.gasPrice = .automatic
            options.from = EthereumAddress(KeysService().selectedWallet()!.address)!
            
            guard let contractAddressLocal = EthereumAddress(contractAddress) else {return}
            guard let amount = Web3.Utils.parseToBigUInt("0", units: .eth) else {return}
            guard let selectedKey = KeysService().selectedWallet()?.address else {return}
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeysService().keystoreManager())
            guard let ethAddressFrom = EthereumAddress(selectedKey) else {return}
            guard let contract = web3.contract(geoABI, at: contractAddressLocal, abiVersion: 2) else {return}
            let params: [AnyObject] = [date, latitude, longitude] as [AnyObject]
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            guard let writeTX = contract.write("postParticipantLocation",
                                               parameters: params,
                                               transactionOptions: options) else {
                                                completion(nil)
                                                return}
            writeTX.transactionOptions.from = ethAddressFrom
            writeTX.transactionOptions.value = amount
            
            let result = try? writeTX.send(password: password, transactionOptions: options)
            DispatchQueue.main.async {
                completion(result)
            }
            return
        }
    }
    
    /***************************
     Third Party Methods
     **************************/
    
    func getNumberOfParticipants(completion: @escaping ([String: Any]) -> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
        
        DispatchQueue.global().async {
          
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeystoreManager.defaultManager)
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethContractAddress
            options.value = 0 // or any other value you want to send
            
            guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.method("numberOfParticipants", transactionOptions: options) else {return}
            let result = try? transaction.call(transactionOptions: options)
            DispatchQueue.main.async {
                completion(result ?? [:])
            }
        }
    }
    
    func getNumberOfLocations(participantID: BigUInt, completion: @escaping ([String: Any]) -> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
        
        DispatchQueue.global().async {
            
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeystoreManager.defaultManager)
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethContractAddress
            options.value = 0 // or any other value you want to send
            
            guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.method("getNumberOfLocations", parameters: [participantID as AnyObject], transactionOptions: options) else {return}
            let result = try? transaction.call(transactionOptions: options)
            DispatchQueue.main.async {
                completion(result ?? [:])
            }
        }
    }
    
    func getStatusOfParticipant(participantID: BigUInt, completion: @escaping ([String: Any]) -> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
        
        DispatchQueue.global().async {
            
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeystoreManager.defaultManager)
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethContractAddress
            options.value = 0 // or any other value you want to send
            
            guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.method("getSharingEnabled", parameters: [participantID as AnyObject], transactionOptions: options) else {return}
            let result = try? transaction.call(transactionOptions: options)
            DispatchQueue.main.async {
                completion(result ?? [:])
            }
        }
    }
    
    func postPOI(category: Int, lat: Double, long: Double, password: String, completion: @escaping (TransactionSendingResult?) -> Void) {
        DispatchQueue.global().async {
            let category = Int(category)
            let latitude = lat.convertCoordinate(toDecimals: 4)
            let longitude = long.convertCoordinate(toDecimals: 4)
            var options = TransactionOptions.defaultOptions
            options.callOnBlock = .pending
            options.nonce = .pending
            options.gasLimit = .automatic
            options.gasPrice = .automatic
            options.from = EthereumAddress(KeysService().selectedWallet()!.address)!
            
            guard let contractAddressLocal = EthereumAddress(contractAddress) else {return}
            guard let amount = Web3.Utils.parseToBigUInt("0", units: .eth) else {return}
            guard let selectedKey = KeysService().selectedWallet()?.address else {return}
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeysService().keystoreManager())
            guard let ethAddressFrom = EthereumAddress(selectedKey) else {return}
            guard let contract = web3.contract(geoABI, at: contractAddressLocal, abiVersion: 2) else {return}
            let params: [AnyObject] = [category, latitude, longitude] as [AnyObject]
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            guard let writeTX = contract.write("postPOI",
                                               parameters: params,
                                               transactionOptions: options) else {
                                                completion(nil)
                                                return}
            writeTX.transactionOptions.from = ethAddressFrom
            writeTX.transactionOptions.value = amount
            
            let result = try? writeTX.send(password: password, transactionOptions: options)
            DispatchQueue.main.async {
                completion(result)
            }
            return
        }
    }
    
    func getCategory(paticipantID: BigUInt, dateTime: BigUInt, completion: @escaping ([String:Any])-> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
        
        DispatchQueue.global().async {
            
            let web3 = Web3swiftService.web3instance
            web3.addKeystoreManager(KeystoreManager.defaultManager)
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethContractAddress
            options.value = 0 // or any other value you want to send
            
            guard let contract = web3.contract(geoABI, at: ethContractAddress, abiVersion: 2) else {return}
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.read("getCategory", parameters: [dateTime] as [AnyObject], transactionOptions: options) else { return}
            let result = try? transaction.call(transactionOptions: options)
            DispatchQueue.main.async {
                completion(result ?? [:])
            }
        }
    }

    
    //MARK: - Get untrusted address
    func getUntrustedAddress(completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            let wallet = Web3swiftService.keyservice.localStorage.getWallet()
            guard let address = wallet?.address else {
                completion(nil)
                return
            }
            completion(address)
        }
    }
    
    // MARK: - Get ETH balance
    func getETHbalance(completion: @escaping (BigUInt?, Error?) -> Void) {
            let wallet = Web3swiftService.keyservice.localStorage.getWallet()
        DispatchQueue.global().async {

            guard let address = wallet?.address else {
                return
            }
            let ETHaddress = EthereumAddress(address)
            let web3Main = Web3swiftService.web3instance
            do {
                let balanceResult = try web3Main.eth.getBalance(address: ETHaddress!)
                
                completion(balanceResult, nil)
            }
            catch{
                return
            }
           
        }
    }
   
    
    
}

enum Result<T> {
    case Success(T)
    case Error(Error)
}
