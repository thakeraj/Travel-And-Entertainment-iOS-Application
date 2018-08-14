//
//  ReviewsVC.swift
//  TravelAndEntertainment
//
//  Created by Raj Thaker on 4/10/18.
//  Copyright © 2018 Raj Thaker. All rights reserved.
//

import UIKit

class ReviewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var googleReviews : [ReviewModel]!
    var yelpReviews : [ReviewModel]!
    var reviewsToDisplay : [ReviewModel]!
    @IBOutlet weak var noReviewsView: UIView!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var reviewsToggler: UISegmentedControl!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var orderSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewsToDisplay = googleReviews
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let reviews = reviewsToDisplay {
            if(reviews.count > 0 )
            {
                reviewsTableView.isHidden = false
                noReviewsView.isHidden = true
                return reviews.count
            } else {
                reviewsTableView.isHidden = true
                noReviewsView.isHidden = false
            }
        } else {
            reviewsTableView.isHidden = true
            noReviewsView.isHidden = false
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewsCell", for: indexPath) as! ReviewsCell
        let currentReview : ReviewModel = reviewsToDisplay[indexPath.row]
        if let authorName = currentReview.name {
            cell.name.text = authorName
        }
        if let userRating = currentReview.rating {
            cell.rating.rating = userRating
        }
        if let userTime = currentReview.time {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let reviewDate = NSDate(timeIntervalSince1970: TimeInterval(userTime))
            let reviewDateString = dateFormatterGet.string(from: reviewDate as Date)
            cell.time.text = "\(reviewDateString)"
        } else if let yelpUserTime = currentReview.yelpTimeCreated {
            cell.time.text = "\(yelpUserTime)"
        }
        if let userReview = currentReview.review {
            cell.reviewText.text = userReview
        }
        if let imageUrl = currentReview.imageUrl {
            let url = URL(string: imageUrl)
            let data = try? Data(contentsOf: url!)
            cell.reviewersPhoto.image = UIImage(data: data!)
        } else {
            cell.reviewersPhoto.image = nil
        }
        return cell
    }
    
    @IBAction func reviewsToggle(_ sender: UISegmentedControl) {
        sortReviews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentReview = reviewsToDisplay[indexPath.row] as? ReviewModel {
            if let url = currentReview.authorUrl as? String {
                UIApplication.shared.open(URL(string : url)!, options: [:], completionHandler: { (status) in })
            }
        }
    }
    
    @IBAction func sortReviewsSegment(_ sender: UISegmentedControl) {
        sortReviews()
    }
    
    @IBAction func orderReviewsSegment(_ sender: UISegmentedControl) {
        sortReviews()
    }
    
    
    func sortReviews() {
        if(reviewsToggler.selectedSegmentIndex == 0) {
            if let reviewsToDisplay = googleReviews as? [ReviewModel] {
                self.reviewsToDisplay = performSorting(reviews: reviewsToDisplay)
            } else {
                self.reviewsToDisplay = googleReviews
            }
        } else if(reviewsToggler.selectedSegmentIndex == 1) {
            if let reviewsToDisplay = yelpReviews as? [ReviewModel] {
                self.reviewsToDisplay = performSorting(reviews: reviewsToDisplay)
            } else {
                self.reviewsToDisplay = yelpReviews
            }
        }
        self.reviewsTableView.reloadData()
    }
    
    
    func performSorting(reviews: [ReviewModel]) -> [ReviewModel]{
        if(sortSegmentedControl.selectedSegmentIndex == 0) {
            return reviews
        } else if(sortSegmentedControl.selectedSegmentIndex == 1) {
            if(self.orderSegmentedControl.selectedSegmentIndex == 0) {
                return (reviews.sorted(by: {$0.rating < $1.rating}))
            } else if(self.orderSegmentedControl.selectedSegmentIndex == 1) {
                return (reviews.sorted(by: {$0.rating > $1.rating}))
            }
        } else if(sortSegmentedControl.selectedSegmentIndex == 2) {
            if(self.orderSegmentedControl.selectedSegmentIndex == 0) {
                if let googleDates = reviews[0].time as? UInt64 {
                    return (reviews.sorted(by: {$0.time < $1.time}))
                } else {
                    return (reviews.sorted(by: {
                        
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date1 = dateFormatterGet.date(from: $0.yelpTimeCreated)
                        let s1 = Double((date1?.timeIntervalSince1970)!)
                        let date2 = dateFormatterGet.date(from: $1.yelpTimeCreated)
                        let s2 = Double((date2?.timeIntervalSince1970)!)
                        return s1 < s2}))
                    
                }
            } else if(self.orderSegmentedControl.selectedSegmentIndex == 1) {
                if let googleDates = reviews[0].time as? UInt64 {
                    return (reviews.sorted(by: {$0.time > $1.time}))
                }else {
                    return (reviews.sorted(by: {
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date1 = dateFormatterGet.date(from: $0.yelpTimeCreated)
                        let s1 = Double((date1?.timeIntervalSince1970)!)
                        let date2 = dateFormatterGet.date(from: $1.yelpTimeCreated)
                        let s2 = Double((date2?.timeIntervalSince1970)!)
                        return s1 > s2}))
                    
                }
            }
        }
        return reviews
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
