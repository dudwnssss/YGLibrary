//
//  SearchBarView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

struct SearchBarView: View {
    @State private var searchText: String = ""
    let query: String
    let onSubmitted: (String) -> Void
    private let placeholder: String = "제목 또는 저자를 입력하세요"
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $searchText)
                .font(.system(size: 16))
                .submitLabel(.search)
                .onSubmit {
                    onSubmitted(searchText)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    onSubmitted("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.systemGray6))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.white)
        .onAppear {
            searchText = query
        }
        .onChange(of: query) { newValue in
            searchText = newValue
        }
    }
}
