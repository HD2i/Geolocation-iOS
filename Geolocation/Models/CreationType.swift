//
//  CreationType.swift
//  Geolocation
//
//  Adapted from PeepethClient by Matter, Inc.
//  Obtained from: https://github.com/matterinc/PeepethClient
//  Obtained on: 01/21/19
//
//  Created by Matt Johnson on 1/4/19.
//  Copyright © 2018 Matt Johnson. All rights reserved.
//

import Foundation

enum CreationType {
    
    case importWallet
    case createWallet
    
    func title() -> String {
        switch self {
        case .importWallet:
            return "Import Wallet"
        case .createWallet:
            return "Create Wallet"
        }
    }
}
