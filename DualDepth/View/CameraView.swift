//
//  CameraView.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/26.
//

import SwiftUI

struct CameraView: View {
    @StateObject var model = CameraModel()
    
    // MARK: -
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
    
    var capturedPhotoThumbnail: some View {
                Group {
                    if model.photo != nil {
                        Image(uiImage: model.photo.image!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .animation(.spring, value: model.photo)
//                            .animation(.spring())
        
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 60, height: 60, alignment: .center)
                            .foregroundColor(.black)
                    }
                }
            }
    // MARK: - status
    @State private var isPresented = false
    
    // MARK: - body
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 10) {
                    Image(systemName: "square.stack.3d.forward.dottedline")
                        .foregroundColor(model.isDepthMapAvailable ? .yellow : .secondary)
                    Image(systemName: "square.dotted")
                        .foregroundColor(model.isLiDARAvailable ? .yellow : .secondary)
                    Spacer()
                }
                .padding(.horizontal)
                
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
                
                ZStack {
                    HStack {
                        // Depthmap thumbnail
                        capturedPhotoThumbnail
                        
                        Spacer()
                        
                        // Setting
                        Button {
                            isPresented.toggle()
                        } label: {
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                        }
                        .padding()

                    }
                    
                    // Button to capture photo
                    captureButton
                }
            }
            .sheet(isPresented: $isPresented) {
                // Dismiss
            } content: {
                SettingView()
            }

        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
