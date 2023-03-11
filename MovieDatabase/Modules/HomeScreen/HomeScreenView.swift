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
import RxGesture
import Network

class HomeScreenView: UIViewController {
    @IBOutlet weak var movieListView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorTitle: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    var viewModel = HomeScreenViewModel()
    var apiManager = ApiManager()
    var bag = DisposeBag()
    var monitor = NWPathMonitor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAction()
        setupView()
        registerDataBinding()
        setupNetworkMonitor()
    }
    
    //MARK: listening to movielist observable object and populate the collectionview
    func registerDataBinding() {
        collectionView.register(MovieCell.nib, forCellWithReuseIdentifier: MovieCell.identifier)
        viewModel.movieList.bind(
            to: collectionView.rx.items(
                cellIdentifier: MovieCell.identifier,
                cellType: MovieCell.self)) { [weak self] (_, item, cell) in
                    guard let self = self else { return }
                    cell.backgroundColor = UIColor.clear
                    cell.posterImage.kf.indicatorType = .activity
                    cell.posterImage.kf.setImage(with: self.apiManager.getImageUrl(item.posterImage ?? ""))
                    cell.titleLabel.text = item.title ?? "-"
                    cell.movieId = item.id ?? 0
                    cell.delegate = self
            }
            .disposed(by: bag)
        
        // fetch next page's data when user scrolled to bottom
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
    
    func setupView() {
        // setup background
        collectionView.backgroundColor = UIColor.clear
        
        // setup navigation
        navigationItem.title = "Discover"
    }
    
    // listen to observables
    func setupAction() {
        retryButton.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.fetchData()
            }).disposed(by: bag)
        
        viewModel.onSuccessFetchData
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.movieListView.isHidden = !value
                self.errorView.isHidden = value
                self.retryButton.isHidden = value
                self.errorTitle.text = ErrorType.fetchFailed.description
            }).disposed(by: bag)
    }
    // MARK: Network status monitoring
    // When compile it on simulator may behave oddly. Works well with real devices
    func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print(GeneralType.networkConnected.description)
                    self.movieListView.isHidden = false
                    self.errorView.isHidden = true
                    self.viewModel.fetchData()
                } else {
                    print(GeneralType.networkDisconnected.description)
                    self.movieListView.isHidden = true
                    self.errorView.isHidden = false
                    self.errorTitle.text = ErrorType.noInternet.description
                    self.retryButton.isHidden = true
                }
            }
            print(path.isExpensive)
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
}

//MARK: CollectionView delegation
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

//MARK: MovieCell method delegation
extension HomeScreenView: MovieCellDelegate {
    func didTap(id: Int, title: String) {
        guard let navigation = self.navigationController else { return }
        viewModel.navigateToMovieDetailView(id: id, title: title, from: navigation)
    }
}
