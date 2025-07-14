//
//  FloatingButton.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import UIKit

final class FloatingButton: UIButton {
    private var lastLocation: CGPoint = .zero
    private var isDragging = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .systemYellow
        setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        tintColor = .white
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 4
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        if !isDragging {
            NotificationCenter.default.post(name: NSNotification.Name("ShowApiMockingTool"), object: nil)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform.identity
                }
            })
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = self.superview else { return }
        
        switch gesture.state {
        case .began:
            isDragging = true
            lastLocation = self.center
            
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.8
            }
            
        case .changed:
            let translation = gesture.translation(in: superview)
            let newCenter = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
            
            let halfWidth = frame.width / 2
            let halfHeight = frame.height / 2
            let minX = halfWidth + 8
            let maxX = superview.bounds.width - halfWidth - 8
            let minY = halfHeight + 8
            let maxY = superview.bounds.height - halfHeight - 8
            
            center = CGPoint(
                x: min(maxX, max(minX, newCenter.x)),
                y: min(maxY, max(minY, newCenter.y))
            )
            
        case .ended, .cancelled:
            isDragging = false
            
            UIView.animate(withDuration: 0.3) {
                let rightEdge = superview.bounds.width - self.frame.width / 2 - 16
                let leftEdge = self.frame.width / 2 + 16
                
                if self.center.x > superview.bounds.width / 2 {
                    self.center.x = rightEdge
                } else {
                    self.center.x = leftEdge
                }
                
                self.alpha = 1.0
            }
            
        default:
            break
        }
    }
}
