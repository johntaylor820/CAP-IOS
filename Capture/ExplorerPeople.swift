//
//  ExplorerPeople.swift
//  Capture
//
//  Created by Mathias Palm on 2016-08-24.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit

protocol ExplorerPeopleDelegate {
    func goUser()
}

class ExplorerPeople: UICollectionViewCell {
    
    @IBOutlet weak var peopleCollectionView: UICollectionView!
    var delegate : ExplorerPeopleDelegate? = nil

    var postData: [User]? {
        didSet {
            if let data = postData {
                if data.count > 0 {
                    peopleCollectionView.reloadData()
                }
            }
        }
    }
    
    func getPopluarPeople() {
//        postData = [User(dictionary:["fullname":"Jimmey kimmel" as AnyObject]), User(dictionary:["fullname":"Jimmey kimmel" as AnyObject]), User(dictionary:["fullname":"Jimmey kimmel" as AnyObject]), User(dictionary:["fullname":"Jimmey kimmel" as AnyObject]), User(dictionary:["fullname":"Jimmey kimmel" as AnyObject])]
        
        
        SearchManager.sharedInstance.popularUsers({users, error in
            guard users != nil && error == nil else {
                debugPrint(error)
                return
            }
            if let users = users {
                self.postData = users
                DispatchQueue.main.async {
                    self.peopleCollectionView.reloadData()
                    
                }
            }
        })

    }
}

extension ExplorerPeople: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let data = postData {
//            return data.count
//        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "people", for: indexPath) as! ExplorerPeopleCell
        if let data = postData , data.count > (indexPath as NSIndexPath).row {
            let row = data[(indexPath as NSIndexPath).row]
            cell.id = row.id
            cell.urlString = row.profileImage
            cell.name = row.getName()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height*0.8, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("here")
        print(indexPath)
        print(delegate)
        
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? ExplorerPeopleCell{
            if let id = cell.id {
                idToPass = id
            }
            delegate?.goUser()
        }
    }

    
}

class ExplorerPeopleCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: CircularImageViewWithOutBorder!
    @IBOutlet weak var nameLabel: UILabel!
    
    var id: Int?
    var urlString: String? {
        didSet {
            if let urlString = urlString , urlString.characters.count > 0 {
                profileImageView.loadImage(urlString)
            }
        }
    }
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
}
