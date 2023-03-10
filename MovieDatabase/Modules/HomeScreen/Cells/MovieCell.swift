//
//  MovieCellCollectionViewCell.swift
//  MovieDatabase
//
//  Created by ardy on 09/03/23.
//

import UIKit

class MovieCell: UICollectionViewCell {
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let identifier = String(describing: MovieCell.self)
    static let nib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure(posterImage)
        
    }
    
    func configure(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = 14
        imageView.showGradientSkeleton(animated: true, delay: 0)
        titleLabel.showGradientSkeleton(animated: true, delay: 0)
    }
}
