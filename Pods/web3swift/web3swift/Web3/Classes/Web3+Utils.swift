//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift
import SwiftRLP
import secp256k1_swift
import EthereumAddress

public typealias Web3Utils = Web3.Utils

extension Web3 {
    
    /// Namespaced Utils functions. Are not bound to particular web3 instance, so capitalization matters.
    public struct Utils {
        
        typealias Iban = IBAN
    }
}

extension Web3.Utils {
    
    /// Calculate address of deployed contract deterministically based on the address of the deploying Ethereum address
    /// and the nonce of this address
    public static func calcualteContractAddress(from: EthereumAddress, nonce: BigUInt) -> EthereumAddress? {
        guard let normalizedAddress = from.addressData.setLengthLeft(32) else {return nil}
        guard let data = RLP.encode([normalizedAddress, nonce] as [AnyObject]) else {return nil}
        guard let contractAddressData = Web3.Utils.sha3(data)?[12..<32] else {return nil}
        guard let contractAddress = EthereumAddress(Data(contractAddressData)) else {return nil}
        return contractAddress
    }
    
    /// Various units used in Ethereum ecosystem
    public enum Units {
        case eth
        case wei
        case Kwei
        case Mwei
        case Gwei
        case Microether
        case Finney
        
        var decimals:Int {
            get {
                switch self {
                case .eth:
                    return 18
                case .wei:
                    return 0
                case .Kwei:
                    return 3
                case .Mwei:
                    return 6
                case .Gwei:
                    return 9
                case .Microether:
                    return 12
                case .Finney:
                    return 15
                }
            }
        }
    }
    
    /// Precoded "cold wallet" (private key controlled) address. Basically - only a payable fallback function.
    public static var coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
    
    /// Precoded ERC20 contracts ABI. Output parameters are named for ease of use.
    public static var erc20ABI = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
    
    public static var erc721ABI = "[{\"constant\":true,\"inputs\":[{\"name\":\"interfaceID\",\"type\":\"bytes4\"}],\"name\":\"supportsInterface\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"_name\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"getApproved\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_approved\",\"type\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_index\",\"type\":\"uint256\"}],\"name\":\"tokenOfOwnerByIndex\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"safeTransferFrom\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_index\",\"type\":\"uint256\"}],\"name\":\"tokenByIndex\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"ownerOf\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"_symbol\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_operator\",\"type\":\"address\"},{\"name\":\"_approved\",\"type\":\"bool\"}],\"name\":\"setApprovalForAll\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_tokenId\",\"type\":\"uint256\"},{\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"safeTransferFrom\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"tokenURI\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_operator\",\"type\":\"address\"}],\"name\":\"isApprovedForAll\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_approved\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_operator\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_approved\",\"type\":\"bool\"}],\"name\":\"ApprovalForAll\",\"type\":\"event\"}]"
    public static var ensRegistryABI = """
[{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"resolver","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"label","type":"bytes32"},{"name":"owner","type":"address"}],"name":"setSubnodeOwner","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"ttl","type":"uint64"}],"name":"setTTL","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"ttl","outputs":[{"name":"","type":"uint64"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"resolver","type":"address"}],"name":"setResolver","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"owner","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"owner","type":"address"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":true,"name":"label","type":"bytes32"},{"indexed":false,"name":"owner","type":"address"}],"name":"NewOwner","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"resolver","type":"address"}],"name":"NewResolver","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"ttl","type":"uint64"}],"name":"NewTTL","type":"event"}]
"""

