//
//  View+.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        modifier(HideKeyboardOnTap())
    }
}

struct HideKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle()) 
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
    }
}
