//
//  ExplorerViewController.swift
//  Capture
//
//  Created by Mathias Palm on 2016-08-23.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

extension SearchViewController {    
    func explorerCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch type {
        case .user:
            return users.count
        case .tag:
            return tags.count
        case .trendingTag:
            return popularTags.count
        case .trendingUser:
            return popularUsers.count
        case .popular:
            return 7
        }
    }
    
    func explorerCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell!
        let row = (indexPath as NSIndexPath).row
        switch type{
        case .user:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchUserCell", for: indexPath) as? UserViewCell
            if let c = cell as? UserViewCell {
                let user = users[row]
                c.name = user.getName()
                c.username = user.username
                c.imageURL = user.profileImage
                c.id = user.id
            }
        case .tag:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchTagCell", for: indexPath) as? TagViewCell
            if let c = cell as? TagViewCell {
                let tag = tags[row]
                c.tagString = tag.name
            }
        case .trendingTag:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as? TrendingViewCell
            if let c = cell as? TrendingViewCell {
                let tag = popularTags[row]
                c.name = "#\(tag.name)"
                c.id = tag.postid
            }
        case .trendingUser:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as? TrendingViewCell
            if let c = cell as? TrendingViewCell {
                let user = popularUsers[row]
                c.name = user.getName()
                c.id = user.id
            }
        case .popular:
            switch row {
            case 0:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! ExplorerLabel
                if let cell = cell as? ExplorerLabel {
                    cell.string = "Popular Posts"
                }
            case 1:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! ExplorerPosts
                
                if let cell = cell as? ExplorerPosts {
                    cell.delegate = self
                    cell.getPopularPosts()
                }
            case 2:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! ExplorerLabel
                if let cell = cell as? ExplorerLabel {
                    cell.string = "Popular People"
                }
            case 3:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCell", for: indexPath) as! ExplorerPeople
                if let cell = cell as? ExplorerPeople {
                    cell.delegate = self
                    cell.getPopluarPeople()
                }
            case 4:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! ExplorerLabel
                if let cell = cell as? ExplorerLabel {
                    cell.string = "Trending Tags"
                }
            case 5:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCell", for: indexPath) as! ExplorerTags
                if let cell = cell as? ExplorerTags {
                    cell.delegate = self
                    cell.getPopularTags()
                }
            case 6:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! ExplorerLabel
                if let cell = cell as? ExplorerLabel {
                    cell.string = "Popular Posts Near Me"
                }
            default:
                cell = UICollectionViewCell()
            }
        default:
            cell = UICollectionViewCell()

        }
        
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.contentView.frame = cell.bounds
        return cell
    }
    
    func explorerCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:UICollectionViewCell?
        switch type {
        case .user:
            cell = collectionView.cellForItem(at: indexPath)
            if let cell = cell as? UserViewCell, let id = cell.id {
                showUser(id)
            }
        case .tag:
            cell = collectionView.cellForItem(at: indexPath)
            if let cell = cell as? TagViewCell {
                idToPass = cell.id
                performSegue(withIdentifier: "showPost", sender: nil)
            }
        case .trendingTag:
            cell = collectionView.cellForItem(at: indexPath)
            if let cell = cell as? TrendingViewCell {
                idToPass = cell.id
                performSegue(withIdentifier: "showPost", sender: nil)
            }
        case .trendingUser:
            cell = collectionView.cellForItem(at: indexPath)
            if let cell = cell as? TrendingViewCell, let id = cell.id {
                showUser(id)
            }
        default:
            break
        }

    }
    func explorerCollectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if type == .popular {
            switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! ExplorerHeader
                headerView.getExplorerHeaderTags()
                headerView.setGradient()
                return headerView
            case UICollectionElementKindSectionFooter:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! ExplorerFooter
                footerView.addLocations()
                return footerView
            default:
                return UICollectionReusableView()
            }
        }
        return UICollectionReusableView()
    }
    
//    func explorerCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        let flow = explorerCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        if type == .popular {
//            flow.minimumLineSpacing = 10.0
//            return UIEdgeInsetsMake(10, 10, 10, 10)
//        }
//        flow.minimumLineSpacing = 0.0
//        return UIEdgeInsetsMake(0, 0, 0, 0)
//    }
    
    func explorerCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if type == .popular {
            return CGSize(width: collectionView.frame.size.width, height: screen.size.height*0.35)
        } else {
            return CGSize.zero
        }
    }
    
    func explorerCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if type == .popular {
            return CGSize(width: collectionView.frame.size.width, height: screen.size.height*0.35)
        } else {
            return CGSize.zero
        }
    }
    
    func explorerCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: screen.size.width, height: 50)
        switch type {
        case .user, .tag:
            size.height = 60
        case .trendingTag, .trendingUser:
            size.height = 40
        default:
            switch (indexPath as NSIndexPath).row {
            case 1,3:
                return CGSize(width: collectionView.frame.size.width, height: screen.size.width*0.25)
            case 5:
                return CGSize(width: collectionView.frame.size.width, height: screen.size.width*0.35)
            default:
                return CGSize(width: collectionView.frame.size.width, height: 38)
            }

        }
        return size
        
    }
    
        func showUser(_ id: Int) {
            if id == UserManager.sharedInstance.user!.id {
                tabBarController?.selectedIndex = 4
            } else {
                idToPass = id
                performSegue(withIdentifier: "showUser", sender: nil)
            }
        }

    
}

