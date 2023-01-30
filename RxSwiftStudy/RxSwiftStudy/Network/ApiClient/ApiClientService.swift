//
//  ApiClientService.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/30.
//

import Foundation
import HandyJSON

public class MetaModel: HandyJSON {
    required public init() {}
}

public class BaseModel: MetaModel {
    var success: Bool = true
    var errorMsg: String?
    
    init(errMsg: String) {
        success = false
        errorMsg = errMsg
    }
    
    required init() {}
}

// MARK: - API Request
public enum ApiRequestMethod: UInt {
    case GET = 0
    /// 参数只会放在body里
    case POST
    case PUT
    case DELETE
}

/// 基础参数 参考：https://info.bilibili.co/pages/viewpage.action?pageId=80639558
public enum ApiSignType: UInt {
    /// 仅带基础参数，不会签名
    case noSign
    /// 带基础参数+access_key，会签名（sign）
    case staticParams
    /// 什么额外参数都不带，也不签名，适合用于调用第三方接口
    case thirdPart
}

public enum ApiTaskType: UInt {
    /// default value -> NSURLSessionDataTask
    case data = 0
    /// upload file task -> NSURLSessionUploadTask
    /// Use uploadTaskWithRequest:fromFile: method , The body stream and body data in this type of request are ignored , You need to
    /// set localPath of the file or localData to upload, and set ignoreCache property to YES.
    case upload
}

public protocol ApiOptionsType {
    /// 完整的请求URL
    var realUrl: String { get set }
    
    /// 扩展的url,realUrl = domain + extraUrl
    var extraUrl: String? { get set }

    /// local file path for upload or download tasks
    var localPath: String? { get set }

    /// local data for upload tasks
    var localData: Data? { get set }

    /// response data model for mapping
    var modelDescriptions: MetaModel { get set }

    /// 以数据模型进行请求
    var requestModel: MetaModel?
    
    /// request params( in request url or body @see requestMethod)
    var params: [String: Any]? { get set }

    /// extra HTTP header in request
    var extraHTTPHeader: [String: String]? { get set }

    // optional
    /**
    Default: BFCApiRequestMethodGET
    */
    var requestMethod: ApiRequestMethod { get set }
    
    /**
    The request’s timeout interval, in seconds. （可设置的最小值:5.f）
    Default: 20.f
    */
    var timeoutInterval: Double { get set }

    /**
    Default: BFCApiSignTypeDefault
    */
    var signType: ApiSignType { get set }

    /**
    Default: BFCApiTaskTypeData
    */
    var taskType: ApiTaskType { get set }
}

public protocol ApiRequestType {
    init(_ options: ApiOptionsType)
    func requestAsync()
    func requestSync()
    func cancel()

    var completionHandler: (([String: Any]) -> ())? { get set }
    var httpHeaderHandler: (([String: Any]) -> ())? { get set }
    var cachedHandler: (([String: Any]) -> ())? { get set }
    var errorHandler: ((Error, [String: Any]) -> ())? { get set }
    var progressHandler: ((Int64, Int64, Int64, Float) -> ())? { get set }
    var rawDataHandler: ((Data) -> ())? { get set }

    var customRequest: (() -> URLRequest)? { get set }
    var requestInjection: ((URLRequest) -> URLRequest)? { get set }
}
