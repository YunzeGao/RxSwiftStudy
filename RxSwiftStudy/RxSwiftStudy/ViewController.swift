//
//  ViewController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/4.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let dataSource = Observable.from(optional: [
        "Login",
        "Github Signup",
        "Github Search"
    ])

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    func setupUI() {
        self.navigationItem.title = "功能列表"
        view.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
        }
    }
    
    func bind() {
        let handlers:[() -> Void] = [
            { self.gotoLoginController() },
            { self.gotoGithubSignupController() },
            { self.gotoGitHubSearchViewController() }
        ]
        dataSource.bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, name, cell in
            cell.textLabel?.text = name
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: false)
            handlers[indexPath.row]()
        }).disposed(by: disposeBag)
    }
}

extension ViewController {
    func gotoLoginController() {
        self.navigationController?.pushViewController(LoginController(), animated: true)
    }
    
    func gotoGithubSignupController() {
        self.navigationController?.pushViewController(SignupController(), animated: true)
    }
    
    func gotoGitHubSearchViewController() {
        self.navigationController?.pushViewController(GitHubSearchViewController(), animated: true)
    }
}

