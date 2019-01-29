//
//  GeoLocationContract.swift
//  Geolocation
//
//  Adapted from PeepethClient by Matter, Inc.
//  Obtained from: https://github.com/matterinc/PeepethClient
//  Obtained on: 01/4/19
//
//  Created by Matt Johnson on 1/4/19.
//  Copyright © 2018 Matt Johnson. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress

let contractAddress = "0x29ab9ee6e639bac5a5f2ab7099f48248ed315ffe"
let ethContractAddress = EthereumAddress(contractAddress)

let geoABI = """
[
{
"constant": true,
"inputs": [],
"name": "getParticipantNumberOfLocations",
"outputs": [
{
"name": "",
"type": "uint256"
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
"name": "_participantID",
"type": "uint256"
},
{
"name": "_dateTime",
"type": "uint256"
}
],
"name": "getCategory",
"outputs": [
{
"name": "",
"type": "uint8"
}
],
"payable": false,
"stateMutability": "view",
"type": "function"
},
{
"constant": false,
"inputs": [],
"name": "postParticipantSharingPreference",
"outputs": [],
"payable": false,
"stateMutability": "nonpayable",
"type": "function"
},
{
"constant": false,
"inputs": [
{
"name": "_POIname",
"type": "uint8"
},
{
"name": "_lat",
"type": "uint256"
},
{
"name": "_long",
"type": "uint256"
}
],
"name": "postPOI",
"outputs": [],
"payable": false,
"stateMutability": "nonpayable",
"type": "function"
},
{
"constant": true,
"inputs": [
{
"name": "_participantID",
"type": "uint256"
},
{
"name": "_index",
"type": "uint256"
}
],
"name": "getDateTimeOfLocation",
"outputs": [
{
"name": "",
"type": "uint256"
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
"name": "_participantID",
"type": "uint256"
}
],
"name": "getNumberOfLocations",
"outputs": [
{
"name": "",
"type": "uint256"
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
"name": "",
"type": "uint256"
}
],
"name": "sharingEnabled",
"outputs": [
{
"name": "",
"type": "bool"
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
"name": "_participantID",
"type": "uint256"
}
],
"name": "getSharingEnabled",
"outputs": [
{
"name": "",
"type": "bool"
}
],
"payable": false,
"stateMutability": "view",
"type": "function"
},
{
"constant": true,
"inputs": [],
"name": "numberOfParticipants",
"outputs": [
{
"name": "",
"type": "uint256"
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
"name": "_dateTime",
"type": "uint256"
}
],
"name": "getParticipantCategory",
"outputs": [
{
"name": "",
"type": "uint8"
}
],
"payable": false,
"stateMutability": "view",
"type": "function"
},
{
"constant": true,
"inputs": [],
"name": "getParticipantSharingStatus",
"outputs": [
{
"name": "",
"type": "bool"
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
"name": "_dateTime",
"type": "uint256"
},
{
"name": "_lat",
"type": "int256"
},
{
"name": "_long",
"type": "int256"
}
],
"name": "postParticipantLocation",
"outputs": [],
"payable": false,
"stateMutability": "nonpayable",
"type": "function"
},
{
"constant": true,
"inputs": [
{
"name": "_index",
"type": "uint256"
}
],
"name": "getParticipantDateTimeOfLocation",
"outputs": [
{
"name": "",
"type": "uint256"
}
],
"payable": false,
"stateMutability": "view",
"type": "function"
},
{
"constant": true,
"inputs": [],
"name": "getParticipantID",
"outputs": [
{
"name": "",
"type": "uint256"
}
],
"payable": false,
"stateMutability": "view",
"type": "function"
},
{
"inputs": [],
"payable": true,
"stateMutability": "payable",
"type": "constructor"
}
]
"""

