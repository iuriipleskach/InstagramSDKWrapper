//
//  InstagramUser.swift
//  InstagramSDK
//
//  Created by Iurii Pleskach on 9/15/17.
//  Copyright © 2017 Iurii Pleskach. All rights reserved.
//

import Foundation

struct InstagramUserResponse: Codable {
    struct InstagramUser: Codable {
        let id: String
        let userName: String
        let profilePictureURL: URL
        let fullName: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case userName = "username"
            case profilePictureURL = "profile_picture"
            case fullName = "full_name"
        }
    }
    struct Meta: Codable {
        let code: Int
    }

    let meta: Meta
    let instagramUsers: [InstagramUser]
    enum CodingKeys: String, CodingKey {
        case meta
        case instagramUsers = "data"
    }
}
