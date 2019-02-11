//
//  collectionViewCell.swift
//  Lab
//
//  Created by Singh, Gagandeep on 2/10/19.
//  Copyright © 2019 Singh, Gagandeep. All rights reserved.
//

import Foundation
import UIKit

class collectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkBtn: IndexPathCellButton!
    @IBOutlet weak var imageView: UIImageView!
    
    func displayContent(image: UIImage, isHidden: Bool){
        imageView.image = image
        checkBtn.isHidden = isHidden
        imageView.addSubview(checkBtn)
    }
    
    func selected(){
        checkBtn.isHidden = !checkBtn.isHidden
    }
    
    func isSelected() -> Bool {
        return !(checkBtn?.isHidden)!
    }
}
