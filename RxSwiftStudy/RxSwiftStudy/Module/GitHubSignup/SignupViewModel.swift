//
//  SignupViewModel.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/5.
//

import RxSwift
import RxCocoa

class SignupViewModel {
    // output
    let validatedUsername: Observable<SignupValidationResult>
    let validatedPassword: Observable<SignupValidationResult>
    let validatedPasswordRepeated: Observable<SignupValidationResult>
    
    /// Is signup button enabled
    let signupEnabled: Observable<Bool>
    /// Has user signed in
    let signedIn: Observable<Bool>
    // Is signing process in progress
    let signingIn: Observable<Bool>

    typealias Input = (username: Observable<String>,
                       password: Observable<String>,
                       repeatedPassword: Observable<String>,
                       loginTaps: Observable<Void>)
    
    typealias Dependency = (API: GitHubAPI, validationService: GitHubValidationService)
    
    // input
    init(input: Input, dependency: Dependency) {
        let API = dependency.API
        let validationService = dependency.validationService
        
        validatedUsername = input.username.flatMapLatest {
            validationService.validateUsername($0)
                .observe(on: MainScheduler.instance)
                .catchAndReturn(.failed(message: "Error contacting server"))
        }
        
        validatedPassword = input.password.map {
            validationService.validatePassword($0)
        }.share(replay: 1)
        
        validatedPasswordRepeated = Observable.combineLatest(input.password, input.repeatedPassword, resultSelector: { validationService.validateRepeatedPassword($0, repeatedPassword: $1)
        }).share(replay: 1)
        
        let requestOnAir = BehaviorRelay<Bool>(value: false)
        signingIn = requestOnAir.asObservable()
        
        let usernameAndPassword = Observable.combineLatest(input.username, input.password) { (username: $0, password: $1) }
        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword).flatMapLatest({user in
            requestOnAir.accept(true)
            return API.signup(user.username, password: user.password)
                .observe(on:MainScheduler.instance)
                .catchAndReturn(false)
        }).flatMapLatest({ loggedIn -> Observable<Bool> in
            let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to GitHub failed"
            print(message)
            requestOnAir.accept(false)
            return Observable.of(loggedIn)
        }).share(replay: 1)
        
        signupEnabled = Observable.combineLatest(validatedUsername, validatedPassword, validatedPasswordRepeated, signingIn) {
            $0.isValid && $1.isValid && $2.isValid && !$3
        }.distinctUntilChanged().share(replay: 1)
    }
}
