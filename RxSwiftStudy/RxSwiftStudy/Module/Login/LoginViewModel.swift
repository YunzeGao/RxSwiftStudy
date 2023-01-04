//
//  LoginViewModel.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/4.
//

import Foundation
import RxSwift


let minimalUsernameLength = 5

class LoginViewModel {
    // 输出
    let usernameValid : Observable<Bool>
    let passwordValid : Observable<Bool>
    let allValid : Observable<Bool>
    
    // 输入
    init(username : Observable<String>, password : Observable<String>) {
        usernameValid = username
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)
        
        passwordValid = password
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)
        
        allValid = Observable
            .combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .share(replay: 1)
    }
}
