//
//  ExplorerHeader.swift
//  Capture
//
//  Created by Mathias Palm on 2016-08-24.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit


class ExplorerHeader: UICollectionReusableView {
    fileprivate let ApiKeyExplorerTag = "explorer_header_tag"
    fileprivate let ApiKeyExplorerImg = "explorer_header_img"

    @IBOutlet weak var headerCollectionView: UICollectionView!
    @IBOutlet weak var headerPageControl: UIPageControl!
    @IBOutlet weak var headerGradientView: UIView!
    
    var headerData: [Tag]? {
        didSet {
            if let data = headerData {
                headerPageControl.numberOfPages = data.count
                headerCollectionView.reloadData()
            }
        }
    }
    
    func getExplorerHeaderTags() {
        SearchManager.sharedInstance.popularTags({tags, error in
            guard tags != nil && error == nil else {
                debugPrint(error)
                return
            }
            if let tags = tags {
                self.headerData = tags
                DispatchQueue.main.async {
                    self.headerCollectionView.reloadData()
                }
            }
        })
    }

    lazy var gradientLayer:CAGradientLayer = {
        var gradient = CAGradientLayer()
        let color1 = UIColor.clear.cgColor as CGColor
        let color2 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor as CGColor
        gradient.colors = [color1, color2]
        gradient.locations = [0, 1]
        return gradient
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = headerGradientView.bounds
    }
    func setGradient() {
        headerGradientView.layer.addSublayer(gradientLayer)
    }
}

extension ExplorerHeader: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = headerData {
            return data.count
        }
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerPageCell", for: indexPath) as! ExplorerPageCell
        if let data = headerData , data.count > (indexPath as NSIndexPath).row {
            let row = data[(indexPath as NSIndexPath).row]
            cell.urlString = row.tagimage
            cell.string = row.name
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = headerCollectionView.contentOffset.x
        let w = headerCollectionView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        headerPageControl.currentPage = currentPage
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var scrollOffset = scrollView.contentOffset.x
        let contentWidht = headerCollectionView.contentSize.width - headerCollectionView.frame.size.width
        var indexPath:IndexPath?
        if scrollOffset < 0 {
            indexPath = IndexPath(row: 0, section: 0)
        } else if scrollOffset > contentWidht {
            indexPath = IndexPath(row: headerPageControl.numberOfPages-1, section: 0)
            scrollOffset = scrollOffset - contentWidht
        }
        if let indexPath = indexPath {
            if let cell = headerCollectionView.cellForItem(at: indexPath) as? ExplorerPageCell {
                cell.zoomBackground(scrollOffset, y: 0)
            } else if let cell = headerCollectionView.cellForItem(at: indexPath) as? ExplorerPageCell {
                cell.zoomBackground(scrollOffset, y: 0)
            }
        }
    }
}

class ExplorerPageCell: UICollectionViewCell {
    @IBOutlet weak var pageImageView: ImageView!
    @IBOutlet weak var pageLabel: UILabel!
    
    var id:Int?
    var string: String? {
        didSet {
            if let tag = string , tag.characters.count > 0 {
                pageLabel.text = "#\(tag)"
            }
        }
    }
    
    var urlString: String? {
        didSet {
            if let urlString = urlString , urlString.characters.count > 0 {
                pageImageView.loadImage(urlString)
            }
        }
    }

    
//    func setImage(_ urlString: String) {
//        pageImageView.loadImage(urlString)
//    }
    func zoomBackground(_ x: CGFloat, y: CGFloat) {
        let width = bounds.width
        let scale = (width + 2.0*abs(0.5*(x+y)))/width
        pageImageView.transform = CGAffineTransform.identity.translatedBy(x: x, y: y)
        pageImageView.transform = pageImageView.transform.scaledBy(x: scale, y: scale)
    }
}
