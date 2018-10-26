//
//  collectionviewcustomecellCollectionViewCell.swift
//  test
//
//  Created by user147796 on 10/24/18.
//  Copyright © 2018 user147796. All rights reserved.
//

import UIKit

class collectionviewcustomecellCollectionViewCell: UICollectionViewCell {
    @IBOutlet var sentimentBtn: UIButton!
    @IBOutlet var img: UIImageView!

    func configrationCell (_ text : String,customimg : String)
    {
        sentimentBtn.layer.borderWidth = 1
        sentimentBtn.layer.cornerRadius = 15
        sentimentBtn.clipsToBounds = true
        sentimentBtn.setTitle(text, for: .normal)
       img.image = UIImage(named: customimg)
        
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
    
}
