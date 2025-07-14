//
//  APIDetailController.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import UIKit

final class APIDetailViewController: UIViewController, UITextViewDelegate {
    private let record: APIRecord
    private let textView = UITextView()
    private let segmentedControl = UISegmentedControl(items: ["원본", "모킹"])
    private let mockSwitch = UISwitch()
    
    private let headerView = UIView()
    private let methodLabel = UILabel()
    private let urlLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let bottomToolbar = UIView()
    
    private var textViewBottomConstraint: NSLayoutConstraint?
    
    init(record: APIRecord) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupHeaderView()
        setupTextView()
        setupBottomToolbar()
        updateUI(forEditMode: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNavigationBar() {
        title = ""
        
        // 닫기 버튼
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = .systemBackground
        
        methodLabel.font = .systemFont(ofSize: 14, weight: .bold)
        methodLabel.textAlignment = .center
        methodLabel.textColor = .white
        methodLabel.layer.cornerRadius = 6
        methodLabel.clipsToBounds = true
        methodLabel.text = record.method
        
        let statusCodeLabel = UILabel()
        statusCodeLabel.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        statusCodeLabel.text = "\(record.statusCode)"
        
        if record.statusCode >= 200 && record.statusCode < 300 {
            statusCodeLabel.textColor = .systemGreen
        } else if record.statusCode >= 300 && record.statusCode < 400 {
            statusCodeLabel.textColor = .systemBlue
        } else if record.statusCode >= 400 && record.statusCode < 500 {
            statusCodeLabel.textColor = .systemOrange
        } else if record.statusCode >= 500 {
            statusCodeLabel.textColor = .systemRed
        } else {
            statusCodeLabel.textColor = .systemGray
        }
        
        switch record.method.uppercased() {
        case "GET":
            methodLabel.backgroundColor = UIColor.systemBlue
        case "POST":
            methodLabel.backgroundColor = UIColor.systemGreen
        case "PUT":
            methodLabel.backgroundColor = UIColor.systemOrange
        case "DELETE":
            methodLabel.backgroundColor = UIColor.systemRed
        case "PATCH":
            methodLabel.backgroundColor = UIColor.systemPurple
        default:
            methodLabel.backgroundColor = UIColor.systemGray
        }
        
        urlLabel.font = .systemFont(ofSize: 15, weight: .medium)
        urlLabel.textColor = .label
        urlLabel.numberOfLines = 0
        urlLabel.text = record.url
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        dateLabel.text = formatter.string(from: record.timestamp)
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5
        
        headerView.addSubview(methodLabel)
        headerView.addSubview(statusCodeLabel)
        headerView.addSubview(urlLabel)
        headerView.addSubview(dateLabel)
        headerView.addSubview(segmentedControl)
        headerView.addSubview(separator)
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        statusCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            methodLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            methodLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            methodLabel.widthAnchor.constraint(equalToConstant: 50),
            methodLabel.heightAnchor.constraint(equalToConstant: 24),
            
            statusCodeLabel.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 4),
            statusCodeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            statusCodeLabel.widthAnchor.constraint(equalToConstant: 50),
            
            urlLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            urlLabel.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 10),
            urlLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: statusCodeLabel.trailingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            segmentedControl.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            separator.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
        ])
    }
    
    private func setupTextView() {
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.alwaysBounceVertical = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 60, right: 8) // 하단 여백 증가
        textView.layer.cornerRadius = 0
        textView.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        textView.inputAccessoryView = toolbar
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        textViewBottomConstraint?.isActive = true
    }
    
    private func setupBottomToolbar() {
        bottomToolbar.backgroundColor = UIColor.systemBackground
        bottomToolbar.layer.borderWidth = 0.5
        bottomToolbar.layer.borderColor = UIColor.systemGray4.cgColor
        bottomToolbar.alpha = 0 // 초기에는 숨김
        
        let switchLabel = UILabel()
        switchLabel.text = "모킹 활성화"
        switchLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        mockSwitch.isOn = record.isActive
        mockSwitch.onTintColor = .systemBlue
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("적용", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // 레이아웃
        bottomToolbar.addSubview(switchLabel)
        bottomToolbar.addSubview(mockSwitch)
        bottomToolbar.addSubview(saveButton)
        view.addSubview(bottomToolbar)
        
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        mockSwitch.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 60),
            
            switchLabel.leadingAnchor.constraint(equalTo: bottomToolbar.leadingAnchor, constant: 16),
            switchLabel.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor),
            
            mockSwitch.leadingAnchor.constraint(equalTo: switchLabel.trailingAnchor, constant: 12),
            mockSwitch.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: bottomToolbar.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTextView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !textView.frame.contains(location) {
            dismissKeyboard()
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              segmentedControl.selectedSegmentIndex == 1 else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        textViewBottomConstraint?.constant = -keyboardHeight
        
        UIView.animate(withDuration: animationDuration) {
            self.bottomToolbar.alpha = 0
            self.view.layoutIfNeeded()
        }
        
        if let selectedRange = textView.selectedTextRange {
            let caretRect = textView.convert(textView.caretRect(for: selectedRange.end), to: nil)
            let visibleRect = view.frame.height - keyboardHeight
            
            if caretRect.maxY > visibleRect {
                textView.scrollRectToVisible(caretRect, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration) {
            if self.segmentedControl.selectedSegmentIndex == 1 {
                self.textViewBottomConstraint?.constant = -60
                self.bottomToolbar.alpha = 1
            } else {
                self.textViewBottomConstraint?.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        textView.resignFirstResponder()
    }
    
    @objc private func segmentChanged() {
        let isEditMode = segmentedControl.selectedSegmentIndex == 1
        updateUI(forEditMode: isEditMode)
        updateTextView()
    }
    
    @objc private func saveButtonTapped() {
        if segmentedControl.selectedSegmentIndex == 1 {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
            APIMockingManager.shared.updateMockedResponse(
                for: record.id,
                with: textView.text,
                isActive: mockSwitch.isOn
            )
            
            showToast(message: "저장되었습니다")
            
            dismissKeyboard()
        }
    }
    
    // MARK: - UI 업데이트
    
    private func updateUI(forEditMode isEditMode: Bool) {
        if isEditMode {
            navigationItem.rightBarButtonItem?.isEnabled = true
            textView.isEditable = true
            textView.backgroundColor = .systemBackground
            
            textViewBottomConstraint?.constant = -60
            UIView.animate(withDuration: 0.2) {
                self.bottomToolbar.alpha = 1
            }
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            textView.isEditable = false
            textView.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
            
            textViewBottomConstraint?.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.bottomToolbar.alpha = 0
            }
            
            dismissKeyboard()
        }
    }
    
    private func updateTextView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            textView.text = formatJSON(record.originalResponse)
        } else {
            textView.text = formatJSON(record.mockedResponse ?? record.originalResponse)
        }
        
        textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }
    
    private func formatJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8) else {
            return jsonString
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                return prettyString
            }
        } catch {
            // JSON 파싱 실패 시 원본 반환
        }
        
        return jsonString
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
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            toastView.widthAnchor.constraint(equalToConstant: 180),
            toastView.heightAnchor.constraint(equalToConstant: 40),
            
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: toastView.topAnchor),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor)
        ])
        
        UIView.animate(withDuration: 0.2, animations: {
            toastView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 1.5, options: [], animations: {
                toastView.alpha = 0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if let selectedRange = textView.selectedTextRange {
            let caretRect = textView.caretRect(for: selectedRange.end)
            textView.scrollRectToVisible(caretRect, animated: true)
        }
    }
}

