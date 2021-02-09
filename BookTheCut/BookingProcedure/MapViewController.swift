//
//  MapViewController.swift
//  MapProcedure
//
//  Created by Vitaliy on 2020-10-16.
//

import UIKit
import MapKit
import PromiseKit

class MapViewController: BaseMainViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties

    var salonArray: [Salon]?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private lazy var geocoder = CLGeocoder()
    private var chosenSalon: Salon?
    private var hairdresserArray: [Hairdresser] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isInputDataValid() {
            getBackToMainVC()
        }
        
        mapView.delegate = self
        mapView.register(SalonMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        // запрос разрешения от юзера на использование текущей позиции
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.showSalonsOnMap()
    }
    
    // MARK: - Navigation
    
    private func getBackToMainVC() {
        guard let navController = self.navigationController else {
            Logger.error("Cannot get ref to navigationController.")
            return
        }
        navController.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? HairdresserViewController {
            target.salon = self.chosenSalon
            target.hairdresserArray = self.hairdresserArray
        }
    }
    
    // MARK: - Private Methods
    
    /// checks if input data exists
    private func isInputDataValid() -> Bool {
        
        if salonArray == nil || salonArray!.count == 0 {
            return false
        }
        
        return true
    }
    
    private func showCurrentLocation(_ location: CLLocation) {
        
        let coordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)  // масштаб карты
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func showSalonsOnMap() {
        
        salonArray!.forEach { salon in
            
            // TODO: wrap with try catch ?
            let coordinates = CLLocationCoordinate2D(latitude: salon.latitude!, longitude: salon.longitude!)
            
            let salonOnMap = SalonOnMap(id: salon.id,
                                          title: salon.name,
                                          locationName: salon.address,
                                          coordinate: coordinates)
            mapView.addAnnotation(salonOnMap)
        }
    }
    
    private func getHairderssersFromFirebase(salonId: String) -> Promise<Void> {
        return Promise { seal in
            let query = dbRef.child(Constants.fbDbTableHairdressers).queryOrdered(byChild: "salonId").queryEqual(toValue: salonId)
            query.observeSingleEvent(of: .value, with: { snapshot in
                guard let hairdresserData = snapshot.value as? NSDictionary else {
                    Logger.error("Salon has no hirdressers.")
                    seal.fulfill_()
                    return
                }
                for (key, value) in hairdresserData {
                    guard let hairdresserDict = value as? NSDictionary,
                          let id = key as? String,
                          let salonId = hairdresserDict["salonId"] as? String,
                          let name = hairdresserDict["name"] as? String else {
                        // TODO: здесь ошибка, надо закомментить seal
                        // TODO: если салон имеет неправильный формат
                        // seal.reject(AppError.FirebaseRequestError)
                        continue
                    }
                    self.hairdresserArray.append(Hairdresser(id: id, salonId: salonId, name: name))
                }
                seal.fulfill_()
            }) { error in
                seal.reject(error)
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        backToFirstPage()
    }
}

extension MapViewController: MKMapViewDelegate {

    // called when we tap a button in аннотации
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // run a check in order not to affect other annotations
        guard let salonOnMap = view.annotation as? SalonOnMap else {
          return
        }

        guard let chosenSalon = salonArray!.first(where: { $0.id == salonOnMap.id }) else {
            fatalError("Error in MapViewController.chosenSalon: cannot find salon with this id.")
        }
        self.chosenSalon = chosenSalon

        Spinner.start(self)
        hairdresserArray.removeAll()
        // get a list of hairdressers for this salon
        firstly {
            getHairderssersFromFirebase(salonId: chosenSalon.id!)
        }.done {
            Spinner.stop()
            if self.hairdresserArray.count == 0 {
                // TODO: inform user that array is empty
                return
            }
            self.performSegue(withIdentifier: Constants.segueToHairdresserVC, sender: self)
        }.catch { error in
            Spinner.stop()
            Logger.error("\(error.localizedDescription)")
        }
    }
    
}

/// для получения текущей позиции
extension MapViewController: CLLocationManagerDelegate {
    
    // called when we do locationManager.startUpdatingLocation()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.first {
            manager.stopUpdatingLocation()
            showCurrentLocation(location)
        }
    }
    
}
