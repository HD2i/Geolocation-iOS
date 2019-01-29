//
//  User.swift
//  Geolocation
//
//  Created by Matt Johnson on 1/14/19.
//  Copyright © 2019 Matt Johnson. All rights reserved.
//

import Foundation
import EthereumAddress
import BigInt

class Participant {
    
    var ethAddress: EthereumAddress?
    var participantID: BigUInt?
    var numberOfLocations: Int!
    var sharingEnabled: Bool!
    var dates: [Date : POICategory] = [:]
    var refDates = [BigUInt]()
    var categories = [BigUInt]()
    var categoriesString = [POICategory]()

   // var dateTime: [Date?]

    func loadLocations(address: EthereumAddress, completion: @escaping() -> Void) {
        ethAddress = address
        removeData()
        self.getParticipantID{
            self.getSharingStatus {
                self.getNumberOfLocations {
                    if self.numberOfLocations != 0 {
                        self.loadDateTimes{
                            self.loadCategories{
                                completion()
                            }
                        }
                    }
                    else{
                        self.sharingEnabled = false
                        completion()
                    }
                }
            }
        }
    }
    
    func getNumberOfLocations(completion: @escaping() -> Void) {
        Web3swiftService().getNumberOfParticipantsLocations(completion: {numLocations in
            self.numberOfLocations  = (String(describing: numLocations["0"]!) as NSString).integerValue
            completion()
        })
    }
    
    func loadDateTimes(completion: @escaping() -> Void) {
        for i in 0...self.numberOfLocations-1 {
            Web3swiftService().getEachDateTime(index:  BigUInt(i), completion: { (eachDateTime) in
                self.refDates.append(eachDateTime["0"] as! BigUInt)
                self.dates[Date(timeIntervalSince1970: TimeInterval(Double(self.refDates.last!)))] = POICategory.None
                if self.dates.count == self.numberOfLocations {
                    completion()
                }
            })
        }
    }
    
    func loadCategories(completion: @escaping() -> Void) {
        for i in 0...self.dates.count-1 {
            Web3swiftService().getParticipantCategory(dateTime: self.refDates[i], completion: { (eachCategory) in
                let category = eachCategory["0"] as! BigUInt
                self.categories.append(category)
                self.categoriesString.append(POICategory(rawValue: Int(category)) ?? POICategory.None)
                self.dates[Date(timeIntervalSince1970: TimeInterval(Double(self.refDates[i])))] = POICategory(rawValue: Int(category))
                if self.categories.count == self.dates.count {
                    completion()
                }
            })
        }
    }
    
    func getSharingStatus(completion: @escaping() -> Void) {
        Web3swiftService().getShareStatus(completion: { (shareStatus) in
            self.sharingEnabled = shareStatus["0"] as? Bool
            completion()
        })
    }
    
    func getParticipantID(completion: @escaping() -> Void) {
        Web3swiftService().getParticipantID(completion: { (userID) in
            self.participantID = userID["0"] as? BigUInt
            completion()
        })
    }
    
    func postSharingStatus(completion: @escaping() -> Void) {
        
    }
    
    func removeData(){
        numberOfLocations = 0
        dates = [:]
        refDates = []
        categories = []
        categoriesString = []

    }
}
