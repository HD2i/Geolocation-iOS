//
//  3rdPartyViewController.swift
//  Geolocation
//
//  Created by Matt Johnson on 1/18/19.
//  Copyright © 2019 Matt Johnson. All rights reserved.
//

import UIKit
import BigInt
import MapKit


class ThirdPartyViewController: UIViewController {

    @IBOutlet weak var numberParticipantsLabel: UILabel!
    @IBOutlet weak var percentSharing: UILabel!
    @IBOutlet weak var numberLocationsLabel: UILabel!
    
    @IBOutlet weak var participantsTable: UITableView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var locationText: UITextField!
    
    var refreshControl = UIRefreshControl()

    var resultSearchController:UISearchController? = nil

    var allParticipants = AllParticipants()
    
    var selectedPlacemark: MKPlacemark?
    var selectedCategory: Int = 0

    let locationManager = CLLocationManager()
    let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantsTable.delegate = self
        participantsTable.dataSource = self
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        participantsTable.addSubview(refreshControl)
        
        allParticipants.loadAllParticipants {
            self.numberParticipantsLabel.text = String(self.allParticipants.numberOfParticipants)
            self.percentSharing.text = String(Double(self.allParticipants.numberSharing)/Double(self.allParticipants.numberOfParticipants) * 100) + "%"
            self.numberLocationsLabel.text = String(self.allParticipants.numberLocations)

            self.participantsTable.reloadData()
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "locSearch") as! LocationSearchViewController
        locationSearchTable.locationManager = locationManager
        locationSearchTable.delegate = self
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController!.searchResultsUpdater = locationSearchTable
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        self.hideKeyboardWhenTappedAround()

    }
    
    @objc func refresh(){
        allParticipants.loadAllParticipants {
            self.refreshControl.endRefreshing()
            self.numberParticipantsLabel.text = String(self.allParticipants.numberOfParticipants)
            self.participantsTable.reloadData()
        }
    }
    
    @IBAction func searchLocations(_ sender: Any) {
        present(resultSearchController!, animated: true, completion: nil)

    }
    
    
    @IBAction func postPOI(_ sender: Any) {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        let alert = UIAlertController(title: "Password", message: "Please enter your password to confirm.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            UIViewController.removeSpinner(spinner: spinner)
        })
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alert] _ in
            guard let alertController = alert, let password = alertController.textFields?.first else { return }
            Web3swiftService().postPOI(category: self.selectedCategory, lat: self.selectedPlacemark!.coordinate.latitude, long: self.selectedPlacemark!.coordinate.longitude, password: password.text!, completion: {(results) in
                UIViewController.removeSpinner(spinner: spinner)
                if results != nil {
                    Alerts().showTx("Submitted POI Category", txhash: results!.hash, with: "To confirm check your transaction hash on Oasis Block Explorer: \n\(results!.hash)", for: self, dismissOnCompletion: false)
                }
                else{
                    Alerts().show("Submission of POI Category Failed", with: "Failed, please try again", for: self)
                }
            })
        }
        alert.addAction(cancel)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
 
}


extension ThirdPartyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allParticipants.numberOfParticipants ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allUsers", for: indexPath)
        cell.textLabel?.text = "Participant " + String(describing: indexPath.row + 1)
        cell.detailTextLabel?.text = "# Locations: \(allParticipants.participantIDToNumLocations[indexPath.row + 1]!)"
        
        if !allParticipants.participantIDSharing[indexPath.row + 1]! {
            cell.textLabel?.text = (cell.textLabel?.text)! + " (Sharing not enabled)"
            cell.backgroundColor = UIColor.lightGray
            cell.detailTextLabel?.text = "# Locations: N/A"

        }
        else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Participants"
    }
    
    
}

extension ThirdPartyViewController : CLLocationManagerDelegate {
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension ThirdPartyViewController: LocationSearchViewControllerDelegate {
    
    func selectedLocation(placemark: MKPlacemark) {
        resultSearchController!.searchBar.text = placemark.title
        if let name = placemark.name {
            locationText.text = name
        }
        else{
            locationText.text = placemark.title!
        }
        locationText.text = locationText.text! + " (\(placemark.coordinate.latitude.roundCoordinate(toDecimals: 4)), \(placemark.coordinate.longitude.roundCoordinate(toDecimals: 4)))"
        selectedPlacemark = placemark
    }
}

extension ThirdPartyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return POICategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(describing: POICategory(rawValue: row)!)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       selectedCategory = row
    }
    
}

    

