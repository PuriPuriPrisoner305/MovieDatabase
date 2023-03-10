//
//  MovieDetailView.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import UIKit
import RxSwift
import YouTubePlayer

class MovieDetailView: UIViewController {
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var overviewDetailLabel: UILabel!
    
    @IBOutlet weak var videoPlayer: YouTubePlayerView!
    
    @IBOutlet weak var trailerView: UIView!
    var viewModel = MovieDetailViewModel()
    
    var movieID = 0
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        listenToViewModel()
        fetchDetailData()
        setupVideoPlayer()
    }
    
    func fetchDetailData() {
        viewModel.fetchMovieDetail(id: movieID)
    }
    
    func listenToViewModel() {
        viewModel.onSuccessFetchData
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                if value {
                    self.imageCollectionView.reloadData()
                    self.setupView()
                    self.setupPageView()
                    self.setupVideoPlayer()
                }
            }).disposed(by: bag)
    }
    
    func setupCollectionView() {
        imageCollectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
    }
    
    func setupView() {
        overviewDetailLabel.text = viewModel.movieDetail?.overview ?? "-"
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
    
    func setupVideoPlayer() {
        guard let result = viewModel.movieDetail?.videos?.results else { return }
        for data in result {
            guard let type = data.type,
                  let site = data.site
            else { return }
            if type.lowercased() == "trailer" && site.lowercased() == "youtube" {
                guard let key = data.key,
                      let videoUrl = URL(string: "ttps://www.youtube.com/watch?v=\(key)")
                else { return }
                videoPlayer.loadVideoURL(videoUrl)
                break
            }
        }
    }

}

extension MovieDetailView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        cell.imageView.kf.setImage(with: viewModel.imageUrl[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imageCollectionView {
            return CGSize(width: collectionView.frame.size.width, height: 350)
        } else {
            return CGSize(width: 0, height: 0)
        }
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

