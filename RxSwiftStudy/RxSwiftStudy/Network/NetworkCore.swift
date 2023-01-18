//
//  NetworkCore.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/17.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import HandyJSON

enum RequestMethod {
    case GET
    case POST
    case PUT
    case DELETE
}

enum NetworkError : Error {
    // 请求参数错误
    case ParamsInvalid
    // 解析失败
    case ParseJSONError
    // 网络请求发生错误
    case RequestFailed
    // 接收到的返回没有data
    case NoResponse
    // 服务器返回了一个错误代码
    case UnexpectedResult(code: Int?)
}

extension RequestMethod {
    var m: HTTPMethod {
        switch self {
            case .GET:
                return .get
            case .POST:
                return .post
            case .PUT:
                return .put
            case .DELETE:
                return .delete
        }
    }
}

fileprivate class OriginModel{
    var code: Int
    var msg: String
    var data: [String: Any]?
    var dataList: [Any]?
    
    init(_ code: Int, _ msg: String) {
        self.code = code
        self.msg = msg
    }
    
    var isEmpty: Bool {
        if data == nil && dataList == nil {
            return true
        }
        return false
    };
}

// 校验
fileprivate func checkStatusCode(_ code: Int) -> Bool {
    if (code >= 400) {
        return false
    }
    return true
}

fileprivate let baseUrl = "http://127.0.0.1:8000/api/"
class NetworkCore {
    static func request<T: MetaModel>(_ type: T.Type, _ method: RequestMethod, _ url: String, params: [String : Any]? = nil) -> Observable<T> {
        do {
            return try _request(method, url, params: params).map { rawData in
                guard let data = rawData.data else {
                    return BaseModel() as! T
                }
                return type.deserialize(from: data)!
            }
        } catch {
            return Observable.just(BaseModel(errMsg: "请求异常!") as! T)
        }
    }
    
    static func request<T: MetaModel>(_ type: T.Type, _ method: RequestMethod, _ url: String, params: [String : Any]? = nil) -> Observable<[T]> {
        do {
            return try _request(method, url, params: params).map { rawData in
                if let dataList = [T].deserialize(from: rawData.dataList) as? [T] {
                    return dataList
                }
                return []
            }
        } catch {
            return Observable.just([])
        }
    }
    
    fileprivate static func _request(_ method: RequestMethod, _ url: String, params: [String : Any]? = nil) throws -> Observable<OriginModel> {
        guard let url = URL(string: baseUrl + url) else {
            throw NetworkError.ParamsInvalid
        }
        return RxAlamofire.request(method.m, url, parameters: params).responseData().map { resp, data in
            if (!checkStatusCode(resp.statusCode)) {
                throw NetworkError.UnexpectedResult(code: resp.statusCode)
            }
            guard let rawData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                throw NetworkError.ParseJSONError
            }
            guard let code = rawData["code"] as? Int,
                  let msg = rawData["msg"] as? String else {
                throw NetworkError.NoResponse
            }
            let model = OriginModel(code, msg)
            if let data = rawData["data"] as? [String: Any] {
                model.data = data
            } else if let dataList = rawData["data"] as? [Any] {
                model.dataList = dataList
            }
            return model
        }
    }
}