    //function setAddr(bytes32 node, address addr)
    public static var resolverABI = """
[
    {
        "constant": true,
        "inputs": [
            {
                "name": "interfaceID",
                "type": "bytes4"
            }
        ],
        "name": "supportsInterface",
        "outputs": [
            {
                "name": "",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "key",
                "type": "string"
            },
            {
                "name": "value",
                "type": "string"
            }
        ],
        "name": "setText",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "contentTypes",
                "type": "uint256"
            }
        ],
        "name": "ABI",
        "outputs": [
            {
                "name": "contentType",
                "type": "uint256"
            },
            {
                "name": "data",
                "type": "bytes"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "x",
                "type": "bytes32"
            },
            {
                "name": "y",
                "type": "bytes32"
            }
        ],
        "name": "setPubkey",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            }
        ],
        "name": "content",
        "outputs": [
            {
                "name": "",
                "type": "bytes32"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            }
        ],
        "name": "addr",
        "outputs": [
            {
                "name": "",
                "type": "address"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "key",
                "type": "string"
            }
        ],
        "name": "text",
        "outputs": [
            {
                "name": "",
                "type": "string"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "contentType",
                "type": "uint256"
            },
            {
                "name": "data",
                "type": "bytes"
            }
        ],
        "name": "setABI",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            }
        ],
        "name": "name",
        "outputs": [
            {
                "name": "",
                "type": "string"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "name",
                "type": "string"
            }
        ],
        "name": "setName",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "hash",
                "type": "bytes"
            }
        ],
        "name": "setMultihash",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "hash",
                "type": "bytes32"
            }
        ],
        "name": "setContent",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            }
        ],
        "name": "pubkey",
        "outputs": [
            {
                "name": "x",
                "type": "bytes32"
            },
            {
                "name": "y",
                "type": "bytes32"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            },
            {
                "name": "addr",
                "type": "address"
            }
        ],
        "name": "setAddr",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "node",
                "type": "bytes32"
            }
        ],
        "name": "multihash",
        "outputs": [
            {
                "name": "",
                "type": "bytes"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "name": "ensAddr",
                "type": "address"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "node",
                "type": "bytes32"
            },
            {
                "indexed": false,
                "name": "a",
                "type": "address"
            }
        ],
        "name": "AddrChanged",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "node",
                "type": "bytes32"
            },
            {
                "indexed": false,
                "name": "hash",
                "type": "bytes32"
            }
        ],
        "name": "ContentChanged",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "node",
                "type": "bytes32"
            },
            {
                "indexed": false,
                "name": "name",
                "type": "string"
            }
        ],
        "name": "NameChanged",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "node",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "name": "contentType",
                "type": "uint256"
            }
        ],
        "name": "ABIChanged",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "node",
                "type": "bytes32"
            },
            {
                "indexed": false,
                "name": "x",
                "type": "bytes32"
            },
            {
                "indexed": false,
                "name": "y",
                "type": "bytes32"
            }
        ],
        "name": "PubkeyChanged",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "node",
                "type": "bytes32"
            },
            {
                "indexed": false,
                "name": "indexedKey",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "key",
                "type": "string"
            }
        ],
        "name": "TextChanged",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "node",
                "type": "bytes32"
            },
            {
                "indexed": false,
                "name": "hash",
                "type": "bytes"
            }
        ],
        "name": "MultihashChanged",
        "type": "event"
    }
]
"""
    
}

extension Web3.Utils {
    
    /// Convert the private key (32 bytes of Data) to compressed (33 bytes) or non-compressed (65 bytes) public key.
    public static func privateToPublic(_ privateKey: Data, compressed: Bool = false) -> Data? {
        guard let publicKey = SECP256K1.privateToPublic(privateKey:  privateKey, compressed: compressed) else {return nil}
        return publicKey
    }
    
    /// Convert a public key to the corresponding EthereumAddress. Accepts public keys in compressed (33 bytes), non-compressed (65 bytes)
    /// or raw concat(X,Y) (64 bytes) format.
    ///
    /// Returns 20 bytes of address data.
    public static func publicToAddressData(_ publicKey: Data) -> Data? {
        if publicKey.count == 33 {
            guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {return nil}
            return publicToAddressData(decompressedKey)
        }
        var stipped = publicKey
        if (stipped.count == 65) {
            if (stipped[0] != 4) {
                return nil
            }
            stipped = stipped[1...64]
        }
        if (stipped.count != 64) {
            return nil
        }
        let sha3 = stipped.sha3(.keccak256)
        let addressData = sha3[12...31]
        return addressData
    }
    
