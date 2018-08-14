//
//  SearchResultsViewController.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/6/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit
import Foundation
import SwiftSpinner
import Alamofire
import EasyToast

class SearchResultsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var placeSearchResults : NSDictionary!
    var results : [ResultModel]!
    var selectedPlaceName : String!
    var selectedPlaceInfo : PlaceDetailsInfoModel!
    var selectedPlaceId : String!
    var currentPageNumber : Int!
    var nextPageKey : String!
    var longitude : Double!
    var latitude : Double!
    @IBOutlet weak var previousPgBtn: UIButton!
    @IBOutlet weak var nextPgBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsView: UIView!
    static let PAGESIZE : Int = 20
    var lastPgKey : String!
    var currentSearchData : [Int: [ResultModel]]!
    var selectedPlaceGoogleReviews : [ReviewModel]!
    var selectedPlaceYelpReviews : [ReviewModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSearchData  = [Int:[ResultModel]]()
        currentPageNumber = 0;
        self.title = "Search Results"
        currentSearchData[0] = results
        if(results.count < 1 ) {
            tableView.alpha = 0.0;
            noResultsView.alpha = 1.0
        } else {
            if(nextPageKey != nil) {
                nextPgBtn.isEnabled = true
            } else {
                nextPgBtn.isEnabled = false
            }
            tableView.alpha = 1.0;
            noResultsView.alpha = 0.0
            
        }
        SwiftSpinner.hide()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Search Results"
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentSearchData[self.currentPageNumber]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaults = UserDefaults.standard
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! ResultsTableViewCell
        var result = self.currentSearchData[self.currentPageNumber]![indexPath.row]
        cell.placeName.text = result.placeName
        cell.placeAddr.text = result.placeAddr

        let url = URL(string: result.categoryURL)
        let data = try? Data(contentsOf: url!)
        cell.categoryIcon.image = UIImage(data: data!)
        if let favPlaces =  defaults.object(forKey: "tneFavList") as? [String : NSDictionary] {
            if let placeAlreadyFav = favPlaces[result.placeId] as? NSDictionary {
                cell.favoriteBtn.setImage(UIImage(named : "favorite-filled"), for: .normal)
                cell.favoriteBtn.imageView?.image = UIImage(named: "favorite-filled")
            } else {
                cell.favoriteBtn.setImage(UIImage(named : "favorite-empty"), for: .normal)
                cell.favoriteBtn.imageView?.image = UIImage(named: "favorite-empty")
            }
        } else {
            cell.favoriteBtn.setImage(UIImage(named : "favorite-empty"), for: .normal)
            cell.favoriteBtn.imageView?.image = UIImage(named: "favorite-empty")
        }
        
        return cell
    }
    @IBAction func favoriteBtnPressed(_ sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)?.row
        var place : ResultModel = self.currentSearchData[self.currentPageNumber]![indexPath!]
        let defaults = UserDefaults.standard
        if let favPlaces =  defaults.object(forKey: "tneFavList") as? [String : NSDictionary] {
            if let placeAlreadyFav = favPlaces[place.placeId] as? NSDictionary {
                var favoritePlacesToStore = defaults.object(forKey: "tneFavList") as? [String : NSDictionary]
                favoritePlacesToStore?.removeValue(forKey: place.placeId)
                defaults.set(favoritePlacesToStore, forKey: "tneFavList")
                sender.setImage(UIImage(named: "favorite-empty"), for: .normal)
                self.view.showToast("\(place.placeName!) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: false)
            } else {
                var favoritePlacesToStore = defaults.object(forKey: "tneFavList") as? [String : NSDictionary]
                var dict : NSDictionary = [
                    "placeId": place.placeId,
                    "placeName" : place.placeName,
                    "placeAddr" : place.placeAddr,
                    "categoryURL" : place.categoryURL,
                    "favouritesURL" : place.favouritesURL
                ]
                
                favoritePlacesToStore![place.placeId] = dict
                defaults.set(favoritePlacesToStore, forKey: "tneFavList")
                sender.setImage(UIImage(named: "favorite-filled"), for: .normal)
                self.view.showToast("\(place.placeName!) was added to favorites", position: .bottom, popTime: 1, dismissOnTap: false)
            }
        } else {
            var firstTimeStore = [String : NSDictionary]();
            var dict : NSDictionary = [
                "placeId": place.placeId,
                "placeName" : place.placeName,
                "placeAddr" : place.placeAddr,
                "categoryURL" : place.categoryURL,
                "favouritesURL" : place.favouritesURL
            ]
            
            firstTimeStore[place.placeId] = dict
            defaults.set(firstTimeStore, forKey: "tneFavList")
            defaults.setValue(firstTimeStore, forKey: "tneFavList")
            sender.setImage(UIImage(named: "favorite-filled"), for: .normal)
            self.view.showToast("\(place.placeName!) was added to favorites", position: .bottom, popTime: 1, dismissOnTap: false)
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftSpinner.show("Fetching place details...")
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as! ResultsTableViewCell
        selectedPlaceName = currentCell.placeName.text
        selectedPlaceId = self.currentSearchData[self.currentPageNumber]![(indexPath?.row)!].placeId
        var categoryUrl = self.currentSearchData[self.currentPageNumber]![(indexPath?.row)!].categoryURL
        print("PLACE ID \(selectedPlaceId)")
        Alamofire.request(
            URL(string: "http://tne-env-prod1.us-west-1.elasticbeanstalk.com/getPlaceDetails")!,
            method: .get,
            parameters: ["placeId" : selectedPlaceId])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Error while fetching remote rooms: \(response.result.error)")
                    SwiftSpinner.hide()
                    self.view.showToast("Error Connecting to the Server", position: .bottom, popTime: 1, dismissOnTap: false)
                    return
                }
                let placeSearchResults = response.result.value as! NSDictionary
                print(placeSearchResults)
                let placeDetails = (placeSearchResults as AnyObject).object(forKey: "result") as! NSDictionary
                var placeDetailsInfo = PlaceDetailsInfoModel()
                placeDetailsInfo.placeId = self.selectedPlaceId
                placeDetailsInfo.formattedAddr = placeDetails["formatted_address"] as? String
                placeDetailsInfo.phoneNumber = placeDetails["international_phone_number"] as? String
                placeDetailsInfo.ratings = placeDetails["rating"] as? Float
                placeDetailsInfo.categoryUrl = categoryUrl
                var geometry = placeDetails["geometry"] as? NSDictionary
                var location = geometry?.object(forKey: "location") as? NSDictionary
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
                    self.selectedPlaceGoogleReviews = [ReviewModel]()
                    for (place) in placeReviews {
                        var currentReview = ReviewModel()
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
                placeDetailsInfo.placeName = self.selectedPlaceName
                self.selectedPlaceInfo = placeDetailsInfo
                var addressDetails = placeDetails["adr_address"] as! String
                var addressArray = addressDetails.split(separator: ",")
                var addr1 = placeDetails["formatted_address"] as? String
                var city : String = ""
                var state : String = ""
                for (part) in addressArray {
                    if(part.contains("locality")) {
                        var temp = part.split(separator: ">")[1]
                        city = "\(temp.split(separator: "<")[0])"
                    } else if (part.contains("region")) {
                        var t1 = part.split(separator: " ")[1]
                        var t2 = t1.split(separator: ">")[1]
                        state = "\(t2.split(separator: "<")[0])"
                    }
                }
                var yelpParams = [
                    "placeName" : self.selectedPlaceName as! String,
                    "city" : city as! String,
                    "state" : state as! String,
                    "addr1" : addr1?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) as! String,
                    "latitude" : String(self.latitude),
                    "longitude" : String(self.longitude)
                ]
                
                Alamofire.request(
                    URL(string: "http://tne-env-prod1.us-west-1.elasticbeanstalk.com/getYelpReviews")!,
                    method: .get,
                    parameters: yelpParams)
                    .validate()
                    .responseJSON { (yelpResponse) -> Void in
                        guard response.result.isSuccess else {
                            print("Error while fetching remote rooms: \(response.result.error)")
                            SwiftSpinner.hide()
                            self.view.showToast("Error Connecting to the Server", position: .bottom, popTime: 1, dismissOnTap: false)
                            return
                        }
                        if let yelpReviews = yelpResponse.result.value as? [NSDictionary] {
                            if(yelpReviews.count > 0) {
                                self.selectedPlaceYelpReviews = [ReviewModel]()
                                for review in yelpReviews {
                                    var currentYelpReview = ReviewModel()
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
                        self.performSegue(withIdentifier: "placeDetailsSegue", sender: self)
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeDetailsSegue" {
            if let viewController = segue.destination as? PlaceDetailsVC{
                viewController.selectedPlace = self.selectedPlaceName
                viewController.selectedPlaceId = self.selectedPlaceId
                viewController.placeInfo = self.selectedPlaceInfo
                var placeInfoController = viewController.viewControllers![0] as? PlaceInfoVC
                placeInfoController?.placeInfo = self.selectedPlaceInfo
                var placePhotosController = viewController.viewControllers![1] as? PlacePhotosVC
                placePhotosController?.placeId = self.selectedPlaceId
                var placeMapsController = viewController.viewControllers![2] as? MapsVC
                placeMapsController?.destinationFieldLat = self.latitude
                placeMapsController?.destinationFieldLng = self.longitude
                placeMapsController?.destinationPlaceId = self.selectedPlaceId
                var reviewsController = viewController.viewControllers![3] as? ReviewsVC
                reviewsController?.googleReviews = self.selectedPlaceGoogleReviews
                reviewsController?.yelpReviews = self.selectedPlaceYelpReviews
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        SwiftSpinner.hide()
    }
    
    @IBAction func viewNextResults(_ sender: UIButton) {
        self.currentPageNumber = self.currentPageNumber + 1
        SwiftSpinner.show("Loading next page...")
        self.previousPgBtn.isEnabled = true
        if(self.currentSearchData[self.currentPageNumber] == nil) {
            var token : String = "";
            if(self.currentPageNumber == 1) {
                token =  self.nextPageKey
            } else {
                token = self.lastPgKey
            }
            Alamofire.request(
                URL(string: "http://tne-env-prod1.us-west-1.elasticbeanstalk.com/getNext20Results")!,
                method: .get,
                parameters: ["token" : token])
                .validate()
                .responseJSON { (response) -> Void in
                    guard response.result.isSuccess else {
                        SwiftSpinner.hide()
                        self.view.showToast("Error Connecting to the Server", position: .bottom, popTime: 1, dismissOnTap: false)
                        print("Error while fetching remote rooms: \(response.result.error)")
                        return
                    }
                    let placeSearchResults = response.result.value as! NSDictionary
                    if(self.currentPageNumber != 2) {
                        var finalKey = (placeSearchResults as AnyObject).dictionaryWithValues(forKeys: ["next_page_token"])
                        if let finalKeyVal = finalKey["next_page_token"] as? String {
                            self.lastPgKey = finalKey["next_page_token"]! as! String
                        } else {
                            self.nextPgBtn.isEnabled = false;
                        }
                    } else {
                        self.nextPgBtn.isEnabled = false;
                    }
                    var newResults = (placeSearchResults as AnyObject).object(forKey: "results") as! NSArray
                    var temp = [ResultModel]()
                    for (place) in newResults {
                        var cell = ResultModel();
                        var placeName = "\((place as AnyObject).object(forKey :"name")!)"
                        
                        cell.placeId = "\((place as AnyObject).object(forKey :"place_id")!)"
                        cell.placeName = placeName
                        var placeAddr = "\((place as AnyObject).object(forKey: "vicinity")!)"
                        cell.placeAddr = placeAddr
                        var categoryIcon =  "\((place as AnyObject).object(forKey: "icon")!)"
                        cell.categoryURL = categoryIcon
                        cell.favouritesURL = categoryIcon
                        temp.append(cell)
                    }
                    self.currentSearchData[self.currentPageNumber] = temp
                    self.tableView.reloadData()
                    
                }
                    
        } else {
            if(self.currentPageNumber == 2) {
                self.nextPgBtn.isEnabled = false
            }
            self.tableView.reloadData()
        }
        }
    
    @IBAction func viewPreviousResults(_ sender: UIButton) {
        self.currentPageNumber = self.currentPageNumber - 1
        self.nextPgBtn.isEnabled = true
        if(self.currentPageNumber == 0) {
            self.previousPgBtn.isEnabled = false
        }
        self.tableView.reloadData()
    }
    

}
