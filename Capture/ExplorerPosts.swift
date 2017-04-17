//
//  ExplorerPosts.swift
//  Capture
//
//  Created by Mathias Palm on 2016-08-24.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

protocol ExplorerPostsDelegate {
    func goPost()
}

class ExplorerPosts: UICollectionViewCell {
    
    var delegate : ExplorerPostsDelegate? = nil
    
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    var postData: [Posts]? {
        didSet {
            if let data = postData {
                if data.count > 0 {
                    postsCollectionView.reloadData()
                }
            }
        }
    }
    
    func getPopularPosts() {
        SearchManager.sharedInstance.popularVideos({posts, error in
            guard posts != nil && error == nil else {
                debugPrint(error)
                return
            }
            if let posts = posts {
                self.postData = posts
                DispatchQueue.main.async {
                    self.postsCollectionView.reloadData()
                    
                }
            }
        })

    }
    
}

extension ExplorerPosts: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = postData {
            return data.count
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! ExplorerPostCell
        if let data = postData , data.count > (indexPath as NSIndexPath).row {
            let row = data[(indexPath as NSIndexPath).row]
            cell.id = row.id
            cell.urlString = row.videoThumb

        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ colloectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) ->Bool{
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("here")
        print(indexPath)
        print(delegate)
        
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? ExplorerPostCell{
            if let id = cell.id {
                idToPass = id
            }
        delegate?.goPost()
        }
        
    }
    
}


class ExplorerPostCell: UICollectionViewCell {
    @IBOutlet weak var postImageView: ImageView!
    @IBOutlet weak var playImage: ShadowImage!
    
    var id:Int?
    var urlString: String? {
        didSet {
            if let urlString = urlString , urlString.characters.count > 0 {
                postImageView.loadImage(urlString)
            }
        }
    }
}
