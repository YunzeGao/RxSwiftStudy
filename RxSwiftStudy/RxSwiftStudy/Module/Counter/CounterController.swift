//
//  Counter.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/6.
//

import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

fileprivate let viewHeight = 44
fileprivate let labelWidth = 60

extension UIButton {
    convenience init(counterText: String) {
        self.init(type: .custom)
        setTitle(counterText, for: .normal)
        setTitleColor(.black, for: .normal)
        layer.borderWidth = 1
    }
}

class CounterController : UIViewController, View {
    
    private lazy var addBtn = UIButton(counterText: "+")
    private lazy var subBtn = UIButton(counterText: "-")
    private lazy var textLabel : UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir-Oblique", size: 16)
        label.layer.borderWidth = 1
        return label
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutUI()
        reactor = CounterReactor()
    }
    
    func setupNav() {
        navigationItem.title = "Counter Example"
    }
    
    func layoutUI() {
        setupNav()
        view.backgroundColor = .white
        
        view.addSubview(textLabel)
        view.addSubview(subBtn)
        view.addSubview(addBtn)
        
        textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(viewHeight)
            make.width.equalTo(labelWidth)
        }
        
        subBtn.snp.makeConstraints { make in
            make.top.equalTo(textLabel)
            make.right.equalTo(textLabel.snp.left)
            make.height.width.equalTo(viewHeight)
        }
        
        addBtn.snp.makeConstraints { make in
            make.top.equalTo(textLabel)
            make.left.equalTo(textLabel.snp.right)
            make.height.width.equalTo(viewHeight)
        }
    }
    
    func bind(reactor: CounterReactor) {
        // Action
        subBtn.rx.tap
            .map { Reactor.Action.update(x: -1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addBtn.rx.tap
            .map { Reactor.Action.update(x: 1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state
            .map { String($0.number) }
            .bind(to: textLabel.rx.text.asObserver())
            .disposed(by: disposeBag)
        // View
    }
}

final class CounterReactor : Reactor {
    enum Action {
        // 点击按钮
        case update(x: Int)
    }
    
    enum Mutation {
        case addNumber(x: Int)
    }
    
    struct State {
        var number : Int = 0
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .update(x):
                return Observable.just(Mutation.addNumber(x: x))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
            case let .addNumber(x):
                var newState = state
                newState.number += x
                return newState
        }
    }
}
