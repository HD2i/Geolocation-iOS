//
//  Category.swift
//  Geolocation
//
//  Created by Matt Johnson on 1/15/19.
//  Copyright © 2019 Matt Johnson. All rights reserved.
//

import Foundation
import UIKit

enum POICategory: Int {
    
    case None
    case Hospital
    case Gym
    case Pharmacy
    
    static let count: Int = {
        var num: Int = 0
        while let _ = POICategory(rawValue: num) { num += 1 }
        return num
    }()
    
    func getImage() -> UIImage? {
        switch(self){
        case .None:
            return UIImage(named: "None")
        case .Hospital:
            return UIImage(named: "Hospital")
        case .Gym:
            return UIImage(named: "Gym")
        case .Pharmacy:
            return UIImage(named: "Pharmacy")
        }
    }
}
