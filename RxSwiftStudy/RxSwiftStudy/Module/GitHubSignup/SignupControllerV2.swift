//
//  SignupControllerV2.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/6.
//

import RxSwift
import RxCocoa
import RxGesture
import ReactorKit
import SnapKit

class SignupControllerV2: UIViewController, View {

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
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutUI()
        reactor = SignupControllerReactor(service: GitHubDefaultValidationService.sharedValidationService,
                                          api: GitHubDefaultAPI.sharedAPI)
    }
    
    func bind(reactor: SignupControllerReactor) {
        // Action
        username.field.rx.text
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.inputUsername(name: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        password.field.rx.text
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.inputPassword(password: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        passwordRepeat.field.rx.text
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.inputRepeatPassword(password: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        submitButton.rx.tap.map { [weak self] in
            Reactor.Action.signup(name: self?.username.text, password: self?.password.text)
        }.bind(to: reactor.action).disposed(by: disposeBag)
        // State
        reactor.state.map { $0.validUserNameResult }.bind(to: username.rx.validationResult).disposed(by: disposeBag)
        reactor.state.map { $0.validPasswordResult }.bind(to: password.rx.validationResult).disposed(by: disposeBag)
        reactor.state.map { $0.validRepeatPasswordResult }.bind(to: passwordRepeat.rx.validationResult).disposed(by: disposeBag)
        reactor.state.map { $0.enableSubmit }.bind(to: submitButton.rx.isEnabled).disposed(by: disposeBag)
        reactor.state.map { $0.isLoading }.bind(to: loadingView.rx.isAnimating).disposed(by: disposeBag)
        reactor.state.map { $0.isSigned }
            .distinctUntilChanged()
            .subscribe { [weak self] success in
            self?.showAlert(success)
        }.disposed(by: disposeBag)
        // View
        view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in self?.view.endEditing(true) })
            .disposed(by: disposeBag)
    }
}

fileprivate let topMargin = 8
fileprivate let leftMargin = 20
fileprivate let btnHeight = 40

extension SignupControllerV2 {
    
    func setupNav() {
        title = "GitHub SignUp"
    }
    
    func layoutUI() {
        setupNav()
        
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
}

extension SignupControllerV2 {
    func showAlert(_ flag: Bool) {
        print("User signed in \(flag)")
    }
}
