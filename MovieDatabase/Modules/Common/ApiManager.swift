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
    
    // MARK: convert string to image url with size of 500
    func getImageUrl(_ url: String) -> URL? {
        let imageUrl = "https://image.tmdb.org/t/p/w500/" + url
        return URL(string: imageUrl)
    }
    
}

extension ApiManager {
    enum APIEndpoint {
        case movieDiscover(page: Int)
        case movieDetail(id: Int)
        
        func url() -> String {
            var apiKey = "f911faef7aa9f46f51a69f1843e890ba"
            switch self {
            case .movieDiscover(let page):
                return "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)&with_watch_monetization_types=flatrate"
            case .movieDetail(let id):
                return "https://api.themoviedb.org/3/movie/\(id)?api_key=\(apiKey)&append_to_response=videos,images,reviews"
            }
        }
    }

}
