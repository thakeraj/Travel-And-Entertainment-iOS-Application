//
//  PlacePhotosVC.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/10/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacePhotosVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var noPhotosView: UIView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var placeId : String!
    var placePhotos : [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placePhotos = [UIImage]()
        loadPhotos(placeId: placeId!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (placePhotos.count as? Int) != nil{
            return placePhotos.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placePhoto", for: indexPath) as! PlacePhotoCollectionCell
        cell.photoCell.image = placePhotos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.photosCollectionView.bounds.width, height: self.photosCollectionView.bounds.height/2.5)
    }

    func loadPhotos(placeId : String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                if let noOfPhotos = photos?.results.count {
                    if(noOfPhotos > 0) {
                        self.noPhotosView.alpha = 0
                        self.photosCollectionView.alpha = 1
                        for x in 0..<noOfPhotos {
                            loadImageForMetadata(photoMetadata: (photos?.results[x])!)
                        }
                    } else {
                        self.noPhotosView.alpha = 1
                        self.photosCollectionView.alpha = 0
                    }
                } else {
                    self.noPhotosView.alpha = 1
                    self.photosCollectionView.alpha = 0
                }
            }
        }
        
        func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata){
            GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
                (photo, error) -> Void in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.noPhotosView.alpha = 1
                    self.photosCollectionView.alpha = 0
                } else {
                    self.placePhotos.append(photo!)
                    self.photosCollectionView.reloadData()
                }
            })
        }
    }
}
