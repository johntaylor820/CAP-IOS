//
//  SearchViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-05-04.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

var idToPass: Int?

class SearchViewController: UIViewController, ExplorerPostsDelegate, ExplorerPeopleDelegate, ExplorerTagsDelegate {
    
    
    @IBOutlet weak var explorerCollectionView: UICollectionView!
    var searchController:UISearchController!

    @IBOutlet weak var serachBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarView: UIView!
    
    let screen = UIScreen.main.bounds
    let layout = ExplorerCollectionFlowLayout()

    enum cellType {
        case tag
        case user
        case trendingTag
        case trendingUser
        case popular
    }
    var searchTerm = ""
    var users: [User] = []
    var tags: [Tag] = []
    var isAtEnd = false
    var isCanceling = false
    
    var type:cellType = cellType.popular {
        didSet {
            handleType()
        }
    }
    var popularUsers = [User]()
    var popularTags = [Tag]()
    var popularPosts = [Posts]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true

        searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        type = .popular
        // Setup the Scope Bar
        searchBar.scopeButtonTitles = ["People", "Tags"]
        searchBar.barTintColor = UIColor.white
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 242/255, green: 243/255, blue: 244/255, alpha: 1.0)
        searchBar.tintColor = UIColor(red: 3/255, green: 167/255, blue: 227/255, alpha: 1.0)
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBarView.addSubview(searchBar)
        serachBarViewHeightConstraint.constant = searchBar.frame.size.height
        layout.headerReferenceSize = CGSize(width: screen.size.width, height: screen.size.height*0.35)
        layout.headerReferenceSize = CGSize(width: screen.size.width, height: screen.size.height*0.35)
        explorerCollectionView.setCollectionViewLayout(layout, animated: false)
        explorerCollectionView.reloadData()
        view.layoutIfNeeded()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        searchController.searchBar.isHidden = false
    }
    
    func handleType() {
        switch type {
        case .user:
            break
        case .tag:
            break
        case .trendingTag:
            getPopularTags()
        case .trendingUser:
            getPopularUsers()
        case .popular:
            getPopularVideos()
        }
    }
    
    func getPopularUsers() {
        SearchManager.sharedInstance.popularUsers({users, error in
            guard users != nil && error == nil else {
                debugPrint(error)
                return
            }
            if let users = users {
                self.popularUsers = users
                DispatchQueue.main.async {
                    self.explorerCollectionView.reloadData()
                    
                }
            }
        })
    }
    
    func getPopularTags() {
        SearchManager.sharedInstance.popularTags({tags, error in
            guard tags != nil && error == nil else {
                debugPrint(error)
                return
            }
            if let tags = tags {
                self.popularTags = tags
                DispatchQueue.main.async {
                    self.explorerCollectionView.reloadData()

                }
            }
        })
    }
    func getPopularVideos() {
        SearchManager.sharedInstance.popularVideos({posts, error in
            guard posts != nil && error == nil else {
                debugPrint(error)
                return
            }
            if let posts = posts {
                self.popularPosts = posts
                DispatchQueue.main.async {
                    self.explorerCollectionView.reloadData()

                }
            }
        })
    }

    func shouUser() {
        searchController.searchBar.resignFirstResponder()
        searchController.searchBar.isHidden = true
        performSegue(withIdentifier: "showUser", sender: nil)
    }

    func filterContentForSearchText(_ searchText: String) {
        users.removeAll()
        users = []
        tags.removeAll()
        tags = []
        explorerCollectionView.reloadData()

        searchTerm = searchText
        if type == .user {
            searchUser(searchText)
        } else if type == .tag {
            searchTag(searchText)
        }
    }
    
    func goPost() {
        performSegue(withIdentifier: "showPost", sender: nil)
    }
    
    func goUser(){
        performSegue(withIdentifier: "showUser", sender: nil)
    }
    
    func goTags() {
        performSegue(withIdentifier: "showPost", sender: nil)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showUser" {
            let vc = segue.destination as! UserViewController
            if let id = idToPass {
                vc.userId = id
            } else {
                return
            }
        } else if segue.identifier == "showPost" {
            
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.viewControllers.first as! PostViewController
            if let id = idToPass {
                vc.postID = id
            }

        }
    }

}
extension SearchViewController {
    fileprivate func storeUsers(_ newUsers: [User]) {
        for user in newUsers {
            if !users.contains(user) {
                users.append(user)
            }
        }
        
    }
    func searchUser(_ query: String, refresh: Bool = false) {
        SearchManager.sharedInstance.searchUser(query, completion: {users, error in
            guard users != nil && error == nil else {
                self.isAtEnd = true
                return
            }
            if refresh {
                self.users = users!
            } else {
                self.storeUsers(users!)
            }
            DispatchQueue.main.async {
                self.explorerCollectionView.reloadData()

            }
        })
    }
    
    fileprivate func storeTags(_ newTags: [Tag]) {
        for tag in newTags {
            if !tags.contains(tag) {
                tags.append(tag)
            }
        }
    }
    func searchTag(_ query: String, refresh: Bool = false) {
        SearchManager.sharedInstance.searchTags(query, completion: {tags, error in
            guard tags != nil && error == nil else {
                self.isAtEnd = true
                return
            }
            if refresh {
                self.tags = tags!
            } else {
                self.storeTags(tags!)
            }
            DispatchQueue.main.async {
                self.explorerCollectionView.reloadData()

            }
        })
    }
    
    func handleSearchBar(_ searchBar: UISearchBar) {
        if !isCanceling {
            if searchBar.text!.characters.count > 0 {
                if searchBar.selectedScopeButtonIndex == 0 {
                    type = .user
                } else {
                    type = .tag
                }
                filterContentForSearchText(searchBar.text!)
            } else {
                if searchBar.selectedScopeButtonIndex == 0 {
                    type = .trendingUser
                } else {
                    type = .trendingTag
                }
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isCanceling = false
        var height = searchController.searchBar.frame.size.height*2
        if searchController.searchBar.showsScopeBar {
            height = searchController.searchBar.frame.size.height
        }
        if serachBarViewHeightConstraint.constant < height {
            serachBarViewHeightConstraint.constant = height
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
        if searchBar.text?.characters.count == 0 {
            handleSearchBar(searchController.searchBar)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isCanceling = true
        serachBarViewHeightConstraint.constant = searchController.searchBar.frame.size.height/2
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
        type = .popular
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        handleSearchBar(searchController.searchBar)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text , text.characters.count > 0 {
            handleSearchBar(searchController.searchBar)
        }
        isCanceling = false
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            explorerCollectionView(collectionView, didSelectItemAt: indexPath)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return explorerCollectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            return explorerCollectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            return explorerCollectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return explorerCollectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            return explorerCollectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            return explorerCollectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }
}




