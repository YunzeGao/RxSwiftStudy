//
//  TodoEditController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import SnapKit
import RxSwift
import ReactorKit
import RxOptional

class TodoEditController: BaseViewController, View {
    
    private let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    private let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    private let textInput : UITextField = {
        let field = UITextField()
        field.placeholder = "Do something..."
        field.borderStyle = .roundedRect
        field.clearButtonMode = .always
        field.autocorrectionType = .no;
        field.autocapitalizationType = .none
        return field
    }()
    
    init(reactor: TodoEditReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      self.textInput.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func makeUI() {
        super.makeUI()
        self.navigationItem.leftBarButtonItem = cancelButtonItem
        self.navigationItem.rightBarButtonItem = doneButtonItem
        
        view.addSubview(textInput)
    }
    
    override func layoutUI() {
        super.layoutUI()
        
        textInput.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(22)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func bind(reactor: TodoEditReactor) {
        // Action
        cancelButtonItem.rx.tap
            .map { Reactor.Action.cancel }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        doneButtonItem.rx.tap
            .map { Reactor.Action.submit }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        textInput.rx.text
            .filterNil()
            .skip(2)
            .map { Reactor.Action.update(text: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        // State
        reactor.state.asObservable()
            .map { $0.task.isEmpty ? "New" : "Edit" }
            .distinctUntilChanged()
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        reactor.state.asObservable()
            .map { $0.task.text }
            .distinctUntilChanged()
            .bind(to: textInput.rx.text)
            .disposed(by: disposeBag)
        reactor.state.asObservable()
            .map({ state in
                guard let text = state.task.text else {
                    return false
                }
                return !text.isEmpty && !state.requesting
            })
            .bind(to: doneButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
        reactor.pulse(\.$isDismissed)
            .observe(on:MainScheduler.asyncInstance)
            .filter { $0 }
            .subscribe { [weak self] _ in
                self?.dismiss(animated: true)
            }.disposed(by: disposeBag)
        reactor.pulse(\.$requesting)
            .skip(1)
            .subscribe{ [weak self] flag in
                if (flag) {
                    self?.view.makeToastActivity(.center)
                } else {
                    self?.view.hideToastActivity()
                }
            }.disposed(by: disposeBag)
        reactor.pulse(\.$isSuccess)
            .skip(1)
            .subscribe { [weak self] flag in
                if (flag) {
                    self?.view.makeToast("保存成功!", duration: 0.5, position: .center, completion: { _ in
                        self?.dismiss(animated: true)
                    })
                } else {
                    self?.view.makeToast("保存失败，请重试!", duration: 0.5, position: .center)
                }
            }.disposed(by: self.disposeBag)
    }
}
