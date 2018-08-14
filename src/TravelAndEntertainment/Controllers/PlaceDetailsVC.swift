//
//  PlaceDetailsVC.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/8/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit
import EasyToast

class PlaceDetailsVC: UITabBarController {

    var selectedPlace : String!
    var selectedPlaceId : String!
    var placeInfo : PlaceDetailsInfoModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let titleController = self.navigationController?.navigationBar.items!.count {
            if(titleController > 1 ){
                self.navigationController?.navigationBar.items![1].title = ""
            }
        }
        self.title = selectedPlace!
        let currentPlaceDetailsInfo = self.viewControllers![0] as? PlaceInfoVC
        currentPlaceDetailsInfo?.placeInfo = self.placeInfo
        var favoritePlace = UIBarButtonItem(image: UIImage(named: "favorite-empty"), style: .plain, target: self, action: #selector(favorPlace))
        let defaults = UserDefaults.standard
        if let favPlaces =  defaults.object(forKey: "tneFavList") as? [String : NSDictionary] {
            if let placeAlreadyFav = favPlaces[self.selectedPlaceId] {
                favoritePlace = UIBarButtonItem(image: UIImage(named: "favorite-filled"), style: .plain, target: self, action: #selector(favorPlace))
            } else {
                favoritePlace = UIBarButtonItem(image: UIImage(named: "favorite-empty"), style: .plain, target: self, action: #selector(favorPlace))
            }
        } else {
            favoritePlace = UIBarButtonItem(image: UIImage(named: "favorite-empty"), style: .plain, target: self, action: #selector(favorPlace))
        }
        let tweetAPlace = UIBarButtonItem(image: UIImage(named: "tweet"), style: .plain, target: self, action: #selector(tweetPlace))
        self.navigationItem.rightBarButtonItems  = [favoritePlace, tweetAPlace]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func tweetPlace(sender: UIBarButtonItem) {
        var tweetString = "Check out \(self.placeInfo.placeName!)  located at \(self.placeInfo.formattedAddr!). "
        var web = "";
        if let website = self.placeInfo.website as? String {
                web = website
        } else if let website = self.placeInfo.googlePage as? String {
            web = website
        }
        if(web != "") {
            tweetString += "Website: "
            tweetString = tweetString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            tweetString += web
            tweetString = "https://twitter.com/intent/tweet?hashtags=TravelAndEntertainmentSearch&text=" + tweetString
        } else {
            tweetString = tweetString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            tweetString = "https://twitter.com/intent/tweet?hashtags=TravelAndEntertainmentSearch&text=" + tweetString
        }
        UIApplication.shared.open(URL(string : tweetString)!, options: [:], completionHandler: { (status) in
        })
    }
    
    @objc func favorPlace(sender: UIBarButtonItem) {
        let defaults = UserDefaults.standard
        if let favPlaces =  defaults.object(forKey: "tneFavList") as? [String : NSDictionary] {
            if let placeAlreadyFav = favPlaces[self.selectedPlaceId] as? NSDictionary {
                var favoritePlacesToStore = defaults.object(forKey: "tneFavList") as? [String : NSDictionary]
                favoritePlacesToStore?.removeValue(forKey: self.selectedPlaceId)
                defaults.set(favoritePlacesToStore, forKey: "tneFavList")
                sender.image = UIImage(named: "favorite-empty")
                self.view.showToast("\(self.placeInfo.placeName!) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: false)
            } else {
                var favoritePlacesToStore = defaults.object(forKey: "tneFavList") as? [String : NSDictionary]
                let dict : NSDictionary = [
                    "placeId": self.selectedPlaceId,
                    "placeName" : self.placeInfo.placeName,
                    "placeAddr" : self.placeInfo.formattedAddr,
                    "categoryURL" : self.placeInfo.categoryUrl,
                    "favouritesURL" : self.placeInfo.categoryUrl
                ]
                favoritePlacesToStore![self.selectedPlaceId] = dict
                defaults.set(favoritePlacesToStore, forKey: "tneFavList")
                sender.image = UIImage(named: "favorite-filled")
                self.view.showToast("\(self.placeInfo.placeName!) was added to favorites", position: .bottom, popTime: 1, dismissOnTap: false)
            }
        } else {
            var firstTimeStore = [String : NSDictionary]();
            let dict : NSDictionary = [
                "placeId": self.selectedPlaceId,
                "placeName" : self.placeInfo.placeName,
                "placeAddr" : self.placeInfo.formattedAddr,
                "categoryURL" : self.placeInfo.categoryUrl,
                "favouritesURL" : self.placeInfo.categoryUrl
            ]
            firstTimeStore[self.selectedPlaceId] = dict
            defaults.set(firstTimeStore, forKey: "tneFavList")
            defaults.setValue(firstTimeStore, forKey: "tneFavList")
            sender.image = UIImage(named: "favorite-filled")
            self.view.showToast("\(self.placeInfo.placeName!) was added to favorites", position: .bottom, popTime: 1, dismissOnTap: false)
        }
        
    }

}
