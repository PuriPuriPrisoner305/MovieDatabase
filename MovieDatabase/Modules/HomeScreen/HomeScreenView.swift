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

class HomeScreenView: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = HomeScreenViewModel()
    var apiManager = ApiManager()
    var model = HomeScreenModel()
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
                    cell.posterImage.kf.setImage(with: self?.model.getImageUrl(item.posterImage ?? "")) { _ in
                        cell.hideSkeleton()
                    }
                    cell.titleLabel.text = item.title ?? "-"
                    
            }
            .disposed(by: bag)
        
        collectionView.rx.setDelegate(self).disposed(by: bag)
    }
    
}

extension HomeScreenView: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(2 - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(2))
    
        return CGSize(width: size, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y, scrollView.contentSize.height - scrollView.frame.size.height)
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            viewModel.fetchData()
        }
    }
}


class HomeScreenViewModel {
    var apiManager = ApiManager()
    var movieList = PublishSubject<[Movie]>()
    var pageCounter = 1
    
    var bag = DisposeBag()
    
    func fetchData() {
        apiManager.fetchData(.movieDiscover(page: pageCounter))
            .subscribe(onNext: { [weak self] (data: MovieDiscover) in
                guard let self = self,
                      let data = data.results
                else { return }
                self.movieList.onNext(data)
                self.pageCounter += 1
            }, onError: { error in
                
            }).disposed(by: bag)
    }
}

class ApiManager {
    func fetchData<T: Codable>(_ apiEndpoint: APIEndpoint) -> Observable<T> {
        return Observable.create { observer in
            guard let url = URL(string: apiEndpoint.url()) else {
                observer.onError(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                return Disposables.create()
                
            }
            let session = URLSession.shared
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                guard let data = data else {
                    observer.onError(NSError(domain: "No data returned from API", code: 0, userInfo: nil))
                    return
                }
                do {
                    let objects = try JSONDecoder().decode(T.self, from: data)
                    observer.onNext(objects)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
            
        }
    }
    
    enum APIEndpoint {
        case movieDiscover(page: Int)
        
        func url() -> String {
            switch self {
            case .movieDiscover(let page):
                return "https://api.themoviedb.org/3/discover/movie?api_key=f911faef7aa9f46f51a69f1843e890ba&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)&with_watch_monetization_types=flatrate"
                
            }
        }
    }
}

struct MovieDiscover: Codable {
    let page, totalPages, totalResults: Int?
    let results: [Movie]?
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

class HomeScreenModel {
    func getImageUrl(_ url: String) -> URL? {
        let imageUrl = "https://image.tmdb.org/t/p/w500/" + url
        return URL(string: imageUrl)
    }
}
    
struct Movie: Codable {
    let id: Int?
    let title, posterImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterImage = "poster_path"
    }
}


