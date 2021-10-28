//
//  IconList.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/28.
//

import Foundation

enum DualDepthAppIcon: String, CaseIterable {
    case dualWide = "Default"
    case tripleWithLiDAR = "TripleWithLiDARAppIcon"
    case triple = "TripleAppIcon"
    case dualWideCross = "DualWideCrossAppIcon"
    case dualTelescope = "DualTelescopeAppIcon"
    case dualTelescopeHorizontal = "DualTelescopeHorizontalAppIcon"
    
    func displayName() -> String {
        switch self {
        case .dualWide:
            return "iPhone 12"
        case .tripleWithLiDAR:
            return "iPhone 13 Pro"
        case .triple:
            return "iPhone 11 Pro"
        case .dualWideCross:
            return "iPhone 13"
        case .dualTelescope:
            return "iPhone Xs"
        case .dualTelescopeHorizontal:
            return "iPhone 8 Plus"
        }
    }
}
