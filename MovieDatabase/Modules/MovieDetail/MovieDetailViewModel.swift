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
    let onSuccessFetchData = PublishSubject<Bool>()
    
    var movieDetail: MovieDetailEntity?
    var imageUrl = [URL?]()
    var reviewData = [ReviewResultEntity?]()
    
    func fetchMovieDetail(id: Int) {
        return apiManager.fetchData(.movieDetail(id: id))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (data: MovieDetailEntity?) in
                guard let self = self,
                      let data = data
                else { return }
                self.movieDetail = data
                self.imageUrl = self.getImageUrl(self.movieDetail?.images?.backdrops)
                self.reviewData = self.getReviewData(data.reviews?.results) ?? []
                self.onSuccessFetchData.onNext(true)
            }, onError: { error in
                // error handling
                self.onSuccessFetchData.onNext(false)
            }).disposed(by: bag)
    }
    
    func getImageUrl(_ data: [ImageBackdropEntity]?) -> [URL?] {
        guard let data = data,
              data.count > 0
        else { return [] }
        var imageUrl = [URL?]()
        for i in 0...data.count - 1 {
            if i >= 10 { break }
            let url = apiManager.getImageUrl(data[i].filePath ?? "")
            imageUrl.append(url)
        }
        
        return imageUrl
    }
    
    func getReviewData(_ data: [ReviewResultEntity]?) -> [ReviewResultEntity]? {
        guard let data = data,
              data.count > 0
        else { return [] }
        var dataArray: [ReviewResultEntity]
        dataArray = data.count >= 5 ? Array(data.prefix(5)) : data
        
//        var imageUrl = [URL?]()
//        for i in 0...data.count - 1 {
//            if i >= 5 { break }
//            let url = apiManager.getAvatarUrl(dataArray[i].authorDetails?.avatarPath ?? "")
//            imageUrl.append(url)
//        }
//
        return dataArray
    }
}
