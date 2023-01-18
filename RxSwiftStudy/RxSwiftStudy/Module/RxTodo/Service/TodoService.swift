//
//  TodoService.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import RxSwift
import RxCocoa

enum TodoEvent {
    case create(TodoModel)
    case update(TodoModel)
}

protocol TodoServiceType {
    var event: PublishSubject<TodoEvent> { get }
    
    func fetchAll() -> Observable<[TodoModel]>
    func saveOrUpdate(_ model: TodoModel) -> Observable<TodoModel>
    func changeDoneStatus(_ model: TodoModel) -> Observable<TodoModel>
    func move(_ src: TodoModel, _ target: TodoModel) -> Observable<TodoModel>
    func delete(_ model: TodoModel) -> Observable<Bool>
}

fileprivate let url = "todo/"
class TodoService: TodoServiceType {
    let event = PublishSubject<TodoEvent>()
    private var tasks: [TodoModel] = []
    private var cached: Bool = false
    
    func fetchAll() -> Observable<[TodoModel]> {
        if !cached {
            return Network.getObject(.GET, url, type: TodoListModel.self)
                .map { [weak self] list in
                    guard let `self` = self, let tasks = list.tasks, list.success
                    else { return [] }
                    self.tasks = tasks
                    self.cached = true
                    return tasks
                }
        }
        return .just(tasks)
    }
    
    private func findTask(_ task: TodoModel) -> Int {
        for (index, model) in tasks.enumerated() {
            if (task.order == model.order) {
                return index
            }
        }
        return -1
    }
    
    func saveOrUpdate(_ model: TodoModel) -> Observable<TodoModel> {
        return Network.getObject(.POST, url, params: model.toJSON(), type: TodoModel.self)
            .flatMap {[weak self] task -> Observable<TodoModel> in
                guard let `self` = self, !task.isEmpty else {
                    return .just(TodoModel())
                }
                if (model.isEmpty) {
                    self.tasks.append(task)
                } else {
                    for (index, oldModel) in self.tasks.enumerated() {
                        if (oldModel.order == task.order) {
                            self.tasks[index] = task
                            break
                        }
                    }
                }
                return .just(task)
            }
            .do {
                self.event.onNext(model.isEmpty ? .create($0) : .update($0))
            }
    }
    
    func changeDoneStatus(_ model: TodoModel) -> Observable<TodoModel> {
        model.done = !model.done
        return Network.getObject(.POST, url, params: model.toJSON(), type: TodoModel.self)
            .map { [weak self] task in
                let pos = self?.findTask(task) ?? -1
                if let `self` = self, !task.isEmpty, pos != -1 {
                    self.tasks[pos].done = task.done
                    return task
                }
                model.done = !model.done
                return model
            }
    }
    
    func move(_ src: TodoModel, _ target: TodoModel) -> Observable<TodoModel> {
        guard let srcOrder = src.order, let targetOrder = target.order else {
            return .just(TodoModel())
        }
        let srcIndex = findTask(src)
        let targetIndex = findTask(target)
        if srcIndex == -1 || targetIndex == -1 {
            return .just(TodoModel())
        }
        let params = ["src": srcOrder, "target": targetOrder]
        return Network.getObject(.PUT, url, params: params, type: TodoModel.self)
            .map { [weak self] newModel in
                if (!newModel.isEmpty) {
                    self?.tasks.remove(at: srcIndex)
                    self?.tasks.insert(newModel, at: targetIndex)
                }
                return newModel
            }
    }
    
    func delete(_ model: TodoModel) -> RxSwift.Observable<Bool> {
        let order = model.order ?? ""
        let params = ["id": order]
        return Network.getObject(.DELETE, url, params: params)
            .map {[weak self] model in
                if (model.success) {
                    self?.tasks.removeAll(where: { $0.order == order })
                }
                return model.success
            }
    }
}

