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

//struct CameraView: View {
//    @StateObject var model = CameraModel()
//
//    @State var currentZoomFactor: CGFloat = 1.0
//
//    var captureButton: some View {
//        Button(action: {
//            model.capturePhoto()
//        }, label: {
//            Circle()
//                .foregroundColor(.white)
//                .frame(width: 80, height: 80, alignment: .center)
//                .overlay(
//                    Circle()
//                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
//                        .frame(width: 65, height: 65, alignment: .center)
//                )
//        })
//    }
//
//    var capturedPhotoThumbnail: some View {
//        Group {
//            if model.photo != nil {
//                Image(uiImage: model.photo.image!)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 60, height: 60)
//                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                    .animation(.spring())
//
//            } else {
//                RoundedRectangle(cornerRadius: 10)
//                    .frame(width: 60, height: 60, alignment: .center)
//                    .foregroundColor(.black)
//            }
//        }
//    }
//
//    var flipCameraButton: some View {
//        Button(action: {
//            model.flipCamera()
//        }, label: {
//            Circle()
//                .foregroundColor(Color.gray.opacity(0.2))
//                .frame(width: 45, height: 45, alignment: .center)
//                .overlay(
//                    Image(systemName: "camera.rotate.fill")
//                        .foregroundColor(.white))
//        })
//    }
//
//    var body: some View {
//        GeometryReader { reader in
//            ZStack {
//                Color.black.edgesIgnoringSafeArea(.all)
//
//                VStack {
//                    Button(action: {
//                        model.switchFlash()
//                    }, label: {
//                        Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
//                            .font(.system(size: 20, weight: .medium, design: .default))
//                    })
//                    .accentColor(model.isFlashOn ? .yellow : .white)
//
//                    CameraPreview(session: model.session)
//                        .gesture(
//                            DragGesture().onChanged({ (val) in
//                                //  Only accept vertical drag
//                                if abs(val.translation.height) > abs(val.translation.width) {
//                                    //  Get the percentage of vertical screen space covered by drag
//                                    let percentage: CGFloat = -(val.translation.height / reader.size.height)
//                                    //  Calculate new zoom factor
//                                    let calc = currentZoomFactor + percentage
//                                    //  Limit zoom factor to a maximum of 5x and a minimum of 1x
//                                    let zoomFactor: CGFloat = min(max(calc, 1), 5)
//                                    //  Store the newly calculated zoom factor
//                                    currentZoomFactor = zoomFactor
//                                    //  Sets the zoom factor to the capture device session
//                                    model.zoom(with: zoomFactor)
//                                }
//                            })
//                        )
//                        .onAppear {
//                            model.configure()
//                        }
//                        .alert(isPresented: $model.showAlertError, content: {
//                            Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
//                                model.alertError.primaryAction?()
//                            }))
//                        })
//                        .overlay(
//                            Group {
//                                if model.willCapturePhoto {
//                                    Color.black
//                                }
//                            }
//                        )
//                        .animation(.easeInOut)
//
//
//                    HStack {
//                        capturedPhotoThumbnail
//
//                        Spacer()
//
//                        captureButton
//
//                        Spacer()
//
//                        flipCameraButton
//
//                    }
//                    .padding(.horizontal, 20)
//                }
//            }
//        }
//    }
//}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
