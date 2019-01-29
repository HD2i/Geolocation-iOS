//
//  AllUsers.swift
//  Geolocation
//
//  Created by Matt Johnson on 1/21/19.
//  Copyright © 2019 Matt Johnson. All rights reserved.
//

import Foundation
import EthereumAddress
import BigInt

class AllParticipants {
    
    var numberOfParticipants: Int!
    var numberSharing: Int!
    var numberLocations: Int!
    var participantIDSharing = [Int: Bool]()
    var participantIDToNumLocations: [Int: Int] = [:]
    var participants: [Participant]?
    
    func loadAllParticipants(completion: @escaping() -> Void) {
        removeData()
        getNumberOfParticipants {
            if self.numberOfParticipants != 0 {
                self.getSharingStatusForEachParticipant {
                    self.getNumberOfLocationsOfParticipant {
                        completion()
                    }
                }
            }
            else{
                completion()
            }
        }
    }
    
    func getNumberOfParticipants(completion: @escaping() -> Void) {
        Web3swiftService().getNumberOfParticipants { (result) in
            self.numberOfParticipants = Int(result["0"] as! BigUInt)
            completion()
        }
    }

    func getSharingStatusForEachParticipant(completion: @escaping() -> Void) {
        for eachID in 1...numberOfParticipants {
            Web3swiftService().getStatusOfParticipant(participantID: BigUInt(eachID), completion: { (result) in
                var sharingEnabled: Bool { return (result["0"] as! Int) != 0 }
                self.participantIDSharing[eachID] = sharingEnabled
                self.numberSharing += 1
                if self.participantIDSharing.count == self.numberOfParticipants {
                    completion()
                }
            })
        }
    }
    
    func getNumberOfLocationsOfParticipant(completion: @escaping() -> Void) {
        for eachID in participantIDSharing {
            if eachID.value {
                Web3swiftService().getNumberOfLocations(participantID: BigUInt(eachID.key), completion: { (result) in
                    self.participantIDToNumLocations[eachID.key] = Int(result["0"] as! BigUInt)
                    self.numberLocations += self.participantIDToNumLocations[eachID.key]!
                    if self.participantIDToNumLocations.count == self.numberOfParticipants {
                        completion()
                    }
                })
            }
            else{
                self.participantIDToNumLocations[eachID.key] = 0
                if self.participantIDToNumLocations.count == self.numberOfParticipants {
                    completion()
                }
            }
        }
    }
    
    func removeData(){
        numberOfParticipants = 0
        numberSharing = 0
        numberLocations = 0
        participantIDSharing = [:]
        participantIDToNumLocations = [:]
        participants = []
    }
   
}
