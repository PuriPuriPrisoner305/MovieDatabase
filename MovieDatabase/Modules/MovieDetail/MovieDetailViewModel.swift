//
//  MovieDetailViewModel.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import UIKit
import RxSwift

class MovieDetailViewModel {
    let apiManager = ApiManager()
    let bag = DisposeBag()
    var movieDetail = PublishSubject<MovieDetailEntity>()
    let onSuccessFetchData = PublishSubject<Bool>()
    
    var imageUrl = [URL?]()
    
    func fetchMovieDetail(id: Int) {
        return apiManager.fetchData(.movieDetail(id: id))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (data: MovieDetailEntity?) in
                guard let self = self,
                      let data = data
                else { return }
                self.movieDetail.onNext(data)
                self.imageUrl = self.getImageUrl(data.images?.backdrops)
                self.onSuccessFetchData.onNext(true)
            }, onError: { error in
                // error handling
                self.onSuccessFetchData.onNext(false)
            }).disposed(by: bag)
    }
    
    func getImageUrl(_ data: [ImageBackdropEntity]?) -> [URL?] {
        guard let data = data else { return [] }
        var imageUrl = [URL?]()
        for i in 0...data.count - 1 {
            if i >= 5 { break }
            let url = apiManager.getImageUrl(data[i].filePath ?? "")
            imageUrl.append(url)
        }
        
        return imageUrl
    }
}
