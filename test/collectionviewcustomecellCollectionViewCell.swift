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
   
    func configrationCell (_ text : String)
    {
        sentimentBtn.layer.borderWidth = 1
        sentimentBtn.layer.cornerRadius = 8
        sentimentBtn.clipsToBounds = true
        sentimentBtn.setTitle(text, for: .normal)
        
    }
    
}
