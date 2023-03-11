//
//  HomeScreenViewModel.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import UIKit
import RxSwift
import RxDataSources

class HomeScreenViewModel {
    var apiManager = ApiManager()
    var movieList = BehaviorSubject(value: [MovieEntity]())
    var pageCounter = 1
    
    var bag = DisposeBag()
    
    // MARK: API Call for movies discover
    func fetchData() {
        apiManager.fetchData(.movieDiscover(page: pageCounter))
            .subscribe(onNext: { [weak self] (data: MovieDiscoverEntity?) in
                guard let self = self,
                      let data = data?.results
                else { return }
                do {
                    try self.movieList.onNext(self.movieList.value() + data)
                } catch {
                    // error handling
                }
                self.pageCounter += 1
            }, onError: { error in
                // error handling
            }).disposed(by: bag)
    }
}

// MARK: Navigator
extension HomeScreenViewModel {
    func navigateToMovieDetailView(id: Int, title: String, from navigation: UINavigationController) {
        let storyboardId = String(describing: MovieDetailView.self)
        let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: storyboardId) as? MovieDetailView else {
            fatalError("Error laoding storyboard")
        }
        view.navigationItem.title = title
        view.movieID = id
        navigation.pushViewController(view, animated: true)
    }
}
