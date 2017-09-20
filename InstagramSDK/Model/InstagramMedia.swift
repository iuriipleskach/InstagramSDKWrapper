//
//  InstagramMedia.swift
//  InstagramSDK
//
//  Created by Iurii Pleskach on 9/15/17.
//  Copyright © 2017 Iurii Pleskach. All rights reserved.
//

import Foundation

struct PagedInstagramMedia: Codable {
    struct Pagination: Codable {
    }
    struct InstagramMedia: Codable {
        struct InstagramMediaMetadata: Codable {
            let width: Int
            let height: Int
            let url: URL
        }
        let id: String
        let user: InstagramUserResponse.InstagramUser
        let images: [String: InstagramMediaMetadata]?
        let videos: [String: InstagramMediaMetadata]?
    }
    struct Meta: Codable {
        let code: Int
    }

    let pagination: Pagination
    let data: [InstagramMedia]
    let meta: Meta
}
