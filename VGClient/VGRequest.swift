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

enum VGRoute {
    
    case integrate
    
    case login
    case register
    case findPassword
    
    case airts
    case airtsrange
    
    case airhs
    case airhsrange
    
    case soilhs
    case soilhsrange
    
    case soilts
    case soiltsrange
    
    case lightis
    case lightisrange
    
    case coocs
    case coocsrange
    
    case recent(Int)
    
    case sample(MeasurementType)
    
    var rawValue: String {
        switch self {
        case .integrate: return "/basic/integrated"
        case .login: return "/users/login"
        case .register: return "/users/register"
        case .findPassword: return "/users/findPassword"
        
        case .airts: return "/airts"
        case .airtsrange: return "/airts/range"
        
        case .airhs: return "/airhs"
        case .airhsrange: return "/airhs/range"
        
        case .soilhs: return "/soilhs"
        case .soilhsrange: return "/soilhs/range"
        
        case .soilts: return "/soilts"
        case .soiltsrange: return "/soilts/range"
            
        case .lightis: return "/lightis"
        case .lightisrange: return "/lightis/range"
            
        case .coocs: return "/coocs"
        case .coocsrange: return "/coocs/range"
            
        case .recent(let count): return "/basic/recent/\(count)"
            
        case .sample(let t):
            if t == .integrated {
                return "/basic/sample"
            } else {
                return "/\(t.textDescription)/sample"
            }
        }
    }
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

