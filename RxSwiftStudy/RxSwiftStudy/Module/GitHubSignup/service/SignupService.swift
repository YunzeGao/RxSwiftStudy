//
//  SignupService.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/5.
//

import RxSwift

protocol GitHubAPI {
    func usernameAvailable(_ username: String) -> Observable<Bool>
    func signup(_ username: String, password: String) -> Observable<Bool>
}

protocol GitHubValidationService {
    func validateUsername(_ username: String) -> Observable<SignupValidationResult>
    func validatePassword(_ password: String) -> SignupValidationResult
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> SignupValidationResult
}
