////
////  SearchDataSource.swift
////  Capture
////
////  Created by Mathias Palm on 2016-09-29.
////  Copyright © 2016 capture. All rights reserved.
////
//
//import UIKit
//
//extension SearchViewController {
//
//    func searchCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch type {
//        case .user:
//            return users.count
//        case .tag:
//            return tags.count
//        case .trendingTag:
//            return popularTags.count
//        case .trendingUser:
//            return popularUsers.count
//        case .popular:
//            return popularPosts.count
//        }
//    }
//    func searchCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var cell:UICollectionViewCell!
//        let row = (indexPath as NSIndexPath).row
//        switch type {
//        case .user:
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchUserCell", for: indexPath) as? UserViewCell
//            if let c = cell as? UserViewCell {
//                let user = users[row]
//                c.name = user.getName()
//                c.username = user.username
//                c.imageURL = user.profileImage
//                c.id = user.id
//            }
//        case .tag:
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchTagCell", for: indexPath) as? TagViewCell
//            if let c = cell as? TagViewCell {
//                let tag = tags[row]
//                c.tagString = tag.name
//            }
//        case .trendingTag:
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as? TrendingViewCell
//            if let c = cell as? TrendingViewCell {
//                let tag = popularTags[row]
//                c.name = "#\(tag.name)"
//                c.id = tag.postid
//            }
//        case .trendingUser:
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as? TrendingViewCell
//            if let c = cell as? TrendingViewCell {
//                let user = popularUsers[row]
//                c.name = user.getName()
//                c.id = user.id
//            }
//        case .popular:
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularCell", for: indexPath) as? PopularViewCell
//            if let c = cell as? PopularViewCell {
//                let post = popularPosts[row]
//                c.postID = post.id
//                c.thumb = post.videoThumb
//            }
//        }
//        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        cell.contentView.frame = cell.bounds
//        return cell
//    }
//    func searchCollectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if type == .trendingUser || type == .trendingTag {
//            if kind == UICollectionElementKindSectionHeader {
//                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,withReuseIdentifier:"trendingHeader" , for: indexPath) as! TrendingReusableView
//                if type == .trendingTag {
//                    headerView.name = "Trending Tags"
//                } else {
//                    headerView.name = "Trending People"
//                }
//                return headerView
//            } else {
//                return UICollectionReusableView()
//            }
//        }
//        return UICollectionReusableView()
//    }
//    
//    func searchCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        let flow = searchCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        if type == .popular {
//            flow.minimumLineSpacing = 10.0
//            return UIEdgeInsetsMake(10, 10, 10, 10)
//        }
//        flow.minimumLineSpacing = 0.0
//        return UIEdgeInsetsMake(0, 0, 0, 0)
//    }
//    
//    func searchCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        if type == .trendingUser || type == .trendingTag {
//            return CGSize(width: screen.size.width, height: 75)
//        } else {
//            return CGSize.zero
//        }
//    }
//    func searchCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
//        var size = CGSize(width: screen.size.width, height: 50)
//        switch type {
//        case .user, .tag:
//            size.height = 60
//        case .trendingTag, .trendingUser:
//            size.height = 40
//        case .popular:
//            size.width = screen.size.width/2 - 15
//            size.height = size.width
//        }
//        return size
//    }
//}
//
//extension SearchViewController {
//    func searchCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell:UICollectionViewCell?
//        switch type {
//        case .user:
//            cell = collectionView.cellForItem(at: indexPath)
//            if let cell = cell as? UserViewCell, let id = cell.id {
//                showUser(id)
//            }
//        case .tag:
//            cell = collectionView.cellForItem(at: indexPath)
//            if let cell = cell as? TagViewCell {
//                idToPass = cell.id
//                performSegue(withIdentifier: "showPost", sender: nil)
//            }
//        case .trendingTag:
//            cell = collectionView.cellForItem(at: indexPath)
//            if let cell = cell as? TrendingViewCell {
//                idToPass = cell.id
//                performSegue(withIdentifier: "showPost", sender: nil)
//            }
//        case .trendingUser:
//            cell = collectionView.cellForItem(at: indexPath)
//            if let cell = cell as? TrendingViewCell, let id = cell.id {
//                showUser(id)
//            }
//        case .popular:
//            cell = collectionView.cellForItem(at: indexPath)
//            if let cell = cell as? PopularViewCell {
//                idToPass = cell.postID
//                performSegue(withIdentifier: "showPost", sender: nil)
//            }
//        }
//    }
//    
//    func showUser(_ id: Int) {
//        if id == UserManager.sharedInstance.user!.id {
//            tabBarController?.selectedIndex = 4
//        } else {
//            idToPass = id
//            performSegue(withIdentifier: "showUser", sender: nil)
//        }
//    }
//}
//
//
//
//
