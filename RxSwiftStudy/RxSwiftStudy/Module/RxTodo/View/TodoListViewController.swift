//
//  TodoViewController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/19.
//

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import RxViewController

class TodoListViewController : BaseViewController, View {
    
    private lazy var addButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    }()
    
    let dataSource = RxTableViewSectionedReloadDataSource<TaskListSection> { _, tableView, indexPath, reactor in
        let cell: TodoListCell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath) as! TodoListCell
        cell.reactor = reactor
        return cell
    }
    
    var tableView: UITableView = {
        let table = UITableView()
        table.allowsSelectionDuringEditing = true
        table.register(TodoListCell.self, forCellReuseIdentifier: "TodoListCell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = TodoListReactor()
    }
    
    override func makeUI() {
        super.makeUI()
        navigationItem.title = "待办清单"
        navigationItem.leftBarButtonItem = addButtonItem
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func layoutUI() {
        super.layoutUI()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
        }
    }
    
    func bind(reactor: TodoListReactor) {
        // DataSource
        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        self.dataSource.canEditRowAtIndexPath = { _, _  in true }
        self.dataSource.canMoveRowAtIndexPath = { _, _  in true }
        // Action
        rx.viewDidAppear
            .map { _ in Reactor.Action.fetchData }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        addButtonItem.rx.tap
            .map(reactor.reactorForCreatingTask)
            .subscribe { [weak self] reactor in
                self?.presentEditVC(reactor)
            }.disposed(by: disposeBag)
        editButtonItem.rx.tap
            .map { Reactor.Action.editClick }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .withLatestFrom(reactor.state.map { $0.isEditing }) { path, editing in
                (path, editing)
            }
            .filter { _, editing in !editing }
            .map { path, _ in Reactor.Action.cellDoneClick(path) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(TodoListCellReactor.self)
            .withLatestFrom(reactor.state.map { $0.isEditing }, resultSelector: { ($0, $1) })
            .filter { _, editing in editing }
            .map { cellReactor, _ in reactor.reactorForEditingTask(cellReactor) }
            .subscribe { [weak self] editReactor in
                self?.presentEditVC(editReactor)
            }
            .disposed(by: self.disposeBag)
        tableView.rx.itemDeleted
            .map(Reactor.Action.remove)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        tableView.rx.itemMoved
            .map(Reactor.Action.move)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        // State
        reactor.pulse(\.$isEditing)
            .subscribe { [weak self] editing in
                self?.editButtonItem.title = editing ? "完成" : "编辑"
                self?.editButtonItem.style = editing ? .done : .plain
                self?.tableView.setEditing(editing, animated: true)
            }.disposed(by: disposeBag)
        reactor.pulse(\.$dataSource)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        reactor.pulse(\.$fetchLoading)
            .filterNil()
            .subscribe {[weak self] loading in
                guard let `self` = self else { return }
                if (loading) {
                    self.view.makeToastActivity(.center)
                } else {
                    self.view.hideToastActivity()
                }
            }.disposed(by: disposeBag)
        // View
        view.rx.screenEdgePanGesture(configuration: { ges, _ in
            ges.edges = .left
        }).when(.ended).subscribe(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
    
    func presentEditVC(_ reactor: TodoEditReactor) {
        present(UINavigationController(rootViewController: TodoEditController(reactor: reactor)), animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print("\(editing)")
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let reactor = self.dataSource[indexPath]
    return TodoListCell.height(fits: tableView.bounds.width, reactor: reactor)
  }
}
