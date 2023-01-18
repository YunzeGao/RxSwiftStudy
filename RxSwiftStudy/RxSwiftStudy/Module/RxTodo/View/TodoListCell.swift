//
//  TodoListCell.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import SnapKit
import ReactorKit

class TodoListCell: UITableViewCell, View {
    
    private struct Constant {
        static let font = UIFont.systemFont(ofSize: 15)
        static let numberOfLines = 2
        static let padding: Double = 15
        static let cellHeight: Double = 44
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = Constant.font
        label.textColor = .black
        label.numberOfLines = Constant.numberOfLines
        label.sizeToFit()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: TodoListCellReactor) {
        title.text = reactor.currentState.text
        accessoryType = reactor.currentState.done ? .checkmark : .none
    }
    
    class func height(fits width: CGFloat, reactor: TodoListCellReactor) -> CGFloat {
        guard let text = reactor.currentState.text else {
            return Constant.cellHeight
        }
        let height = text.height(
          fits: width - Constant.padding * 2,
          font: Constant.font,
          maximumNumberOfLines: Constant.numberOfLines
        )
        return height + Constant.padding * 2
    }
}

extension TodoListCell {
    private func makeUI() {
        contentView.addSubview(title)
        title.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constant.padding)
            make.top.equalToSuperview().offset(Constant.padding)
            make.right.equalToSuperview().offset(-Constant.padding)
        }
    }
}
