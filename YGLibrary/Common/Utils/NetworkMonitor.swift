//
//  NetworkMonitor.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import Network

import SwiftUI

final class NetworkMonitor: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkManager")
    @Published var isConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        
        monitor.start(queue: queue)
    }

}
