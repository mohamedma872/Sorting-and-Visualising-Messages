//
//  FullWidthCellsFlowLayout.swift
//  test
//
//  Created by user147813 on 10/24/18.
//  Copyright © 2018 user147796. All rights reserved.
//

import UIKit

class FullWidthCellsFlowLayout: UICollectionViewFlowLayout {
    func fullWidth(forBounds bounds:CGRect) -> CGFloat {
        
        let contentInsets = self.collectionView!.contentInset
        
        return bounds.width - sectionInset.left - sectionInset.right - contentInsets.left - contentInsets.right
    }
    
    // MARK: Overrides
    
    override func prepare() {
        itemSize.width = fullWidth(forBounds: collectionView!.bounds)
        super.prepare()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if !newBounds.size.equalTo(collectionView!.bounds.size) {
            itemSize.width = fullWidth(forBounds: newBounds)
            return true
        }
        return false
    }
}
