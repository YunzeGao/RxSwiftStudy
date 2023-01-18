//
//  TodoEditReactor.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import RxSwift
import RxCocoa
import ReactorKit
import Factory
import Toast_Swift

enum TodoEditCancelAlertAction: AlertActionType {
    case leave
    case stay
    var title: String? {
        switch self {
            case .leave: return "残忍离开"
            case .stay: return "继续编辑"
        }
    }

    var style: UIAlertAction.Style {
        switch self {
            case .leave: return .destructive
            case .stay: return .default
        }
    }
}

class TodoEditReactor: Reactor {
    enum Action {
        case update(text: String)
        case cancel
        case submit
    }
    
    enum Mutation {
        case update(text: String)
        case dismiss
        case request
        case requestCompletion(_ success: Bool)
    }
    
    struct State {
        var originText: String?
        var task: TodoModel
        var shouldConfirmCancel: Bool = false
        @Pulse var isDismissed: Bool = false
        @Pulse var isSuccess: Bool = false
        @Pulse var requesting: Bool = false
        
        init(_ task: TodoModel) {
            self.task = task
            originText = task.text
        }
    }
    
    let initialState: State
    @Injected(Container.alertServices) private var alert
    @Injected(Container.todoServices) private var api
    
    init(_ task: TodoModel) {
        initialState = State(task)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .update(text):
                return .just(.update(text: text))
            case .submit:
                return Observable.concat([
                    Observable.just(.request),
                    api.saveOrUpdate(currentState.task)
                        .map { .requestCompletion(!$0.isEmpty) }
                ])
            case .cancel:
                if !currentState.shouldConfirmCancel {
                    return .just(.dismiss)
                }
                let actions: [TodoEditCancelAlertAction] = [.leave, .stay]
                return alert.show("确认离开？", "离开后所有改变将会被移除", preferredStyle: .alert, actions: actions)
                    .flatMap { selectedAction -> Observable<Mutation> in
                        switch selectedAction {
                            case .stay:
                                return .empty()
                            case .leave:
                                return .just(.dismiss)
                        }
                    }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            case let .update(text):
                newState.task.text = text
                newState.shouldConfirmCancel = text != state.originText
            case .dismiss:
                newState.isDismissed = true
            case .request:
                newState.requesting = true
            case let .requestCompletion(success):
                newState.requesting = false
                newState.isSuccess = success
        }
        return newState
    }
}
