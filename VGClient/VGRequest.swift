//
//  VGRequest.swift
//  VGClient
//
//  Created by viwii on 2017/4/5.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation


enum VGRequestError: Error {
    case badURL
    case badParameters
}


enum VGRoute: String {
    
    case integrate = "/basic/integrated"
    
    case login = "/users/login"
    case register = "/users/register"
    case findPassword = "/users/findPassword"
    
    case airts = "/airts"
    case airtsrange = "/airts/range"
    
    case airhs = "/airhs"
    case airhsrange = "/airhs/range"
    
    case soilhs = "/soilhs"
    case soilhsrange = "/soilhs/range"
    
    case soilts = "/soilts"
    case soiltsrange = "/soilts/range"
    
    case lightis = "/lightis"
    case lightisrange = "/lightis/range"
    
    case coocs = "/coocs"
    case coocsrange = "/coocs/range"
}


enum VGMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    
    case patch = "PATCH"
    case trace = "TRACE"
    case head = "HEAD"
    case put = "PUT"
}

typealias VGRequestHandler = (Data?, URLResponse?, Error?) -> Void

struct VGRequest {
    
    let hostname: String
    
    init(hostname: String) {
        self.hostname = hostname
    }
    
    @discardableResult
    func make(
        method: VGMethod,
        route: String,
        query: String?,
        httpBody: Data?,
        completionHandler: @escaping VGRequestHandler) -> URLSessionDataTask? {
        
        let path = query == nil ? "\(hostname)\(route)" : "\(hostname)\(route)?\(query!)"
        
        guard let url = URL(string: path) else {
            completionHandler(nil, nil, VGRequestError.badURL)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = httpBody
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        return task
    }
    
    @discardableResult
    func get(route: VGRoute, query: String? = nil, handler: @escaping VGRequestHandler) -> URLSessionDataTask? {
        return make(method: .get,
                    route: route.rawValue,
                    query: query,
                    httpBody: nil,
                    completionHandler: handler)
    }
    
    @discardableResult
    func post( route: VGRoute, httpBody: Data? = nil, handler: @escaping VGRequestHandler) -> URLSessionDataTask? {
        return make(method: .post,
                    route: route.rawValue,
                    query: nil,
                    httpBody: httpBody,
                    completionHandler: handler)
        
    }
    
    @discardableResult
    func delete(
        route: VGRoute,
        query: String? = nil,
        httpBody: Data? = nil,
        handler: @escaping VGRequestHandler) -> URLSessionDataTask? {
        
        return make(method: .delete,
                    route: route.rawValue,
                    query: query,
                    httpBody: httpBody,
                    completionHandler: handler)
    }
}

