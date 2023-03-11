//
//  ReviewCell.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import UIKit

class ReviewCell: UICollectionViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    static let identifier = String(describing: ReviewCell.self)
    static let nib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
