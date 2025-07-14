//
//  APIMockingViewController.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import UIKit

final class APIMockingViewController: UIViewController {
    
    private let tableView = UITableView()
    private var records: [APIRecord] = []
    private let emptyStateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRecords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecords()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTableView()
        setupEmptyState()
    }
    
    private func setupNavigationBar() {
        title = "API 모킹"
        
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .systemGray
        navigationItem.leftBarButtonItem = closeButton
        
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(showActionsMenu)
        )
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(APIMethodCell.self, forCellReuseIdentifier: "ApiMethodCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateLabel.text = "기록된 API 요청이 없습니다.\n앱을 사용하면 자동으로 기록됩니다."
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .systemFont(ofSize: 16)
        emptyStateLabel.isHidden = true
        
        view.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func loadRecords() {
        records = APIMockingManager.shared.records
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !records.isEmpty
    }
        
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func showActionsMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
            title: "모킹 전체 비활성화",
            style: .default,
            handler: { [weak self] _ in
                self?.disableAllMocks()
            }
        ))
        
        alertController.addAction(UIAlertAction(
            title: "기록 전체 삭제",
            style: .destructive,
            handler: { [weak self] _ in
                self?.confirmDeleteAllRecords()
            }
        ))
        
        alertController.addAction(UIAlertAction(
            title: "취소",
            style: .cancel
        ))
        
        present(alertController, animated: true)
    }
    
    private func disableAllMocks() {
        APIMockingManager.shared.disableAllMocks()
        
        // UI 업데이트 최적화
        DispatchQueue.main.async {
            self.loadRecords()
            self.tableView.reloadData()
            self.showToast(message: "모든 모킹이 비활성화되었습니다")
        }
    }
    
    private func confirmDeleteAllRecords() {
        let alert = UIAlertController(
            title: "전체 삭제",
            message: "모든 API 기록을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(
            title: "삭제",
            style: .destructive,
            handler: { [weak self] _ in
                self?.deleteAllRecords()
            }
        ))
        
        present(alert, animated: true)
    }
    
    private func deleteAllRecords() {
        APIMockingManager.shared.deleteAllRecords()
        
        DispatchQueue.main.async {
            self.records.removeAll()
            self.tableView.reloadData()
            self.updateEmptyState()
        }
    }
    
    private func showToast(message: String) {
        let toastView = UIView()
        toastView.backgroundColor = UIColor.label.withAlphaComponent(0.7)
        toastView.layer.cornerRadius = 20
        toastView.clipsToBounds = true
        toastView.alpha = 0
        
        let label = UILabel()
        label.text = message
        label.textColor = .systemBackground
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        
        toastView.addSubview(label)
        view.addSubview(toastView)
        
        toastView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toastView.widthAnchor.constraint(equalToConstant: 240),
            toastView.heightAnchor.constraint(equalToConstant: 44),
            
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: toastView.topAnchor),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                toastView.alpha = 0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
}


extension APIMockingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApiMethodCell", for: indexPath) as? APIMethodCell else {
            return UITableViewCell()
        }
        let record = records[indexPath.row]
        cell.configure(with: record)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let record = records[indexPath.row]
        
        let detailVC = APIDetailViewController(record: record)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
            guard let self else { return }
            
            let recordToDelete = self.records[indexPath.row]
            APIMockingManager.shared.deleteRecord(id: recordToDelete.id)
            
            self.records.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateEmptyState()
            
            completion(true)
        }
        
        let record = records[indexPath.row]
        let toggleTitle = record.isActive ? "비활성화" : "활성화"
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] (_, _, completion) in
            guard let self else { return }
            
            let updatedIsActive = !record.isActive
            
            APIMockingManager.shared.updateMockedResponse(
                for: record.id,
                with: record.mockedResponse ?? record.originalResponse,
                isActive: updatedIsActive
            )
            
            DispatchQueue.main.async {
                self.loadRecords()
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            completion(true)
        }
        
        toggleAction.backgroundColor = record.isActive ? .systemOrange : .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
    }
}
