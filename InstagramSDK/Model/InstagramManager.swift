//
//  InstagramManager.swift
//  InstagramSDK
//
//  Created by Iurii Pleskach on 9/18/17.
//  Copyright © 2017 Iurii Pleskach. All rights reserved.
//

import UIKit

class InstagramManager {
    private static let accessTokenKey = "access_token"
    enum Scope : String {
        case basic
        case publicContent = "public_content"
        case followerList = "follower_list"
        case comments
        case relationships
        case likes
    }
    
    // MARK: -
    private var session: URLSession
    private var baseAutorizationURL: URL
    private var baseApiURL: URL
    private var redirectURI: String
    private var clientId: String
    
    // MARK: -
    private var userDataTask: URLSessionDataTask?
    private var mediaDataTask: URLSessionDataTask?
    
    // MARK: - Public interface
    public static let shared = InstagramManager(baseAutorizationURL: URL(string: "https://www.instagram.com/oauth/authorize/")!, baseApiURL: URL(string: "https://api.instagram.com/v1/")!, clientId: "bbc67133ac414d19b8cde93752124551", redirectURI: "http://testsite.ua")
    public var accessToken: String!

    init(baseAutorizationURL: URL, baseApiURL: URL, clientId: String, redirectURI: String, session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
        self.baseAutorizationURL = baseAutorizationURL
        self.baseApiURL = baseApiURL
        self.clientId = clientId
        self.redirectURI = redirectURI
    }

    public func autorizationURL(for scope: Scope) -> URL? {
        var autorizationURLComponents = URLComponents(url: self.baseAutorizationURL, resolvingAgainstBaseURL: true)
        let parameters = ["client_id" : self.clientId, "redirect_uri" : self.redirectURI, "response_type" : "token", "scope" : scope.rawValue]
        autorizationURLComponents?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }

        return autorizationURLComponents?.url
    }
    
    public func requestUser(with userName: String, completion: @escaping ([InstagramUserResponse.InstagramUser]?, Error?) -> Void) -> Void {
        let parameters = ["q" : userName, InstagramManager.accessTokenKey : self.accessToken]
        let path = "users/search"
        self.userDataTask = self.call(path: path, parameters: parameters) { (data, response, error) in
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
        let parameters = [InstagramManager.accessTokenKey : self.accessToken]
        let path = "users/\(userId)/media/recent/"
        self.mediaDataTask = self.call(path: path, parameters: parameters) { (data, response, error) in
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

    private func call(baseURL: URL? = nil, path: String, parameters: [String : String?]? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        let theBaseURL = baseURL ?? self.baseApiURL
        guard let endpointURL = URL(string: path, relativeTo: theBaseURL), var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: true) else {
            completion(nil, nil, nil)
            return nil
        }
        if let parameters = parameters {
            components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        }
        guard let endpointURLWithParameters = components.url else {
            completion(nil, nil, nil)
            return nil
        }

        let dataTask = self.session.dataTask(with: endpointURLWithParameters, completionHandler: completion)
        dataTask.resume()
        return dataTask
    }
}
