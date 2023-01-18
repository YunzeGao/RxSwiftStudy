//
//  TodoModel.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/19.
//

import Foundation

class TodoModel: MetaModel {
    var order: String?
    var text: String?
    var done: Bool = false
}

extension TodoModel {
    var isEmpty: Bool {
        return order == nil || order!.isEmpty
    }
    
    var success: Bool {
        return !isEmpty
    }
}

class TodoListModel: BaseModel {
    var tasks: [TodoModel]?
}
