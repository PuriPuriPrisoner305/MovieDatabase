//
//  ApiManager.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import UIKit
import RxSwift

class ApiManager {
    // MARK: fetch api data function
    func fetchData<T: Codable>(_ apiEndpoint: APIEndpoint) -> Observable<T> {
        return Observable.create { observer in
            guard let url = URL(string: apiEndpoint.url()) else {
                observer.onError(NSError(domain: ErrorType.invalidURL.description, code: 0, userInfo: nil))
                return Disposables.create()
                
            }
            let session = URLSession.shared
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                guard let data = data else {
                    observer.onError(NSError(domain: ErrorType.emptyFetchedData.description, code: 0, userInfo: nil))
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
    
    // MARK: convert string to image url with size of 500
    func getImageUrl(_ url: String) -> URL? {
        let imageUrl = URLPath.posterImage.link + url
        return URL(string: imageUrl)
    }
    
    func getAvatarUrl(_ url: String) -> URL? {
        let imageUrl = URLPath.avatarImage.link + url
        return URL(string: imageUrl)
    }
    
}

extension ApiManager {
    enum APIEndpoint {
        case movieDiscover(page: Int)
        case movieDetail(id: Int)
        
        func url() -> String {
            switch self {
            case .movieDiscover(let page):
                return URLPath.discoverMovie(page: page).link
            case .movieDetail(let id):
                return URLPath.movieDetail(id: id).link
            }
        }
    }

}
