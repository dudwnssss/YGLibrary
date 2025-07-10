//
//  SearchBarView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

struct SearchBarView: View {
    @State private var searchText: String = ""
    private let placeholder: String = "제목 또는 저자를 입력하세요"
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField(placeholder, text: $searchText)
        }
        .padding(16)
        .frame(height: 44)
        .background(Color(uiColor: .systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
            
#Preview {
    SearchBarView()
}


