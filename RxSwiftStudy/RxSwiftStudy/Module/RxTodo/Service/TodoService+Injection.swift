//
//  TodoService+Injection.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import Factory

extension Container {
    static var todoServices: Factory<TodoServiceType> = Factory(scope: .shared) {
        return TodoService()
    }
}
