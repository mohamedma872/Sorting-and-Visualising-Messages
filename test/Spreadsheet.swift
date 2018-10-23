//
//  Spreadsheet.swift
//  test
//
//  Created by user147796 on 10/23/18.
//  Copyright © 2018 user147796. All rights reserved.
//

import Foundation
// To parse the JSON, add this file to your project and do:
//
//   let spreadsheet = try? newJSONDecoder().decode(Spreadsheet.self, from: jsonData)


struct Spreadsheet: Codable {
    let version, encoding: String
    let feed: Feed
}

struct Feed: Codable {
    let xmlns: String
    let xmlnsOpenSearch: String
    let xmlnsGsx: String
    let id, updated: ID
    let category: [Category]
    let title: Title
    let link: [Link]
    let author: [Author]
    let openSearchTotalResults, openSearchStartIndex: ID
    let entry: [Entry]
    
    enum CodingKeys: String, CodingKey {
        case xmlns
        case xmlnsOpenSearch = "xmlns$openSearch"
        case xmlnsGsx = "xmlns$gsx"
        case id, updated, category, title, link, author
        case openSearchTotalResults = "openSearch$totalResults"
        case openSearchStartIndex = "openSearch$startIndex"
        case entry
    }
}

struct Author: Codable {
    let name, email: ID
}

struct ID: Codable {
    let t: String
    
    enum CodingKeys: String, CodingKey {
        case t = "$t"
    }
}

struct Category: Codable {
    let scheme, term: String
}

struct Entry: Codable {
    let id, updated: ID
    let category: [Category]
    let title,
    content: Title
    let link: [Link]
   
}

struct Title: Codable {
    let type: TitleType
    let t: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case t = "$t"
    }
}

enum TitleType: String, Codable {
    case text = "text"
}

struct Link: Codable {
    let rel: String
    let type: LinkType
    let href: String
}

enum LinkType: String, Codable {
    case applicationAtomXML = "application/atom+xml"
}
