//
//  UserViewController.swift
//  Geolocation
//
//  Created by Matt Johnson on 1/10/19.
//  Copyright © 2019 Matt Johnson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ParticipantViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var pastLocationsTableView: UITableView!
    @IBOutlet weak var sharingEnabled: UISwitch!
    
    let locationManager = CLLocationManager()
    let me = Participant()

    var currentLocation: CLLocation!
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        setupMap()
        pastLocationsTableView.delegate = self
        pastLocationsTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        pastLocationsTableView.addSubview(refreshControl)
        me.loadLocations(address: Web3swiftService.currentAddress!, completion: {
            self.sharingEnabled.isOn = self.me.sharingEnabled
            self.pastLocationsTableView.reloadData()
        })
        addMapTrackingButton()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.locationManager.startUpdatingLocation()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locationManager.location else {
                return
            }
            if let coor = mapView.userLocation.location?.coordinate{
                mapView.setCenter(coor, animated: true)
            }
            setLocationText(location: currentLocation)
            
        }
    }
    
    func setupMap(){
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.roundCorners()
        mapView.layer.borderColor = UIColor.black.cgColor
        mapView.layer.borderWidth = 2.0
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
    
    func addMapTrackingButton(){
        let image = UIImage(named: "Map") as UIImage?
        let button   = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.frame = CGRect(origin: CGPoint(x:5, y: 10), size: CGSize(width: 35, height: 35))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        button.tintColor = UIColor.gold()
        button.backgroundColor = .black
        button.setRounded()
        button.addTarget(self, action: #selector(self.centerMapOnUserButtonClicked), for:.touchUpInside)
        mapView.addSubview(button)
    }
    
    func setLocationText(location: CLLocation) {
        let coord = "(\(location.coordinate.latitude.roundCoordinate(toDecimals: 4)), \(location.coordinate.longitude.roundCoordinate(toDecimals: 4)))"
        let dateTime = "\(Date().localizedDescription(dateStyle: .short, timeStyle: .short))"
        let string = "I want to add my current location \(coord) on \(dateTime)"
        let coordRange = (string as NSString).range(of: coord)
        let dateTimeRange = (string as NSString).range(of: dateTime)
        
        let attributedString    = NSMutableAttributedString(string: string)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica", size: 16.0)!, range: (string as NSString).range(of: string))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica-Bold", size: 16.0)!, range: coordRange)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica-Bold", size: 16.0)!, range: dateTimeRange)

        locationTextView.attributedText = attributedString
        locationTextView.textAlignment = .center
    }
    
    @objc func centerMapOnUserButtonClicked() {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    @IBAction func shareLocationData(_ sender: Any) {
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locationManager.location else {
                return
            }
            setLocationText(location: currentLocation)
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
                Web3swiftService().postParticipantLocation(dateTime: Date().timeIntervalSince1970, lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude, password: password.text!, completion: {(results) in
                    UIViewController.removeSpinner(spinner: spinner)
                    if results != nil {
                        Alerts().showTx("Submitted Location Data", txhash: results!.hash, with: "To confirm check your transaction hash on Oasis block explorer: \n\(results!.hash)", for: self, dismissOnCompletion: false)
                    }
                    else{
                        Alerts().show("Submission of Location Data Failed", with: "Failed, please try again", for: self)
                    }
                })
            }
            alert.addAction(cancel)
            alert.addAction(confirmAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func setSharingStatus(_ sender: Any) {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        let alert = UIAlertController(title: "Password", message: "Please enter your password to confirm.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            UIViewController.removeSpinner(spinner: spinner)
            self.sharingEnabled.isOn = !self.sharingEnabled.isOn
        })
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alert] _ in
            guard let alertController = alert, let password = alertController.textFields?.first else { return }
            Web3swiftService().setSharingStatus(enableSharing: self.sharingEnabled.isOn, password: password.text!, completion: {(results) in
                UIViewController.removeSpinner(spinner: spinner)
                if results != nil {
                    Alerts().showTx("Submitted Request to change Sharing Preference ", txhash: results!.hash, with: "To confirm check your transaction hash on Oasis Block Explorer: \n\(results!.hash)", for: self, dismissOnCompletion: false)
                }
                else{
                    print("failed")
                    self.sharingEnabled.isOn = !self.sharingEnabled.isOn
                    Alerts().show("Request to change Sharing Preference Failed", with: "Please make sure you've posted a location before changing your sharing preference", for: self)
                }
            })
        }
        alert.addAction(cancel)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func refresh(){
        me.loadLocations(address: Web3swiftService.currentAddress!, completion: {
            self.refreshControl.endRefreshing()
            self.sharingEnabled.isOn = self.me.sharingEnabled
            self.pastLocationsTableView.reloadData()
        })
    }

}

extension ParticipantViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(viewRegion, animated: false)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: " + error.localizedDescription)
    }
    
}

extension ParticipantViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return me.numberOfLocations ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pastLocation", for: indexPath)
        let pastLocationData = Array(me.dates).sorted(by: {$0.key > $1.key})
        if pastLocationData.count > 0 {
            let thisLocationData = pastLocationData[indexPath.row]
            cell.imageView?.image = thisLocationData.value.getImage()
            cell.textLabel?.text = String(describing: thisLocationData.key.localizedDescription(dateStyle: .short, timeStyle: .short))
            cell.detailTextLabel?.text = String(describing: thisLocationData.value)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Past Locations"
    }
    

}

extension ParticipantViewController: MKMapViewDelegate {
    
}
