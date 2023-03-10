//
//  ImageCell.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = String(describing: ImageCell.self)
    static let nib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
