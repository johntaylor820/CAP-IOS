//
//  ExplorerTags.swift
//  Capture
//
//  Created by Mathias Palm on 2016-08-24.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit


protocol ExplorerTagsDelegate {
    func goTags()
}


class ExplorerTags: UICollectionViewCell {
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    var delegate : ExplorerTagsDelegate? = nil

    var postData: [Tag]? {
        didSet {
            if let data = postData {
                if data.count > 0 {
                    tagCollectionView.reloadData()
                }
            }
        }
    }
    func getPopularTags() {
        
        SearchManager.sharedInstance.popularTags({tags, error in
            guard tags != nil && error == nil else {
                debugPrint(error)
                return
            }
            if let tags = tags {
                self.postData = tags
                DispatchQueue.main.async {
                    self.tagCollectionView.reloadData()
                    
                }
            }
        })

    }
}
extension ExplorerTags: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let data = postData {
//            return data.count
//        }
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tag", for: indexPath) as! ExplorerTagCell
        if let data = postData , data.count > (indexPath as NSIndexPath).row {
            let row = data[(indexPath as NSIndexPath).row]
            cell.id = row.postid
            cell.tagName = row.name
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var width:CGFloat = 100
        let height = collectionView.frame.size.height/3 - 6
        if let data = postData , data.count > (indexPath as NSIndexPath).row {
            let row = data[(indexPath as NSIndexPath).row]
            width = row.width + 40
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("here")
        print(indexPath)
        print(delegate)
        
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? ExplorerTagCell{
            if let id = cell.id {
                idToPass = id
            }
            delegate?.goTags()
        }
        
    }

    
}
class ExplorerTagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    
    var id: Int?
    var tagName: String? {
        didSet {
            tagLabel.text = tagName
        }
    }
}
