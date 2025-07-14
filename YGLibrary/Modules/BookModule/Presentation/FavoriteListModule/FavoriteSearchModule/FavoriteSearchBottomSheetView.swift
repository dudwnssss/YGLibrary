//
//  FavoriteSearchModalView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import SwiftUI

struct FavoriteSearchBottomSheetView: View {
    let onQuerySelected: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store: FavoriteSearchStore
    @FocusState private var isSearchFocused: Bool
    
    init(onQuerySelected: @escaping (String) -> Void) {
        self.onQuerySelected = onQuerySelected
        self._store = StateObject(wrappedValue: FavoriteSearchStore(onQuerySelected: onQuerySelected))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: .zero) {
                searchBarSection
                
                if store.state.isLoading {
                    loadingView
                } else if store.state.query.isEmpty {
                    emptyStateView
                } else if store.state.suggestions.isEmpty {
                    noResultsView
                } else {
                    suggestionsListView
                }
                
                Spacer()
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                if !store.state.query.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("검색") {
                            store.dispatch(.selectQuery(store.state.query))
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            store.dispatch(.onAppear)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSearchFocused = true
            }
        }
    }
        
    private var searchBarSection: some View {
        VStack(spacing: .zero) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                
                TextField("제목 또는 저자를 입력하세요", text: Binding(
                    get: { store.state.query },
                    set: { store.dispatch(.updateQuery($0)) }
                ))
                .font(.system(size: 16))
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    if !store.state.query.isEmpty {
                        store.dispatch(.selectQuery(store.state.query))
                        dismiss()
                    }
                }
                
                if !store.state.query.isEmpty {
                    Button(action: {
                        store.dispatch(.updateQuery(""))
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
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemBackground))
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Divider()
                .padding(.top, 16)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("즐겨찾기 불러오는 중...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("즐겨찾기에서 검색해보세요")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("즐겨찾기한 책의 제목, 저자, 출판사에서\n일치하는 항목을 찾아드려요")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("검색 결과가 없어요")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("'\(store.state.query)'와 일치하는\n즐겨찾기 항목이 없습니다")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
    
    private var suggestionsListView: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                ForEach(store.state.suggestions) { suggestion in
                    SearchSuggestionRowView(
                        suggestion: suggestion,
                        query: store.state.query
                    ) {
                        store.dispatch(.selectSuggestion(suggestion))
                        dismiss()
                    }
                    
                    if suggestion.id != store.state.suggestions.last?.id {
                        Divider()
                            .padding(.leading, 48)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    FavoriteSearchBottomSheetView { query in
        print("Selected query: \(query)")
    }
}
