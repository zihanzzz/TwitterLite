//
//  ViewController.swift
//  Twitter User Interface
//
//  Created by Dean Brindley on 25/04/2015.
//  Copyright (c) 2015 Dean Brindley. All rights reserved.
//

import UIKit
//import SafariServices

let offset_HeaderStop: CGFloat = 40.0 // At this offset the Header stops its transformations
let distance_W_LabelHeader: CGFloat = 30.0 // The distance between the top of the screen and the top of the White Label

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    // MARK: Outlet properties
    
    var user: User!
    
    var timelineChoice: UIConstants.TimelineEnum?
    
    var userTweets: [Tweet]?
    
    var favoriteTweets: [Tweet]?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var followingButton: FollowingButton!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var linkLabel: UILabel!
    
    // COUNTINGS
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    var headerBlurImageView:UIImageView!
    var headerImageView:UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = true
        if (User.isCurrentUser(user: user)) {
            followingButton.isHidden = true
        }
        if (user.isFollowing)! {
            followingButton.setUpFollowingAppearance()
        } else {
            followingButton.setUpToFollowAppearance()
        }
        segmentedControl.tintColor = UIConstants.twitterPrimaryBlue
        
        // labels
        headerLabel.text = user.name
        nameLabel.text = user.name
        nameLabel.font = UIFont(name: UIConstants.getTextFontNameBold(), size: 22)
        nameLabel.textColor = UIColor.black
        
        screennameLabel.text = "@\(user.screenname!)"
        screennameLabel.textColor = UIConstants.twitterDarkGray
        screennameLabel.font = UIFont(name: UIConstants.getTextFontNameLight(), size: 16)
        
        userDescription.text = user.userDescription!
        userDescription.font = UIFont(name: UIConstants.getTextFontNameLight(), size: 18)
        userDescription.textColor = UIColor.black
        
        locationImageView.image = UIImage(named: "location")
        if (user.location == nil || user.location?.characters.count == 0) {
            locationLabel.text = "Internet"
        } else {
            locationLabel.text = user.location!
        }
        locationLabel.textColor = UIConstants.twitterDarkGray
        locationLabel.font = UIFont(name: UIConstants.getTextFontNameLight(), size: 15)
        locationLabel.sizeToFit()
        
        linkLabel.text = user.displayURL
        linkImageView.image = UIImage(named: "link")
        linkLabel.textColor = UIConstants.twitterPrimaryBlue
        linkLabel.font = UIFont(name: UIConstants.getTextFontNameLight(), size: 15)
        linkLabel.sizeToFit()
        
        let linkTap = UITapGestureRecognizer()
        linkTap.numberOfTapsRequired = 1
        linkTap.addTarget(self, action: #selector(linkTapped))
        linkLabel.isUserInteractionEnabled = true
        linkLabel.addGestureRecognizer(linkTap)
        
        for label in [tweetsLabel, followingLabel, followersLabel] {
            label?.textColor = UIConstants.twitterLightGray
        }
        
        tweetsCountLabel.text = UIConstants.getFriendlyCounts(count: user.tweetsCount!)
        followingCountLabel.text = UIConstants.getFriendlyCounts(count: user.followingCount!)
        followersCountLabel.text = UIConstants.getFriendlyCounts(count: user.followersCount!)
        
        for label in [tweetsCountLabel, followingCountLabel, followersCountLabel] {
            label?.sizeToFit()
            label?.textColor = UIConstants.twitterPrimaryBlue
            label?.font = UIFont(name: UIConstants.getTextFontNameBold(), size: 17)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        segmentedControl.selectedSegmentIndex = 0
        timelineChoice = UIConstants.TimelineEnum.user
        segmentedControl.addTarget(self, action: #selector(onChangeTimeline(_:)), for: .valueChanged)
        
        let userParams = ["screen_name": user.screenname!]
        TwiSwiftClient.sharedInstance?.timelineWithChoice(choice: UIConstants.TimelineEnum.user, params: userParams, completionHandler: { (tweets: [Tweet]?, error: Error?) in
             self.userTweets = tweets
             self.tableView.reloadData()
        })
        
        let favoriteParams = ["screen_name": user.screenname!]
        TwiSwiftClient.sharedInstance?.timelineWithChoice(choice: UIConstants.TimelineEnum.favorite, params: favoriteParams, completionHandler: { (tweets: [Tweet]?, erro: Error?) in
            self.favoriteTweets = tweets
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
        
        followingButton.addTarget(self, action: #selector(followingButtonTapped(_:)), for: .touchUpInside)
    }
    
    func linkTapped() {
        if let url = URL(string: user.profileURL!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
// SFSafariViewController not working properly : (
//            let svc = SFSafariViewController(url: url)
//            present(svc, animated: true, completion: nil)
        }
    }
    
    func onChangeTimeline(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            timelineChoice = UIConstants.TimelineEnum.user
            break
        case 1:
            timelineChoice = UIConstants.TimelineEnum.favorite
            break
        default:
            break
        }
        tableView.reloadData()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        // Avatar
        let largeAvatarUrl = user.profileImageUrl!.replacingOccurrences(of: "normal", with: "200x200")
        avatarImage.setImageWith(URL(string: largeAvatarUrl)!)
        avatarImage.layer.cornerRadius = 10
        avatarImage.layer.borderColor = UIColor.white.cgColor
        avatarImage.layer.borderWidth = 3
        
        // Header - Image
        headerImageView = UIImageView(frame: headerView.bounds)
        if user.bannerImageView?.image == nil {
            headerImageView.setImageWith(URL(string: User.getDisplayableBannerURL(user: user))!)
        } else {
            headerImageView?.image = user.bannerImageView?.image
        }
        
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerView.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        headerBlurImageView = UIImageView(frame: headerView.bounds)
        
        if user.bannerImageView?.image == nil {
            headerBlurImageView?.image = headerImageView.image?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
        } else {
            headerBlurImageView?.image = user.bannerImageView?.image?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
        }
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 0.0
        headerView.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        headerView.clipsToBounds = true
    }

    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if timelineChoice == UIConstants.TimelineEnum.user {
            return userTweets?.count ?? 0
        } else if timelineChoice == UIConstants.TimelineEnum.favorite {
            return favoriteTweets?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.selectionStyle = .none
        cell.clearCellState()
        
        if timelineChoice == UIConstants.TimelineEnum.user {
            if let tweet = userTweets?[indexPath.row] {
                cell.tweet = tweet
            }
        } else if timelineChoice == UIConstants.TimelineEnum.favorite {
            
            if let tweet = favoriteTweets?[indexPath.row] {
                cell.tweet = tweet
            }
        }
        return cell
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offset = scrollView.contentOffset.y + headerView.bounds.height
        
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            // Hide views if scrolled super fast
            headerView.layer.zPosition = 0
            headerLabel.isHidden = true
        }
            
            // SCROLL UP/DOWN ------------
        else {
            // Header -----------
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            headerLabel.isHidden = false
            let alignToNameLabel = -offset + nameLabel.frame.origin.y + headerView.frame.height + offset_HeaderStop
            
            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop))
            
            //  ------------ Blur
            headerBlurImageView?.alpha = min (1.0, (offset - alignToNameLabel)/distance_W_LabelHeader)
            
            // Avatar -----------
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if avatarImage.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
            } else {
                if avatarImage.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        headerView.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
        
        // Segment control
        
        let segmentViewOffset = profileView.frame.height - segmentedView.frame.height - offset
        
        var segmentTransform = CATransform3DIdentity
        
        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
        
        segmentedView.layer.transform = segmentTransform

        // Set scroll view insets just underneath the segment control
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
    }
    
    func followingButtonTapped(_ sender: FollowingButton) {
        
        if (sender.isFollowing!) {
            
            
            let unfollowAlert = UIAlertController(title: "\(user.name!)", message: nil, preferredStyle: .actionSheet)
            
            unfollowAlert.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) in
                
                self.followingButton.setUpToFollowAppearance()
                
                TwiSwiftClient.sharedInstance?.changeFriendshipStatus(toFollow: false, screenName: self.user.screenname!, completionHandler: { (result) in
                    
                    if (!result!) {
                        self.followingButton.setUpFollowingAppearance()
                    }
                })
            }))
            
            unfollowAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(unfollowAlert, animated: true, completion: nil)
            
            
        } else {
            
            sender.setUpFollowingAppearance()
            TwiSwiftClient.sharedInstance?.changeFriendshipStatus(toFollow: true, screenName: self.user.screenname!, completionHandler: { (result) in
                
                if (!result!) {
                    self.followingButton.setUpToFollowAppearance()
                }
    
            })
        }
    }
}

