//
//  CameraView.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/26.
//

import SwiftUI

struct CameraView: View {
    @StateObject var model = CameraModel()
    
    var captureButton: some View {
            Button(action: {
                model.capturePhoto()
            }, label: {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80, alignment: .center)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.8), lineWidth: 2)
                            .frame(width: 65, height: 65, alignment: .center)
                    )
            })
        }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Image(systemName: "square.stack.3d.forward.dottedline")
                        .foregroundColor(model.isDepthMapAvailable ? .yellow : .secondary)
                        .padding(.horizontal)
                    Spacer()
                }
                
                CameraPreview(session: model.session)
                    .onAppear {
                        model.configure()
                    }
                    .alert(isPresented: $model.showAlertError) {
                        Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                            model.alertError.primaryAction?()
                        }))
                    }
                    .overlay(
                        Group {
                            if model.willCapturePhoto {
                                Color.black
                            }
                        }
                    )
                    .animation(.easeIn)
                
                // Button to capture photo
                captureButton
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
