//
//  TodoCell.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/29.
//

import ReactorKit


final class TodoListCellReactor: Reactor {
    
    typealias Action = NoAction
    
    var initialState: TodoModel
    
    init(_ model: TodoModel) {
        initialState = model
    }
}
