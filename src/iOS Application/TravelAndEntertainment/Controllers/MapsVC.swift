//
//  MapsVC.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/10/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import AlamofireSwiftyJSON

class MapsVC: UIViewController {
    
    @IBOutlet weak var gmsMapView: GMSMapView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var modeSegments: UISegmentedControl!
    
    var destinationPlaceId : String!
    var destinationFieldLat : Double!
    var destinationFieldLng : Double!
    var sourceLat : Double!
    var sourceLng : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gmsMapView.camera = GMSCameraPosition.camera(withLatitude: destinationFieldLat, longitude: destinationFieldLng, zoom: 14.0)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: destinationFieldLat, longitude: destinationFieldLng)
        marker.map = gmsMapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func travelModeChange(_ sender: UISegmentedControl) {
        let fromText : Int = (fromTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count)!
        if(fromText > 0 && sourceLat != nil && sourceLng != nil && destinationFieldLat != nil && destinationFieldLng != nil) {
            getDirections()
        }
    }
    
    
    @IBAction func startAutoComplete(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        present(autocompleteController, animated: true, completion: nil)
    }
    
    

    func getDirections() {
        var mode = "driving"
        switch modeSegments.selectedSegmentIndex {
        case 0:
            mode = "driving"
        case 1:
            mode = "bicycling"
        case 2 :
            mode = "transit"
        case 3:
            mode = "walking"
        default:
            mode = "driving"
        }
        let params = [
            "sourceLocation" : "\(self.sourceLat!),\(self.sourceLng!)",
            "destinationPlaceId" : "\(self.destinationFieldLat!),\(self.destinationFieldLng!)",
            "mode" : mode
        ]
        Alamofire.request(
            URL(string: "http://tne-env-prod1.us-west-1.elasticbeanstalk.com/getDirections")!,
            method: .get,
            parameters: params)
            .validate()
            .responseJSON { (response) -> Void in
                
                guard response.result.isSuccess else {
                    self.view.showToast("Unable to fetch Directions", position: .bottom, popTime: 1, dismissOnTap: false)
                    return
                }
                self.gmsMapView.clear()
                let polyline = GMSPolyline()
                var path = GMSPath()
                
                let json = response.result.value as? NSDictionary
                if let routes = json!["routes"] as? NSArray {
                    if (routes.count > 0)
                    {
                        let routeDict = routes[0] as! Dictionary<String, Any>
                        let routeOverviewPolyline = routeDict["overview_polyline"] as! Dictionary<String, Any>
                        let points = routeOverviewPolyline["points"]
                        path = GMSPath.init(fromEncodedPath: points as! String)!
                        polyline.path = path
                        polyline.strokeColor = UIColor.blue
                        polyline.strokeWidth = 3.0
                        polyline.map = self.gmsMapView
                        let sourceMarker = GMSMarker()
                        sourceMarker.position = CLLocationCoordinate2D(latitude: self.sourceLat, longitude: self.sourceLng)
                        sourceMarker.map = self.gmsMapView
                        let destMarker = GMSMarker()
                        destMarker.position = CLLocationCoordinate2D(latitude: self.destinationFieldLat, longitude: self.destinationFieldLng)
                        destMarker.map = self.gmsMapView
                        var bounds = GMSCoordinateBounds()
                        for index in 1...path.count() {
                            bounds = bounds.includingCoordinate(path.coordinate(at: index))
                        }
                        self.gmsMapView.animate(with: GMSCameraUpdate.fit(bounds))
                    }
                }
               
        }
    }

}

extension MapsVC :GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromTextField.text = place.formattedAddress!
        self.sourceLat = place.coordinate.latitude
        self.sourceLng = place.coordinate.longitude
        getDirections()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
