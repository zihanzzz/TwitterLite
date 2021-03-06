//
//  LeftMenuViewController.swift
//  TwiSwift
//
//  Created by James Zhou on 11/4/16.
//  Copyright © 2016 James Zhou. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum MenuSelection: Int {
        case timeline = 0, profile, mentions, settings, logout
    }
    
    @IBOutlet weak var leftMenuTableView: UITableView!
    
    @IBOutlet weak var appVersionLabel: UILabel!
    
    var hamburgerViewController: HamburgerViewController!
    
    private var homeNavigationController: UINavigationController!
    
    private var profileNavigationController: UINavigationController!
    
    private var mentionsNavigationController: UINavigationController!
    
    private var settingsNavigationController: UINavigationController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up VCs
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        homeNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
        let homeTweetsViewController = homeNavigationController.topViewController as? TweetsViewController
        homeTweetsViewController?.timelineChoice = UIConstants.TimelineEnum.home
        
        profileNavigationController = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        let profileViewController = profileNavigationController.topViewController as? ProfileViewController
        profileViewController?.user = User.currentUser
        
        mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
        let mentionsViewController = mentionsNavigationController.topViewController as? TweetsViewController
        mentionsViewController?.timelineChoice = UIConstants.TimelineEnum.mentions
        
        settingsNavigationController = storyboard.instantiateViewController(withIdentifier: "SettingsNavigationController") as! UINavigationController
        
        leftMenuTableView.dataSource = self
        leftMenuTableView.delegate = self
        
        leftMenuTableView.backgroundColor = UIConstants.twitterPrimaryBlue
        leftMenuTableView.separatorColor = UIColor.white
        leftMenuTableView.isScrollEnabled = false
        
        // remove empty cells
        leftMenuTableView.tableFooterView = UIView()
        
        // set up initial VC
        hamburgerViewController.contentViewController = homeNavigationController
        
        // set up app version label
        let version = UIConstants.getAppVersion()
        let appBundle = UIConstants.getAppBundle()
        appVersionLabel.text = "TwitterLite v\(version) (\(appBundle))"
        appVersionLabel.textColor = UIColor.white
        appVersionLabel.font = UIFont(name: UIConstants.getTextFontNameLight(), size: 16)
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIConstants.twitterPrimaryBlue
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuCell", for: indexPath) as! LeftMenuCell
        
        cell.backgroundColor = UIConstants.twitterPrimaryBlue
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case MenuSelection.timeline.rawValue:
            cell.setUpMenu(menuText: "Timeline", menuImageName: "home")
            break
        case MenuSelection.profile.rawValue:
            cell.setUpMenu(menuText: "Profile", menuImageName: "profile")
            break
        case MenuSelection.mentions.rawValue:
            cell.setUpMenu(menuText: "Mentions", menuImageName: "mention")
            break
        case MenuSelection.settings.rawValue:
            cell.setUpMenu(menuText: "Settings", menuImageName: "settings")
            break
        case MenuSelection.logout.rawValue:
            cell.setUpMenu(menuText: "Log Out", menuImageName: "logout-white")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case MenuSelection.timeline.rawValue:
            hamburgerViewController.contentViewController = homeNavigationController
            break
        case MenuSelection.profile.rawValue:
            hamburgerViewController.contentViewController = profileNavigationController
            break
        case MenuSelection.mentions.rawValue:
            hamburgerViewController.contentViewController = mentionsNavigationController
            break
        case MenuSelection.settings.rawValue:
            hamburgerViewController.contentViewController = settingsNavigationController
            break
        case MenuSelection.logout.rawValue:
            NotificationCenter.default.post(name: UIConstants.HamburgerEventEnum.didClose.notification, object: nil, userInfo: nil)
            let logoutAlert = UIAlertController(title: "Log Out", message: "Are you sure to log out of TwitterLite?", preferredStyle: .alert)
            logoutAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                logoutAlert.dismiss(animated: true, completion: nil)
            }))
            logoutAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                User.currentUser?.logout()
            }))
            present(logoutAlert, animated: true, completion: nil)
            break
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
