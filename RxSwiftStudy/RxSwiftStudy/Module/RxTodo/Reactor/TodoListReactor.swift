//
//  TodoListReactor.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import RxSwift
import ReactorKit
import RxDataSources
import Factory

typealias TaskListSection = SectionModel<Void, TodoListCellReactor>

class TodoListReactor: Reactor {
    enum Action {
        // 展示列表
        case fetchData
        // 点击edit
        case editClick
        // 点击item-done
        case cellDoneClick(IndexPath)
        // 删除item
        case remove(IndexPath)
        // 移动item
        case move(_ src: IndexPath, _ dest: IndexPath)
    }
    
    enum Mutation {
        case setDataSource(_ tasks: [TodoModel])
        case updateEdit
        case addModel(_ model: TodoModel)
        case updateModel(_ model: TodoModel)
        case changeDoneStatus(IndexPath, TodoModel)
        case removeModel(IndexPath, Bool)
        case moveItem(IndexPath, IndexPath, TodoModel)
        case loading
    }
    
    struct State {
        @Pulse var dataSource: [TaskListSection] = [TaskListSection(model: Void(), items: [])]
        @Pulse var fetchLoading: Bool?
        @Pulse var isEditing: Bool = false
    }
    
    let initialState = State()
    @Injected(Container.todoServices) private var api
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let apiEventMutation: Observable<Mutation> = api.event.flatMap { [weak self] taskEvent -> Observable<Mutation> in
            self?.mutate(taskEvent: taskEvent) ?? .empty()
        }
        return Observable.of(mutation, apiEventMutation).merge()
    }
    
    private func mutate(taskEvent: TodoEvent) -> Observable<Mutation> {
        switch taskEvent {
            case let .create(model):
                return .just(.addModel(model))
            case let .update(model):
                return .just(.updateModel(model))
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case .fetchData:
                return Observable<Mutation>.concat([
                    Observable.just(.loading),
                    api.fetchAll().map { .setDataSource($0) }
                ])
            case .editClick:
                return .just(.updateEdit)
            case let .cellDoneClick(path):
                let model = currentState.dataSource[path].currentState
                return api.changeDoneStatus(model).map { .changeDoneStatus(path, $0) }
            case let .move(src, dest):
                let srcModel = currentState.dataSource[src].currentState
                let destModel = currentState.dataSource[dest].currentState
                return api.move(srcModel, destModel).map { .moveItem(src, dest, $0) }
            case let .remove(path):
                let model = currentState.dataSource[path].currentState
                return api.delete(model).map { .removeModel(path, $0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            case let .setDataSource(tasks):
                newState.dataSource = [SectionModel(model: Void(), items: tasks.map(TodoListCellReactor.init))]
                newState.fetchLoading = false
            case .updateEdit:
                newState.isEditing = !newState.isEditing
            case let .addModel(task):
                newState.dataSource.append(TodoListCellReactor(task), at: 0)
            case let .updateModel(model):
                if let path = indexPath(forModel: model) {
                    newState.dataSource[path] = TodoListCellReactor(model)
                }
            case let .changeDoneStatus(path, task):
                let currentTask = newState.dataSource[path].currentState
                if (currentTask.order == task.order) {
                    newState.dataSource[path] = TodoListCellReactor(task)
                }
            case let .removeModel(path, success):
                if (success) {
                    newState.dataSource.remove(at: path)
                }
            case let .moveItem(src, target, newModel):
                let oldModel = newState.dataSource[src].currentState
                if (newModel.success && newModel.order != oldModel.order) {
                    newState.dataSource.remove(at: src)
                    newState.dataSource.insert(TodoListCellReactor(newModel), at: target)
                }
            case .loading:
                newState.fetchLoading = true
        }
        return newState
    }
    
    private func indexPath(forModel model: TodoModel) -> IndexPath? {
      let section = 0
        let item = currentState.dataSource[section].items.firstIndex { reactor in reactor.currentState.order == model.order }
      if let item = item {
        return IndexPath(item: item, section: section)
      } else {
        return nil
      }
    }
    
    func reactorForCreatingTask() -> TodoEditReactor {
      return TodoEditReactor(TodoModel())
    }
    
    func reactorForEditingTask(_ cell: TodoListCellReactor) -> TodoEditReactor {
      return TodoEditReactor(cell.currentState)
    }
}


extension Array where Element: SectionModelType {
    public subscript(indexPath: IndexPath) -> Element.Item {
      get {
        return self[indexPath.section].items[indexPath.item]
      }
      mutating set {
        self.update(section: indexPath.section) { items in
          items[indexPath.item] = newValue
        }
      }
    }
    
    public mutating func append(_ newElement: Element.Item, at section: Int) {
      self.update(section: section) { items in
          items.append(newElement)
      }
    }
    
    @discardableResult
    public mutating func remove(at indexPath: IndexPath) -> Element.Item {
      return self.update(section: indexPath.section) { items in
        return items.remove(at: indexPath.item)
      }
    }
    
    private mutating func update<T>(section: Int, mutate: (inout [Element.Item]) -> T) -> T {
      var items = self[section].items
      let value = mutate(&items)
      self[section] = Element.init(original: self[section], items: items)
      return value
    }
    
    public mutating func insert(_ newElement: Element.Item, at indexPath: IndexPath) {
      self.update(section: indexPath.section) { items in
        items.insert(newElement, at: indexPath.item)
      }
    }
}
