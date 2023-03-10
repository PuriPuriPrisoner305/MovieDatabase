//
//  HomeScreenModel.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import Foundation
import RxDataSources

struct MovieDiscoverEntity: Codable {
    let page, totalPages, totalResults: Int?
    let results: [MovieEntity]?
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieEntity: Codable {
    let id: Int?
    let title, posterImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterImage = "poster_path"
    }
}

struct MovieSection {
    var items: [MovieEntity]
}

extension MovieSection: SectionModelType {
    typealias Item = MovieEntity
    
    init(original: MovieSection, items: [Item]) {
        self = original
        self.items = items
    }
}
