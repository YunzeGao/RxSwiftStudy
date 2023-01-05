//
//  SignupController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/5.
//

import UIKit
import RxSwift
import SnapKit
import RxGesture

class SignupController: UIViewController {
    
    private lazy var username = SignupField("Username")
    private lazy var password = SignupField("Password")
    private lazy var passwordRepeat = SignupField("Password Repeat")
    private lazy var submitButton : UIButton = {
        var btn = UIButton(type: .custom)
        btn.setTitle("submit", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.white, for: .disabled)
        btn.backgroundColor = .green
        btn.alpha = 0.6
        return btn
    }()
    private lazy var loadingView : UIActivityIndicatorView = {
        var loading = UIActivityIndicatorView(style: .medium)
        return loading
    }()
    
    private let disposeBag = DisposeBag()
    
    var viewModel : SignupViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutUI()
        bind()
    }
}

fileprivate let topMargin = 8
fileprivate let leftMargin = 20
fileprivate let btnHeight = 40

extension SignupController {
    func layoutUI() {
        view.backgroundColor = .white
        view.addSubview(username)
        view.addSubview(password)
        view.addSubview(passwordRepeat)
        view.addSubview(submitButton)
        view.addSubview(loadingView)
        
        username.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(topMargin + 22)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
        }
        password.snp.makeConstraints { make in
            make.top.equalTo(username.snp.bottom).offset(topMargin)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
        }
        passwordRepeat.snp.makeConstraints { make in
            make.top.equalTo(password.snp.bottom).offset(topMargin)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
        }
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordRepeat.snp.bottom).offset(topMargin * 2)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(btnHeight)
        }
        loadingView.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(submitButton)
            make.width.equalTo(btnHeight)
        }
    }
    
    func bind() {
        let inputs = (
            username.field.rx.text.orEmpty.asObservable(),
            password.field.rx.text.orEmpty.asObservable(),
            passwordRepeat.field.rx.text.orEmpty.asObservable(),
            submitButton.rx.tap.asObservable()
        )
        let dependencies = (
            GitHubDefaultAPI.sharedAPI,
            GitHubDefaultValidationService.sharedValidationService
        )
        viewModel = SignupViewModel(input: inputs, dependency: dependencies)
        
        viewModel.validatedUsername.bind(to: username.rx.validationResult).disposed(by: disposeBag)
        viewModel.validatedPassword.bind(to: password.rx.validationResult).disposed(by: disposeBag)
        viewModel.validatedPasswordRepeated.bind(to: passwordRepeat.rx.validationResult).disposed(by: disposeBag)
        viewModel.signupEnabled.subscribe(onNext: { [weak self] valid  in
            self?.submitButton.isEnabled = valid
            self?.submitButton.alpha = valid ? 1.0 : 0.6
        }).disposed(by: disposeBag)
        viewModel.signingIn.bind(to: loadingView.rx.isAnimating).disposed(by: disposeBag)
        viewModel.signedIn.subscribe(onNext: { signedIn in
            print("User signed in \(signedIn)")
        }).disposed(by: disposeBag)
        
        submitButton.rx.tap
            .subscribe(onNext: {[weak self] in self?.submit()})
            .disposed(by: disposeBag)
        view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in self?.view.endEditing(true) })
            .disposed(by: disposeBag)
    }
}

extension SignupController {
    func submit() {
        print("username = \(username.text), password = \(password.text)")
    }
}
