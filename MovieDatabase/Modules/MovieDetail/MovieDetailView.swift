//
//  MovieDetailView.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import UIKit
import RxSwift

class MovieDetailView: UIViewController {
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var overviewDetailLabel: UILabel!
    
    var viewModel = MovieDetailViewModel()
    
    var movieID = 0
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        listenToViewModel()
        fetchDetailData()
    }
    
    func fetchDetailData() {
        viewModel.fetchMovieDetail(id: movieID)
    }
    
    func listenToViewModel() {
        viewModel.movieDetail
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.overviewDetailLabel.text = data.overview
                
            }).disposed(by: bag)
        
        viewModel.onSuccessFetchData
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                if value {
                    self.imageCollectionView.reloadData()
                    self.setupPageView()
                }
            }).disposed(by: bag)
    }
    
    func setupCollectionView() {
        imageCollectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
    }
    
    func setupPageView() {
        self.pageView.currentPage = 0
        self.pageView.numberOfPages = viewModel.imageUrl.count
//        self.timer()
    }
    
    func timer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard let currentIndexPath = self.imageCollectionView.indexPathsForVisibleItems.first else { return }
            let nextItemIndex = (currentIndexPath.item + 1) % self.viewModel.imageUrl.count
            
            let nextIndexPath = IndexPath(item: nextItemIndex, section: 0)
            self.imageCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
        timer.fire()
    }

}

extension MovieDetailView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        cell.imageView.kf.setImage(with: viewModel.imageUrl[indexPath.row])
        let currentIndexPath = self.imageCollectionView.indexPathsForVisibleItems.first
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 300)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let view = scrollView as? UICollectionView
        if view == imageCollectionView {
            let contentOffset = imageCollectionView.contentOffset
            let pageWidth = imageCollectionView.bounds.width
            let currentPage = Int(round(contentOffset.x / pageWidth))
            pageView.currentPage = currentPage
        }
    }
}