    /// Convert a public key to the corresponding EthereumAddress. Accepts public keys in compressed (33 bytes), non-compressed (65 bytes)
    /// or raw concat(X,Y) (64 bytes) format.
    ///
    /// Returns the EthereumAddress object.
    public static func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
        guard let addressData = Web3.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return EthereumAddress(address)
    }
    
    /// Convert a public key to the corresponding EthereumAddress. Accepts public keys in compressed (33 bytes), non-compressed (65 bytes)
    /// or raw concat(X,Y) (64 bytes) format.
    ///
    /// Returns a 0x prefixed hex string.
    public static func publicToAddressString(_ publicKey: Data) -> String? {
        guard let addressData = Web3.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return address
    }
    
    /// Converts address data (20 bytes) to the 0x prefixed hex string. Does not perform checksumming.
    public static func addressDataToString(_ addressData: Data) -> String? {
        guard addressData.count == 20 else {return nil}
        return addressData.toHexString().addHexPrefix().lowercased()
    }
    
    /// Hashes a personal message by first padding it with the "\u{19}Ethereum Signed Message:\n" string and message length string.
    /// Should be used if some arbitrary information should be hashed and signed to prevent signing an Ethereum transaction
    /// by accident.
    public static func hashPersonalMessage(_ personalMessage: Data) -> Data? {
        var prefix = "\u{19}Ethereum Signed Message:\n"
        prefix += String(personalMessage.count)
        guard let prefixData = prefix.data(using: .ascii) else {return nil}
        var data = Data()
        if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
            data.append(personalMessage)
        } else {
            data.append(prefixData)
            data.append(personalMessage)
        }
        let hash = data.sha3(.keccak256)
        return hash
    }
    
    /// Parse a user-supplied string using the number of decimals for particular Ethereum unit.
    /// If input is non-numeric or precision is not sufficient - returns nil.
    /// Allowed decimal separators are ".", ",".
    public static func parseToBigUInt(_ amount: String, units: Web3.Utils.Units = .eth) -> BigUInt? {
        let unitDecimals = units.decimals
        return parseToBigUInt(amount, decimals: unitDecimals)
    }
    
    /// Parse a user-supplied string using the number of decimals.
    /// If input is non-numeric or precision is not sufficient - returns nil.
    /// Allowed decimal separators are ".", ",".
    public static func parseToBigUInt(_ amount: String, decimals: Int = 18) -> BigUInt? {
        let separators = CharacterSet(charactersIn: ".,")
        let components = amount.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: separators)
        guard components.count == 1 || components.count == 2 else {return nil}
        let unitDecimals = decimals
        guard let beforeDecPoint = BigUInt(components[0], radix: 10) else {return nil}
        var mainPart = beforeDecPoint*BigUInt(10).power(unitDecimals)
        if (components.count == 2) {
            let numDigits = components[1].count
            guard numDigits <= unitDecimals else {return nil}
            guard let afterDecPoint = BigUInt(components[1], radix: 10) else {return nil}
            let extraPart = afterDecPoint*BigUInt(10).power(unitDecimals-numDigits)
            mainPart = mainPart + extraPart
        }
        return mainPart
    }
    
    /// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public static func formatToEthereumUnits(_ bigNumber: BigInt, toUnits: Web3.Utils.Units = .eth, decimals: Int = 4, decimalSeparator: String = ".") -> String? {
        let magnitude = bigNumber.magnitude
        guard let formatted = formatToEthereumUnits(magnitude, toUnits: toUnits, decimals: decimals, decimalSeparator: decimalSeparator) else {return nil}
        switch bigNumber.sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }
    
    /// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public static func formatToPrecision(_ bigNumber: BigInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String? {
        let magnitude = bigNumber.magnitude
        guard let formatted = formatToPrecision(magnitude, numberDecimals: numberDecimals, formattingDecimals: formattingDecimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific) else {return nil}
        switch bigNumber.sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }
    
    /// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public static func formatToEthereumUnits(_ bigNumber: BigUInt, toUnits: Web3.Utils.Units = .eth, decimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String? {
        return formatToPrecision(bigNumber, numberDecimals: toUnits.decimals, formattingDecimals: decimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific);
    }
    
    /// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "numberDecimals",
    /// then limits the decimal part to "formattingDecimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public static func formatToPrecision(_ bigNumber: BigUInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String? {
        if bigNumber == 0 {
            return "0"
        }
        let unitDecimals = numberDecimals
        var toDecimals = formattingDecimals
        if unitDecimals < toDecimals {
            toDecimals = unitDecimals
        }
        let divisor = BigUInt(10).power(unitDecimals)
        let (quotient, remainder) = bigNumber.quotientAndRemainder(dividingBy: divisor)
        var fullRemainder = String(remainder);
        let fullPaddedRemainder = fullRemainder.leftPadding(toLength: unitDecimals, withPad: "0")
        let remainderPadded = fullPaddedRemainder[0..<toDecimals]
        if remainderPadded == String(repeating: "0", count: toDecimals) {
            if quotient != 0 {
                return String(quotient)
            } else if fallbackToScientific {
                var firstDigit = 0
                for char in fullPaddedRemainder {
                    if (char == "0") {
                        firstDigit = firstDigit + 1;
                    } else {
                        let firstDecimalUnit = String(fullPaddedRemainder[firstDigit ..< firstDigit+1])
                        var remainingDigits = ""
                        let numOfRemainingDecimals = fullPaddedRemainder.count - firstDigit - 1
                        if numOfRemainingDecimals <= 0 {
                            remainingDigits = ""
                        } else if numOfRemainingDecimals > formattingDecimals {
                            let end = firstDigit+1+formattingDecimals > fullPaddedRemainder.count ? fullPaddedRemainder.count : firstDigit+1+formattingDecimals
                            remainingDigits = String(fullPaddedRemainder[firstDigit+1 ..< end])
                        } else {
                            remainingDigits = String(fullPaddedRemainder[firstDigit+1 ..< fullPaddedRemainder.count])
                        }
                        if remainingDigits != "" {
                            fullRemainder = firstDecimalUnit + decimalSeparator + remainingDigits
                        } else {
                            fullRemainder = firstDecimalUnit
                        }
                        firstDigit = firstDigit + 1;
                        break
                    }
                }
                return fullRemainder + "e-" + String(firstDigit)
            }
        }
        if (toDecimals == 0) {
            return String(quotient)
        }
        return String(quotient) + decimalSeparator + remainderPadded
    }
    
    /// Recover the Ethereum address from recoverable secp256k1 signature. Message is first hashed using the "personal hash" protocol.
    /// BE WARNED - changing a message will result in different Ethereum address, but not in error.
    ///
    /// Input parameters should be hex Strings.
    static public func personalECRecover(_ personalMessage: String, signature: String) -> EthereumAddress? {
        guard let data = Data.fromHex(personalMessage) else {return nil}
        guard let sig = Data.fromHex(signature) else {return nil}
        return Web3.Utils.personalECRecover(data, signature:sig)
    }
    
    /// Recover the Ethereum address from recoverable secp256k1 signature. Message is first hashed using the "personal hash" protocol.
    /// BE WARNED - changing a message will result in different Ethereum address, but not in error.
    ///
    /// Input parameters should be Data objects.
    static public func personalECRecover(_ personalMessage: Data, signature: Data) -> EthereumAddress? {
        if signature.count != 65 { return nil}
        let rData = signature[0..<32].bytes
        let sData = signature[32..<64].bytes
        let vData = signature[64]
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return Web3.Utils.publicToAddress(publicKey)
    }
    
    
    /// Recover the Ethereum address from recoverable secp256k1 signature.
    /// Takes a hash of some message. What message is hashed should be checked by user separately.
    ///
    /// Input parameters should be Data objects.
    static public func hashECRecover(hash: Data, signature: Data) -> EthereumAddress? {
        if signature.count != 65 { return nil}
        let rData = signature[0..<32].bytes
        let sData = signature[32..<64].bytes
        let vData = signature[64]
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return Web3.Utils.publicToAddress(publicKey)
    }
    
    /// returns Ethereum variant of sha3 (keccak256) of data. Returns nil is data is empty
    static public func keccak256(_ data: Data) -> Data? {
        if data.count == 0 {return nil}
        return data.sha3(.keccak256)
    }
    
    /// returns Ethereum variant of sha3 (keccak256) of data. Returns nil is data is empty
    static public func sha3(_ data: Data) -> Data? {
        if data.count == 0 {return nil}
        return data.sha3(.keccak256)
    }
    
    /// returns sha256 of data. Returns nil is data is empty
    static public func sha256(_ data: Data) -> Data? {
        if data.count == 0 {return nil}
        return data.sha256()
    }
    
    /// Unmarshals a 65 byte recoverable EC signature into internal structure.
    static func unmarshalSignature(signatureData:Data) -> SECP256K1.UnmarshaledSignature? {
        if (signatureData.count != 65) {return nil}
        let bytes = signatureData.bytes
        let r = Array(bytes[0..<32])
        let s = Array(bytes[32..<64])
        return SECP256K1.UnmarshaledSignature(v: bytes[64], r: Data(r), s: Data(s))
    }
    
    /// Marshals the V, R and S signature parameters into a 65 byte recoverable EC signature.
    static func marshalSignature(v: UInt8, r: [UInt8], s: [UInt8]) -> Data? {
        guard r.count == 32, s.count == 32 else {return nil}
        var completeSignature = Data(bytes: r)
        completeSignature.append(Data(bytes: s))
        completeSignature.append(Data(bytes: [v]))
        return completeSignature
    }
    
    /// Marshals internal signature structure into a 65 byte recoverable EC signature.
    static func marshalSignature(unmarshalledSignature: SECP256K1.UnmarshaledSignature) -> Data {
        var completeSignature = Data(unmarshalledSignature.r)
        completeSignature.append(Data(unmarshalledSignature.s))
        completeSignature.append(Data(bytes: [unmarshalledSignature.v]))
        return completeSignature
    }
    
    public static func hexToData(_ string: String) -> Data? {
        return Data.fromHex(string)
    }
    
    public static func hexToBigUInt(_ string: String) -> BigUInt? {
        return BigUInt(string.stripHexPrefix(), radix: 16)
    }
    
    public static func randomBytes(length: Int) -> Data? {
        return Data.randomBytes(length:length)
    }
}
