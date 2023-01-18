//
//  SignupService+Injection.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/9.
//

import Foundation
import Factory

extension Container {
    static let gitHubAPI = Factory<GitHubAPI> { GitHubDefaultAPI.sharedAPI }
    static let gitHubValid = Factory<GitHubValidationService> {
        GitHubDefaultValidationService.sharedValidationService
    }
}
