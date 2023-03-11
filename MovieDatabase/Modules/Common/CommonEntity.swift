//
//  CommonEntity.swift
//  MovieDatabase
//
//  Created by ardy on 11/03/23.
//

import Foundation

enum GeneralType {
    case networkConnected
    case networkDisconnected
    
    var description: String {
        switch self {
        case .networkConnected:
            return "Network connected"
        case .networkDisconnected:
            return "Network disconnected"
        }
    }
}

enum ErrorType {
    case fetchFailed
    case noInternet
    case decodingFailed
    case storyboardLoadFailed
    case invalidURL
    case emptyFetchedData
    
    var description: String {
        switch self {
        case .fetchFailed:
            return "We have problem loading movie data. Please try again"
        case .noInternet:
            return "Please check for internet connection"
        case .decodingFailed:
            return "Error decoding fetched data"
        case .storyboardLoadFailed:
            return "Error loading storyboard"
        case .invalidURL:
            return "Invalid URL"
        case .emptyFetchedData:
            return "No data returned from API"
        }
    }
}

enum URLPath {
    case APIKey
    case posterImage
    case avatarImage
    case discoverMovie(page: Int)
    case movieDetail(id: Int)
    
    var link: String {
        switch self {
        case .APIKey:
            return "f911faef7aa9f46f51a69f1843e890ba"
        case .posterImage:
            return "https://image.tmdb.org/t/p/w500/"
        case .avatarImage:
            return "https://image.tmdb.org/t/p/w200/"
        case .discoverMovie(let page):
            let url =
            "https://api.themoviedb.org/3/discover/movie?api_key=\(URLPath.APIKey.link)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)&with_watch_monetization_types=flatrate"
            return url
        case .movieDetail(let id):
            let url = "https://api.themoviedb.org/3/movie/\(id)?api_key=\(URLPath.APIKey.link)&append_to_response=videos,images,reviews"
            return url
        }
    }
}
