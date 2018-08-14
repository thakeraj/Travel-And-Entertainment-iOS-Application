//
//  PlaceInfoViewController.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/9/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit
import SwiftSpinner
import Cosmos

class PlaceInfoVC: UIViewController {

    @IBOutlet weak var placeAddrLbl: UITextView!
    @IBOutlet weak var phoneNoLbl: UITextView!
    @IBOutlet weak var priceLbl: UITextView!
    @IBOutlet weak var websiteLbl: UITextView!
    @IBOutlet weak var ratingsLbl: UITextView!
    @IBOutlet weak var googleLbl: UITextView!
    
    @IBOutlet weak var placeAddr: UITextView!
    @IBOutlet weak var placeNumber: UITextView!
    @IBOutlet weak var priceLevel: UITextView!
    @IBOutlet weak var placeRating: CosmosView!
    @IBOutlet weak var placeWebsite: UITextView!
    @IBOutlet weak var googlePage: UITextView!
    var placeInfo : PlaceDetailsInfoModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateInfoValues()
        SwiftSpinner.hide()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func populateInfoValues() {
        if(placeInfo != nil) {
            if(placeInfo.formattedAddr != nil) {
                placeAddr.text = placeInfo.formattedAddr
                placeAddrLbl.isHidden = false
                placeAddr.isHidden = false
            } else {
                placeAddrLbl.isHidden = true
                placeAddr.isHidden = true
            }
            if(placeInfo.phoneNumber != nil) {
                placeNumber.text = placeInfo.phoneNumber
                placeNumber.isHidden = false
                phoneNoLbl.isHidden = false
            } else {
                placeNumber.isHidden = true
                phoneNoLbl.isHidden = true
            }
            if(placeInfo.priceLevel != nil) {
                let priceLevels : Int = Int(placeInfo.priceLevel!)
                var pricing = ""
                if(priceLevels < 1) {
                    pricing = "Free"
                } else {
                    for x in 1...priceLevels {
                        pricing = pricing+"$"
                    }
                }
                priceLevel.text = pricing
                priceLbl.isHidden = false
                priceLevel.isHidden = false
            } else {
                priceLbl.isHidden = true
                priceLevel.isHidden = true
            }
            if(placeInfo.ratings != nil) {
                placeRating.rating = Double(placeInfo.ratings)
                print("RATING \(placeRating.rating)")
                placeRating.isHidden = false
                ratingsLbl.isHidden = false
            } else {
                placeRating.isHidden = true
                ratingsLbl.isHidden = true
            }
            if(placeInfo.website != nil) {
                placeWebsite.text = placeInfo.website
                placeWebsite.isHidden = false
                websiteLbl.isHidden = false
            } else {
                placeWebsite.isHidden = true
                websiteLbl.isHidden = true
            }
            if(placeInfo.googlePage != nil) {
                googlePage.text = placeInfo.googlePage
                googlePage.isHidden = false
                googleLbl.isHidden = false
            } else {
                googlePage.isHidden = true
                googleLbl.isHidden = true
            }
        }
    }
}
