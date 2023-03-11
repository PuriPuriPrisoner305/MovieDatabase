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
    @IBOutlet weak var reviewCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var overviewDetailLabel: UILabel!
    @IBOutlet weak var videoPlayer: YouTubePlayerView!
    @IBOutlet weak var trailerView: UIView!
    
    var viewModel = MovieDetailViewModel()
    var apiManager = ApiManager()
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
                    self.reviewCollectionView.reloadData()
                    self.setupView()
                    self.setupPageView()
                    self.setupVideoPlayer()
                }
            }).disposed(by: bag)
    }
    
    func setupCollectionView() {
        imageCollectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        reviewCollectionView.register(ReviewCell.nib, forCellWithReuseIdentifier: ReviewCell.identifier)
    }
    
    func setupView() {
        overviewDetailLabel.text = viewModel.movieDetail?.overview ?? "-"
    }
    func setupPageView() {
        self.pageView.currentPage = 0
        self.pageView.numberOfPages = viewModel.imageUrl.count
        self.timer()
    }
    
    func timer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard let currentIndexPath = self.imageCollectionView.indexPathsForVisibleItems.first else { return }
            let nextItemIndex = currentIndexPath.item + 1 < self.viewModel.imageUrl.count ? (currentIndexPath.item + 1) % (self.viewModel.movieDetail?.images?.backdrops?.count ?? 0) : 0
            let nextIndexPath = nextItemIndex <= self.viewModel.imageUrl.count ? IndexPath(item: nextItemIndex, section: 0) : IndexPath(item: 0, section: 0)
            self.imageCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            self.pageView.currentPage = nextItemIndex
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
        if collectionView == imageCollectionView {
            return viewModel.imageUrl.count
        } else if collectionView == reviewCollectionView {
            return viewModel.reviewData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imageCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
            cell.imageView.kf.setImage(with: viewModel.imageUrl[indexPath.row])
            return cell
        } else if collectionView == reviewCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.identifier, for: indexPath) as! ReviewCell
            
            guard let data = viewModel.movieDetail?.reviews?.results?[indexPath.row] else { return UICollectionViewCell() }
            cell.authorNameLabel.text = data.author ?? "-"
            cell.reviewLabel.text = data.content ?? "-"
            let url = apiManager.getAvatarUrl(viewModel.reviewData[indexPath.row]?.authorDetails?.avatarPath ?? "")
            cell.avatarImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.fill"))
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height / 2
            cell.avatarImageView.layer.borderWidth = 2.0
            cell.avatarImageView.layer.borderColor = UIColor.white.cgColor
            cell.clipsToBounds = true
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imageCollectionView {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        } else if collectionView == reviewCollectionView {
            return CGSize(width: collectionView.frame.size.width - 30, height: 300)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == imageCollectionView {
            return 0
        }
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

