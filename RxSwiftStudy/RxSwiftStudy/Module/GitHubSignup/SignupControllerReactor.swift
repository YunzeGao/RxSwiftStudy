//
//  SignupControllerRefactor.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/6.
//

import RxSwift
import RxCocoa
import ReactorKit

final class SignupControllerReactor : Reactor {
    enum Action {
        case inputUsername(name: String?)
        case inputPassword(password: String?)
        case inputRepeatPassword(password: String?)
        case signup(name: String?, password: String?)
    }
    
    enum Mutation {
        case setUsername(name: String?)
        case setValidUserNameResult(result: SignupValidationResult)
        case setPassword(password: String?)
        case setRepeatPassword(password: String?)
        case setLoading(loading: Bool)
        case signup(success: Bool)
    }
    
    struct State {
        var username: String?
        var validUserNameResult: SignupValidationResult = .empty
        var password: String?
        var validPasswordResult: SignupValidationResult = .empty
        var repeatPassword: String?
        var validRepeatPasswordResult: SignupValidationResult = .empty
        var enableSubmit: Bool = false
        var isLoading: Bool = false
        var isSigned: Bool = false
    }
    
    let initialState = State()
    
    let api: GitHubAPI
    let service: GitHubValidationService
    
    init(service: GitHubValidationService, api: GitHubAPI) {
        self.api = api
        self.service = service
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .inputUsername(name):
                guard let name = name else { return Observable.empty() }
                return Observable.concat([
                    // 更新 name
                    Observable.just(Mutation.setUsername(name: name)),
                    // 验证 name
                    service.validateUsername(name).map { Mutation.setValidUserNameResult(result: $0) }
                ])
            case let .inputPassword(password):
                guard let password = password else { return Observable.empty() }
                return Observable.just(Mutation.setPassword(password: password))
            case let .inputRepeatPassword(password):
                guard let password = password else { return Observable.empty() }
                return Observable.just(Mutation.setRepeatPassword(password: password))
            case let .signup(name, password):
                guard let name = name, let password = password else {
                    return Observable.empty()
                }
                return Observable.concat([
                    // 置为Loading态
                    Observable.just(Mutation.setLoading(loading: true)),
                    // CallApI
                    api.signup(name, password: password)
                        .take(until: self.action.filter(Action.isSignupAction))
                        .map { Mutation.signup(success: $0)},
                    // 回复Loading态
                    Observable.just(Mutation.setLoading(loading: false))
                ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            case let .setUsername(name):
                newState.username = name
            case .setValidUserNameResult(result: let result):
                newState.validUserNameResult = result
            case .setPassword(password: let password):
                newState.password = password
                newState.validPasswordResult = service.validatePassword(password ?? "")
            case .setRepeatPassword(password: let password):
                newState.repeatPassword = password
                newState.validRepeatPasswordResult = service.validateRepeatedPassword(newState.password ?? "", repeatedPassword: password ?? "")
            case .setLoading(loading: let loading):
                newState.isLoading = loading
            case .signup(success: let success):
                newState.isSigned = success
        }
        newState.enableSubmit = newState.validUserNameResult.isValid && newState.validPasswordResult.isValid && newState.validRepeatPasswordResult.isValid && !newState.isLoading
        return newState
    }
}

extension SignupControllerReactor.Action {
    static func isSignupAction(_ action: SignupControllerReactor.Action) -> Bool {
        if case .signup  = action {
            return true
        }
        return false
    }
}
