//
//  AlertService+Injection.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import Factory

extension Container {
    static var alertServices: Factory<AlertServiceType> = Factory {
        AlertService()
    }
}
