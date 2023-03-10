//
//  HomeScreenView.swift
//  MovieDatabase
//
//  Created by ardy on 09/03/23.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import SkeletonView
import RxGesture

class HomeScreenView: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = HomeScreenViewModel()
    var apiManager = ApiManager()
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchData()
        registerDataBinding()
    }
    
    func registerDataBinding() {
        collectionView.register(MovieCell.nib, forCellWithReuseIdentifier: MovieCell.identifier)
        viewModel.movieList.bind(
            to: collectionView.rx.items(
                cellIdentifier: MovieCell.identifier,
                cellType: MovieCell.self)) { [weak self] (_, item, cell) in
                    guard let self = self else { return }
                    cell.posterImage.kf.setImage(with: self.apiManager.getImageUrl(item.posterImage ?? ""))
                    cell.titleLabel.text = item.title ?? "-"
                    cell.movieId = item.id ?? 0
                    cell.delegate = self
                    cell.posterImage.hideSkeleton()
                    cell.titleLabel.hideSkeleton()
            }
            .disposed(by: bag)
        
        collectionView.rx.willDisplayCell
            .subscribe { _, indexPath in
                let lastSection = self.collectionView.numberOfSections - 1
                let lastRow = self.collectionView.numberOfItems(inSection: lastSection) - 1
                if indexPath.section == lastSection && indexPath.row == lastRow {
                    self.viewModel.fetchData()
                }
            }.disposed(by: bag)
        
        collectionView.rx.setDelegate(self).disposed(by: bag)
    }
    
}

extension HomeScreenView: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = 30 + (flowLayout.minimumInteritemSpacing * CGFloat(1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(2))
        
        return CGSize(width: size, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

extension HomeScreenView: MovieCellDelegate {
    func didTap(id: Int) {
        guard let navigation = self.navigationController else { return }
        viewModel.navigateToMovieDetailView(id: id, from: navigation)
    }
}
