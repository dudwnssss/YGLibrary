//
//  APIMethodCell.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import UIKit

final class APIMethodCell: UITableViewCell {
    private let methodContainer = UIView()
    private let methodLabel = UILabel()
    private let statusCodeLabel = UILabel()
    private let pathLabel = UILabel()
    private let timeLabel = UILabel()
    private let statusIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        selectedBackgroundView = {
            let view = UIView()
            view.backgroundColor = UIColor.systemGray6
            return view
        }()
        
        methodContainer.layer.cornerRadius = 8
        methodContainer.clipsToBounds = true
        
        methodLabel.textColor = .white
        methodLabel.font = .systemFont(ofSize: 12, weight: .bold)
        methodLabel.textAlignment = .center
        
        statusCodeLabel.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        statusCodeLabel.textAlignment = .center
        
        pathLabel.textColor = .label
        pathLabel.font = .systemFont(ofSize: 14, weight: .medium)
        pathLabel.numberOfLines = 1
        
        timeLabel.textColor = .secondaryLabel
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textAlignment = .right
        
        statusIndicator.layer.cornerRadius = 4
        statusIndicator.clipsToBounds = true
        
        // 레이아웃 추가
        contentView.addSubview(methodContainer)
        methodContainer.addSubview(methodLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(pathLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(statusIndicator)
        
        methodContainer.translatesAutoresizingMaskIntoConstraints = false
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        statusCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        pathLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            methodContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            methodContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            methodContainer.widthAnchor.constraint(equalToConstant: 50),
            methodContainer.heightAnchor.constraint(equalToConstant: 24),
            
            methodLabel.topAnchor.constraint(equalTo: methodContainer.topAnchor),
            methodLabel.leadingAnchor.constraint(equalTo: methodContainer.leadingAnchor),
            methodLabel.trailingAnchor.constraint(equalTo: methodContainer.trailingAnchor),
            methodLabel.bottomAnchor.constraint(equalTo: methodContainer.bottomAnchor),
            
            statusCodeLabel.topAnchor.constraint(equalTo: methodContainer.bottomAnchor, constant: 4),
            statusCodeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusCodeLabel.widthAnchor.constraint(equalToConstant: 50),
            
            pathLabel.leadingAnchor.constraint(equalTo: methodContainer.trailingAnchor, constant: 12),
            pathLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            pathLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timeLabel.leadingAnchor.constraint(equalTo: statusCodeLabel.trailingAnchor, constant: 12),
            timeLabel.topAnchor.constraint(equalTo: pathLabel.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: statusIndicator.leadingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            statusIndicator.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            statusIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusIndicator.widthAnchor.constraint(equalToConstant: 8),
            statusIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configure(with record: APIRecord) {
        let method = record.method
        methodLabel.text = method
        
        let urlComponents = URLComponents(string: record.url)
        let path = urlComponents?.path ?? ""
        let displayPath = path.isEmpty ? record.url : path
        pathLabel.text = displayPath
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: record.timestamp)
        
        statusCodeLabel.text = "\(record.statusCode)"
        
        if record.statusCode >= 200 && record.statusCode < 300 {
            // 성공 (2xx)
            statusCodeLabel.textColor = .systemGreen
        } else if record.statusCode >= 300 && record.statusCode < 400 {
            // 리다이렉션 (3xx)
            statusCodeLabel.textColor = .systemBlue
        } else if record.statusCode >= 400 && record.statusCode < 500 {
            // 클라이언트 오류 (4xx)
            statusCodeLabel.textColor = .systemOrange
        } else if record.statusCode >= 500 {
            // 서버 오류 (5xx)
            statusCodeLabel.textColor = .systemRed
        } else {
            // 기타 상태 코드
            statusCodeLabel.textColor = .systemGray
        }
        
        switch method.uppercased() {
        case "GET":
            methodContainer.backgroundColor = UIColor.systemBlue
        case "POST":
            methodContainer.backgroundColor = UIColor.systemGreen
        case "PUT":
            methodContainer.backgroundColor = UIColor.systemOrange
        case "DELETE":
            methodContainer.backgroundColor = UIColor.systemRed
        case "PATCH":
            methodContainer.backgroundColor = UIColor.systemPurple
        default:
            methodContainer.backgroundColor = UIColor.systemGray
        }
        
        statusIndicator.backgroundColor = record.isActive ? .systemGreen : .systemGray3
    }
}
