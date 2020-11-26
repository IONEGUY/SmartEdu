//
//  MessageTableViewCell.swift
//  SmartEducation
//
//  Created by MacBook on 11/18/20.
//

import UIKit
import SnapKit

class MessageTableViewCell: UITableViewCell {
    private var messageText: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private var sentTime: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private var container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var rootContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    func initialize(withData data: MessageCellModel) {
        initView(data.messageType)
        
        messageText.text = data.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        sentTime.text = dateFormatter.string(from: data.sentTime)
        
        switch data.messageType {
        case .incoming:
            container.backgroundColor = UIColor(hex: 0xEBEDF0)
        case .outgoing:
            container.backgroundColor = UIColor(hex: 0xCCE4FF)
        }
    }
    
    private func initView(_ messageType: MessageType) {
        initConstraints(messageType)
        changeSelectedBackground()
        container.applyRoundedStyle(borderColor: .clear, cornerRadius: 20)
    }
    
    private func changeSelectedBackground() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        selectedBackgroundView = backgroundView
    }
    
    private func initConstraints(_ messageType: MessageType) {
        rootContainer.addSubview(container)
        contentView.addSubview(rootContainer)
        container.addSubview(messageText)
        container.addSubview(sentTime)
        
        rootContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        container.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview()
            (messageType == .incoming ? make.left : make.right)
                .equalToSuperview()
        }
        
        messageText.snp.makeConstraints { make in
            make.leading.equalTo(container.snp.leading).offset(20)
            make.top.equalTo(container.snp.top).offset(8)
            make.bottom.equalTo(container.snp.bottom).offset(-8)
            make.trailing.equalTo(sentTime.snp.leading).offset(-8)
        }
        
        sentTime.snp.makeConstraints { make in
            make.bottom.equalTo(container.snp.bottom).offset(-10)
            make.trailing.equalTo(container.snp.trailing).offset(5)
            make.width.equalTo(50)
        }
    }
}
