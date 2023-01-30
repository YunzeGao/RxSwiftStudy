//
//  Network.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/17.
//

import Foundation
import RxSwift
import HandyJSON

class Network {
    static func getObject<T: MetaModel>(_ method: RequestMethod, _ url: String, params: [String : Any]? = nil, type: T.Type = BaseModel.self) -> Observable<T> {
        return NetworkCore.request(type, method, url, params: params)
    }
    
    static func getObjects<T: MetaModel>(_ method: RequestMethod, _ url: String, params: [String : Any]? = nil, type: T.Type = BaseModel.self) -> Observable<[T]> {
        return NetworkCore.request(type, method, url, params: params)
    }
}
