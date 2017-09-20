//
//  InstagramManager.swift
//  InstagramSDK
//
//  Created by Iurii Pleskach on 9/18/17.
//  Copyright © 2017 Iurii Pleskach. All rights reserved.
//

import UIKit

class InstagramManager {
    private static let instagramAPIBaseURL = URL(string: "https://api.instagram.com/v1/")
    private static let clientId = "bbc67133ac414d19b8cde93752124551"
    private static let redirectURI = "http://testsite.ua"
    private static let accessTokenKey = "access_token"

    // MARK: -
    // TODO: implement dependency injection to use shared session instead
    private lazy var session = URLSession(configuration: URLSessionConfiguration.default)
    private var userDataTask: URLSessionDataTask?
    private var mediaDataTask: URLSessionDataTask?
    // MARK: - Public interface
    public static let shared = InstagramManager()
    public let autorizationURL = URL(string: "https://www.instagram.com/oauth/authorize/?client_id=\(InstagramManager.clientId)&redirect_uri=\(InstagramManager.redirectURI)&response_type=token&scope=public_content")
    public var accessToken: String!

    public func requestUser(with userName: String, completion: @escaping ([InstagramUserResponse.InstagramUser]?, Error?) -> Void) -> Void {
        let parameters = ["q" : userName, "access_token" : self.accessToken]
        let endpoint = "users/search"
        self.userDataTask = self.call(endpoint: endpoint, parameters: parameters) { (data, response, error) in
            // TODO: handle possible errors
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(InstagramUserResponse.self, from: data!) {
                completion(user.instagramUsers, nil)
            } else {
                // TODO: return error
                completion(nil, nil)
            }
        }
    }

    public func requestMediafiles(userId: String, completion: @escaping ([PagedInstagramMedia.InstagramMedia]?, Error?) -> Void) -> Void {
        let parameters = ["access_token" : self.accessToken]
        let endpoint = "users/\(userId)/media/recent/"
        self.mediaDataTask = self.call(endpoint: endpoint, parameters: parameters) { (data, response, error) in
            // TODO: handle possible errors
            let decoder = JSONDecoder()
            if let media = try? decoder.decode(PagedInstagramMedia.self, from: data!) {
                completion(media.data, nil)
            } else {
                // TODO: return error
                completion(nil, nil)
            }
        }
    }
    
    // MARK: - Helper methods
    // TODO: implement error parsing from the specified URL
    public func token(from url: URL) -> String? {
        guard let urlFragment = url.fragment else {
            return nil
        }

        let fragmentPair = urlFragment.components(separatedBy: "=")
        guard fragmentPair.count == 2 && fragmentPair[0] == InstagramManager.accessTokenKey else {
            return nil
        }

        return fragmentPair[1]
    }
    
    // MARK: - Private interface

    private func call(endpoint: String, parameters: [String : String?]? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        guard let apiURL = URL(string: endpoint, relativeTo: type(of: self).instagramAPIBaseURL), var components = URLComponents(url: apiURL, resolvingAgainstBaseURL: true) else {
            completion(nil, nil, nil)
            return nil
        }
        if let parameters = parameters {
            components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        }
        guard let endpointURL = components.url else {
            completion(nil, nil, nil)
            return nil
        }

        let dataTask = self.session.dataTask(with: endpointURL, completionHandler: completion)
        dataTask.resume()
        return dataTask
    }
}
