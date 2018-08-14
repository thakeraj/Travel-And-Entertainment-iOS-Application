//
//  ViewController.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/6/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import McPicker
import EasyToast
import SwiftSpinner
import GooglePlaces
import GooglePlacePicker

class HomeVC: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var initialViewToggler: UISegmentedControl!
    var userCurrentLatitude: Double!
    var userCurrentLongitude: Double!
    
    @IBOutlet weak var searchFormTab: UIView!
    @IBOutlet weak var keywordText: UITextField!
    @IBOutlet weak var categoryText: McTextField!
    @IBOutlet weak var distanceText: UITextField!
    @IBOutlet weak var sourceLocationText: UITextField!
    @IBOutlet weak var searchFormView: UIView!
    @IBOutlet weak var noFavoritesView: UIView!
    var newPlaceSearchResults : NSArray!
    var searchResult : [ResultModel]!
    var nextPageKey : String!
    var favouritePlaces : [String: NSDictionary]!
    var placeIds : [String]!
    @IBOutlet weak var favoritesTable: UITableView!
    var selectedPlaceId : String!
    var selectedPlaceGoogleReviews : [ReviewModel]!
    var selectedPlaceYelpReviews : [ReviewModel]!
    var selectedPlaceName : String!
    var selectedPlaceInfo : PlaceDetailsInfoModel!
    var longitude : Double!
    var latitude : Double!
    
    //Load Location Manager and Check for Favorites.
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        loadFavResults()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Getting Current User Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        userCurrentLatitude = locValue.latitude
        userCurrentLongitude = locValue.longitude
        
    }
    
    //Click of Search Hit the Rest Api to fetch Search Results
    @IBAction func searchForPlaces(_ sender: UIButton) {
        let isValid : Bool = performSearchFormValidation()
        if(isValid) {
            fetchPlace()
        }
    }
    
    //Location Auto Complete Function
    @IBAction func startAutoComplete(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        present(autocompleteController, animated: true, completion: nil)
    }
    
    //Slide to Delete from Table - Unfavorite a Place
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let defaults = UserDefaults.standard
            if let favPlaces =  defaults.object(forKey: "tneFavList") as? [String : NSDictionary] {
                if (favPlaces[placeIds[indexPath.row]]) != nil {
                    var favoritePlacesToStore = defaults.object(forKey: "tneFavList") as? [String : NSDictionary]
                    favoritePlacesToStore?.removeValue(forKey: placeIds[indexPath.row])
                    defaults.set(favoritePlacesToStore, forKey: "tneFavList")
                }
            }
            let placeName =  favouritePlaces.removeValue(forKey: placeIds[indexPath.row])!["placeName"] as! String
            tableView.beginUpdates()
            favouritePlaces.removeValue(forKey: placeIds[indexPath.row])
            placeIds.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            if(favouritePlaces.count < 1) {
                self.noFavoritesView.isHidden = false
                self.favoritesTable.isHidden = true
            }
            self.view.showToast("\(placeName) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: false)
        }
    }
    
    
    //Checks if Keyword and Location Fields don't have empty space values.
    func performSearchFormValidation()  -> Bool{
        if((keywordText.text?.trimmingCharacters(in: .whitespacesAndNewlines).count)! < 1) {
            self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: 1, dismissOnTap: false)
            return false
        } else if ((sourceLocationText.text?.trimmingCharacters(in: .whitespaces).count)! < 1)  {
            self.view.showToast("From location cannot be empty", position: .bottom, popTime: 1, dismissOnTap: false)
            return false
        }
        return true
    }
    
    //Toggler between Search Form and Favorites View.
    @IBAction func switchInitialViews(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0) {
            UIView.animate(withDuration: 0.5, animations: {
                self.displaySearchForm()
            })
        } else if(sender.selectedSegmentIndex == 1) {
            print("Came Here")
            UIView.animate(withDuration: 0.5, animations: {
                self.searchFormView.isHidden = true
                if(self.favouritePlaces.count > 0) {
                    print("Got Favorite Results")
                    self.displayFavoritesTable()
                    self.favoritesTable.reloadData()
                } else {
                    print("NO Favorite Results")
                    self.displayNoResults()
                }
                
            })
        }
    }
    
    func displaySearchForm() {
        self.searchFormView.isHidden = false
        self.noFavoritesView.isHidden = true
        self.favoritesTable.isHidden = true
    }
    
    func displayFavoritesTable() {
        self.favoritesTable.isHidden = false
        self.noFavoritesView.isHidden = true
    }
    
    func displayNoResults() {
        self.noFavoritesView.isHidden = false
        self.favoritesTable.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadFavResults()
        if let favorTable = self.favoritesTable {
            favorTable.reloadData()
        }
    }
    
    @IBAction func displayCategories(_ sender: Any) {
       displayCategories()
    }
    
    //Populate the McPicker Categories
    func displayCategories() {
        self.keywordText.becomeFirstResponder()
        McPicker.show(data: [["Default", "Airport", "Amusement Park", "Aquarium", "Art Gallery", "Bakery", "Bar", "Beauty Salon", "Bowling Alley", "Bus Station", "Cafe", "Campground", "Car Rental", "Casino", "Lodging", "Movie Theater", "Museum", "Night Club", "Park", "Parking", "Restaurant", "Shopping Mall", "Stadium", "Subway Station", "Taxi Stand", "Train Station", "Transit Station", "Travel Agency", "Zoo"]]) {  [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.categoryText.text = name
                self?.keywordText.becomeFirstResponder()
                
            }
        }
        
    }

    //Collecting Values from the form to perform search operation.
    func prepareParametersForSearch() -> [ String: String] {
        var parameters = [String: String]();
        parameters["keyword"] = keywordText.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        parameters["category"] = categoryText.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "_")
        var radius = distanceText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if(radius.count > 0) {
            parameters["distance"] = distanceText.text!
        } else {
            parameters["distance"] = "10"
        }
        let srcLocation = sourceLocationText.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if(srcLocation == "my location" || srcLocation == "your location") {
            parameters["fromLocationOption"] = "hereLocation"
            parameters["customLocationText"] = ""
        } else {
            parameters["fromLocationOption"] = "customLocation"
            parameters["customLocationText"] = sourceLocationText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        parameters["currentLocationLatitude"] = "\(userCurrentLatitude!)"
        parameters["currentLocationLongitude"] = "\(userCurrentLongitude!)"
        return parameters;
    }
    
    //Hit Rest Api for Search Results.
    func fetchPlace()->() {
        
        SwiftSpinner.show("Searching...")
        let params = prepareParametersForSearch()
        
        Alamofire.request(
            URL(string: "http://tne-env-prod1.us-west-1.elasticbeanstalk.com/getNearByPlaces")!,
            method: .get,
            parameters: params)
            .validate()
            .responseJSON { (response) -> Void in
                
                //In case of Errors
                guard response.result.isSuccess else {
                    SwiftSpinner.hide()
                    self.view.showToast("Could Not Reach Server", position: .bottom, popTime: 1, dismissOnTap: false)
                    return
                }
                
                let placeSearchResults = response.result.value as! NSDictionary
                var nextPgKey = (placeSearchResults as AnyObject).dictionaryWithValues(forKeys: ["next_page_token"])
                if let nextPgKey = nextPgKey["next_page_token"] as? String {
                    self.nextPageKey = nextPgKey
                } else {
                    self.nextPageKey = nil
                }
                
                self.newPlaceSearchResults = (placeSearchResults as AnyObject).object(forKey: "results") as! NSArray
                
                var fetchedResults = [ResultModel]()
                
                for (place) in self.newPlaceSearchResults {
                
                    let resultCellData = ResultModel();
                    let placeName = "\((place as AnyObject).object(forKey :"name")!)"
                    resultCellData.placeId = "\((place as AnyObject).object(forKey :"place_id")!)"
                    resultCellData.placeName = placeName
                    let placeAddr = "\((place as AnyObject).object(forKey: "vicinity")!)"
                    resultCellData.placeAddr = placeAddr
                    let categoryIcon =  "\((place as AnyObject).object(forKey: "icon")!)"
                    resultCellData.categoryURL = categoryIcon
                    resultCellData.favouritesURL = categoryIcon
                    fetchedResults.append(resultCellData)

                }
                
                self.searchResult = fetchedResults
                
                self.performSegue(withIdentifier: "presearchResults", sender: self)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favPlaceCell", for: indexPath) as! FavoritesTableViewCell
        let placeData = favouritePlaces[placeIds[indexPath.row]]
        let url = URL(string: placeData!["categoryURL"]! as! String)
        let data = try? Data(contentsOf: url!)
        cell.categoryIcon.image = UIImage(data: data!)
        cell.placeName.text = placeData!["placeName"]! as? String
        cell.placeAddr.text = placeData!["placeAddr"]! as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(favouritePlaces != nil) {
                return self.favouritePlaces.count
        }
        return 0
       
    }
    
    //Fetch Place Details and Perform Segue.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftSpinner.show("Fetching place details...")
        let indexPath = tableView.indexPathForSelectedRow
        let favoritePlace = favouritePlaces[placeIds[(indexPath?.row)!]] as! NSDictionary
        
        
        selectedPlaceName = favoritePlace["placeName"] as? String
        selectedPlaceId = placeIds[(indexPath?.row)!]
        let categoryUrl = favoritePlace["categoryURL"] as? String
        
        Alamofire.request(
            URL(string: "http://tne-env-prod1.us-west-1.elasticbeanstalk.com/getPlaceDetails")!,
            method: .get,
            parameters: ["placeId" : selectedPlaceId])
            .validate()
            .responseJSON { (response) -> Void in
                
                //In case of Errors
                guard response.result.isSuccess else {
                    SwiftSpinner.hide()
                    self.view.showToast("Could Not Reach Server", position: .bottom, popTime: 1, dismissOnTap: false)
                    return
                }
                
                let placeSearchResults = response.result.value as! NSDictionary
                let placeDetails = (placeSearchResults as AnyObject).object(forKey: "result") as! NSDictionary
                let placeDetailsInfo = PlaceDetailsInfoModel()
                placeDetailsInfo.placeId = self.selectedPlaceId
                placeDetailsInfo.categoryUrl = categoryUrl
                placeDetailsInfo.formattedAddr = placeDetails["formatted_address"] as? String
                placeDetailsInfo.phoneNumber = placeDetails["international_phone_number"] as? String
                placeDetailsInfo.ratings = placeDetails["rating"] as? Float
                let geometry = placeDetails["geometry"] as? NSDictionary
                let location = geometry?.object(forKey: "location") as? NSDictionary
                self.latitude = location?.value(forKey: "lat") as? Double
                self.longitude =  location?.value(forKey: "lng") as? Double
                placeDetailsInfo.priceLevel = placeDetails["price_level"] as? Float
                if let website = placeDetails["website"] as? String {
                    placeDetailsInfo.website = website
                } else {
                    placeDetailsInfo.website = nil
                }
                if let googleURL = placeDetails["url"] as? String {
                    placeDetailsInfo.googlePage = googleURL
                } else {
                    placeDetailsInfo.googlePage = nil
                }
                
                if let placeReviews = placeDetails["reviews"] as? [NSDictionary] {
                    self.populateGoogleReviews(googleReviews : placeReviews)
                }
                placeDetailsInfo.placeName = self.selectedPlaceName
                self.selectedPlaceInfo = placeDetailsInfo
                let addressDetails = placeDetails["adr_address"] as! String
                let addressArray = addressDetails.split(separator: ",")
                let addr1 = placeDetails["formatted_address"] as? String
                var city : String = ""
                var state : String = ""
                for (part) in addressArray {
                    if(part.contains("locality")) {
                        let firstSplit = part.split(separator: ">")[1]
                        city = "\(firstSplit.split(separator: "<")[0])"
                    } else if (part.contains("region")) {
                        let firstSplit = part.split(separator: " ")[1]
                        let secondSplit = firstSplit.split(separator: ">")[1]
                        state = "\(secondSplit.split(separator: "<")[0])"
                    }
                }
                
                let yelpParams = [
                    "placeName" : self.selectedPlaceName,
                    "city" : city,
                    "state" : state,
                    "addr1" : addr1?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                    "latitude" : String(self.latitude),
                    "longitude" : String(self.longitude)
                ]
                
                Alamofire.request(
                    URL(string: "http://tne-env-prod1.us-west-1.elasticbeanstalk.com/getYelpReviews")!,
                    method: .get,
                    parameters: yelpParams)
                    .validate()
                    .responseJSON { (yelpResponse) -> Void in
                        //In case of Errors
                        guard response.result.isSuccess else {
                            SwiftSpinner.hide()
                            self.view.showToast("Could Not Reach Server", position: .bottom, popTime: 1, dismissOnTap: false)
                            return
                        }
                        
                        if let yelpReviews = yelpResponse.result.value as? [NSDictionary] {
                            self.populateYelpDetails(yelpReviews: yelpReviews)
                        }
                        self.performSegue(withIdentifier: "favorPlaceDetails", sender: self)
                }
        }
        
    }
    
    func populateGoogleReviews(googleReviews: [NSDictionary]) {
        self.selectedPlaceGoogleReviews = [ReviewModel]()
        for (place) in googleReviews {
            let currentReview = ReviewModel()
            if let authorName = place["author_name"] as? String {
                currentReview.name = authorName
            }
            if let authorUrl = place["author_url"] as? String {
                currentReview.authorUrl = authorUrl
            }
            if let authorImg = place["profile_photo_url"] as? String {
                currentReview.imageUrl = authorImg
            }
            if let userRatig = place["rating"] as? Double {
                currentReview.rating = userRatig
            }
            if let reviewText = place["text"] as? String {
                currentReview.review = reviewText
            }
            if let reviewTime = place["time"] as? UInt64 {
                currentReview.time = reviewTime
            }
            self.selectedPlaceGoogleReviews.append(currentReview)
        }
    }
    
    func populateYelpDetails(yelpReviews : [NSDictionary]) {
        
        if(yelpReviews.count > 0) {
            self.selectedPlaceYelpReviews = [ReviewModel]()
            for review in yelpReviews {
                let currentYelpReview = ReviewModel()
                if let rating = review["rating"] as? Double {
                    currentYelpReview.rating = rating
                }
                if let currentReview = review["text"] as? String {
                    currentYelpReview.review = currentReview
                }
                if let timeCreated = review["time_created"] as? String {
                    currentYelpReview.yelpTimeCreated = timeCreated
                }
                if let authorURL = review["url"] as? String {
                    currentYelpReview.authorUrl = authorURL
                }
                if let user = review["user"] as? NSDictionary {
                    if let userName = user["name"] as? String {
                        currentYelpReview.name = userName
                    }
                    if let userImg = user["image_url"] as? String {
                        currentYelpReview.imageUrl = userImg
                    }
                }
                self.selectedPlaceYelpReviews.append(currentYelpReview)
                
            }
        }
    }
    
    //Clear Form
    @IBAction func clearSearchForm(_ sender: UIButton) {
        keywordText.text = ""
        categoryText.text = "Default"
        distanceText.text =  ""
        sourceLocationText.text = "Your location"
        
    }
    
    //Either Perform Search Segue or Favorites to Place Details.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presearchResults" {
            if let viewController = segue.destination as? SearchResultsVC{
                viewController.results = searchResult
                viewController.currentPageNumber = 0
                viewController.nextPageKey = self.nextPageKey
            }
        } else if segue.identifier == "favorPlaceDetails"{
            if let viewController = segue.destination as? PlaceDetailsVC{
                
                viewController.selectedPlace = self.selectedPlaceName
                viewController.selectedPlaceId = self.selectedPlaceId
                viewController.placeInfo = self.selectedPlaceInfo
                
                //Different Tab Controllers Data
                let placeInfoController = viewController.viewControllers![0] as? PlaceInfoVC
                placeInfoController?.placeInfo = self.selectedPlaceInfo
                
                let placePhotosController = viewController.viewControllers![1] as? PlacePhotosVC
                placePhotosController?.placeId = self.selectedPlaceId
                
                let placeMapsController = viewController.viewControllers![2] as? MapsVC
                placeMapsController?.destinationFieldLat = self.latitude
                placeMapsController?.destinationFieldLng = self.longitude
                placeMapsController?.destinationPlaceId = self.selectedPlaceId
                
                let reviewsController = viewController.viewControllers![3] as? ReviewsVC
                reviewsController?.googleReviews = self.selectedPlaceGoogleReviews
                reviewsController?.yelpReviews = self.selectedPlaceYelpReviews
            }
        }
    }
    
    
    //Load Favorites Results From UserDefaults
    func loadFavResults() {
        let defaults = UserDefaults.standard
        if let favPlaces =  defaults.object(forKey: "tneFavList") as? [String : NSDictionary] {
            favouritePlaces = favPlaces
            var localPlaceIds = [String]()
            for(key, _) in favPlaces {
                localPlaceIds.append(key)
            }
            placeIds = localPlaceIds
        }
        if let toggler = initialViewToggler {
            if(toggler.selectedSegmentIndex == 1) {
                if(favouritePlaces.count < 1) {
                    self.displayNoResults()
                } else {
                    self.displayFavoritesTable()
                }
            } else {
                self.displaySearchForm()
            }
        }
    }

}

//Google Auto-Complete Module
extension HomeVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        sourceLocationText.text = place.formattedAddress!
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

