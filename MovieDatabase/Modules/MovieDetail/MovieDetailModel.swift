//
//  MovieDetailModel.swift
//  MovieDatabase
//
//  Created by ardy on 10/03/23.
//

import Foundation

struct MovieDetailEntity: Codable {
    let title, releaseDate, overview: String?
    let runtime, voteCount: Int?
    let vote: Double?
    let images: ImageEntity?
    let reviews: ReviewEntity?
    let videos: VideoEntity?
    
    enum CodingKeys: String, CodingKey {
        case title, runtime, vote, images, videos, reviews, overview
        case releaseDate = "release_date"
        case voteCount = "vote_count"
    }
}

struct ImageEntity: Codable {
    let backdrops: [ImageBackdropEntity]?
}

struct ImageBackdropEntity: Codable {
    let filePath: String?
    
    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }
}

struct VideoEntity: Codable {
    let results: [VideoResultEntity]?
    
    enum CodingKeys: String, CodingKey {
        case results
    }
}

struct VideoResultEntity: Codable {
    let key, name, site, type: String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case site
        case type
    }
}

struct ReviewEntity: Codable {
    let page, totalPages, totalResults: Int?
    let results: [ReviewResultEntity]?
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct ReviewResultEntity: Codable {
    let author, content: String?
    let authorDetails: AuthorDetailEntity?
    
    enum CodingKeys: String, CodingKey {
        case author, content
        case authorDetails = "author_details"
    }
}

struct AuthorDetailEntity: Codable {
    let avatarPath: String?
    let rating: Double?
    
    enum CodingKeys: String, CodingKey {
        case rating
        case avatarPath = "avatar_path"
    }
}
