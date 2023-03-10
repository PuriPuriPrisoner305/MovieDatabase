//
//  MovieCellCollectionViewCell.swift
//  MovieDatabase
//
//  Created by ardy on 09/03/23.
//

import UIKit
import RxSwift

protocol MovieCellDelegate {
    func didTap(id: Int)
}

class MovieCell: UICollectionViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let identifier = String(describing: MovieCell.self)
    static let nib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    
    var delegate: MovieCellDelegate?
    var movieId = 0
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        configure(posterImage)
    }
    
    func configure(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = 14
        imageView.showGradientSkeleton(animated: true, delay: 0)
        titleLabel.showGradientSkeleton(animated: true, delay: 0)
    }
    
    func setup() {
        self.contentView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didTap(id: self.movieId)
            }).disposed(by: bag)
    }
}
