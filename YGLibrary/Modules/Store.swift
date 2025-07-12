//
//  Store.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import Foundation

@dynamicMemberLookup
@MainActor
protocol Store: ObservableObject {
    associatedtype Action
    associatedtype State
    
    var state: State { get }
    
    func dispatch(_ action: Action)
}

extension Store {
  subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
    self.state[keyPath: keyPath]
  }
}
