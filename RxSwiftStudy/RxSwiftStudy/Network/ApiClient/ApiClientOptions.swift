//
//  ApiClientOptions.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/30.
//

import Foundation

public class ApiClientOptions: ApiOptionsType {
    public var params: [String : Any]
    
    public var realUrl: String
    
    public var extraUrl: String?
    
    public var localPath: String?
    
    public var localData: Data?
    
    public var modelDescriptions: MetaModel = BaseModel()
    
    public var requestModel: MetaModel? {
        didSet {
            if let model = requestModel?.toJSON() {
                params = model
            }
        }
    }
    
    public var extraHTTPHeader: [String : String]?
    
    public var requestMethod: ApiRequestMethod = .GET
    
    public var timeoutInterval: Double = ApiClientConst.defaultTimeout {
        didSet {
            if (timeoutInterval < ApiClientConst.minTimeout) {
                timeoutInterval = ApiClientConst.minTimeout
            }
        }
    }
    
    public var signType: ApiSignType
    
    public var taskType: ApiTaskType = .data
    
    /// 用于访问第三方Api, 填写url全路径
    init(thirdUrl: String) {
        realUrl = thirdUrl
        signType = .thirdPart
    }
    
    /// 用于访问后端Api, 会自动补全domain, 并且补全相关签名信息
    init(url: String) {
        extraUrl = url
        realUrl = (ApiClientConst.baseDomain ?? "") + url
        signType = .staticParams
    }
}
