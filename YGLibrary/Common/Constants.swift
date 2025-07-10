//
//  Constants.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import UIKit
import SwiftUI

enum Destination {
    case mainTab
    case bookDetail
}

protocol ModuleFactory {
    func makeModule(for destination: Destination) -> UIViewController
}

//struct ModuleFactoryImpl: ModuleFactory {
//    func makeModule(for destination: Destination) -> UIViewController {
//        switch destination {
//        case .mainTab:
//            <#code#>
//        case .bookDetail:
//            <#code#>
//        }
//    }
//}
