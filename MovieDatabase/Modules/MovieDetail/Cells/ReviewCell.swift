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
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var reviewLabel: UILabel!
    
    static let identifier = String(describing: ReviewCell.self)
    static let nib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    func setupCell() {
        setupAvatarView()
        setupRatingView()
    }
    
    func setupAvatarView() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.borderWidth = 2.0
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        contentView.clipsToBounds = true
    }
    
    func setupRatingView() {
        ratingView.layer.borderWidth = 1.0
        ratingView.layer.borderColor = UIColor.white.cgColor
        ratingView.layer.cornerRadius = 4
    }

}
