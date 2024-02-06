//
//  CameraLabelStyle.swift
//  DualDepth
//
//  Created by Mac mini M2 Pro on 2024/02/06.
//

import SwiftUI

// https://qiita.com/uhooi/items/6aa53a3f07b867a8977a
struct CameraLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .frame(width: 16, height: 16)
            
            configuration.title
                .font(.system(size: 8, design: .monospaced))
        }
    }
}

extension LabelStyle where Self == CameraLabelStyle {
    static var cameraLabel: Self { .init() }
}
