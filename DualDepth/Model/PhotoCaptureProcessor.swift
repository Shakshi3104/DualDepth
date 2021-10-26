//
//  PhotoCaptureProcessor.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/26.
//

import Foundation
import Photos
import UIKit

class PhotoCaptureProcessor: NSObject {
    
    lazy var context = CIContext()

    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    
    private let willCapturePhotoAnimation: () -> Void
    
    private let completionHandler: (PhotoCaptureProcessor) -> Void
    
    private let photoProcessingHandler: (Bool) -> Void
    
    /// The actual captured photo's data
    var photoData: Data?
    
    /// The depth data map image
    var depthMapImage: UIImage?
    
    /// The depth data map array
    var depthMapArray: [[Float32]]?
    
    /// The maximum time lapse before telling UI to show a spinner
    private var maxPhotoProcessingTime: CMTime?
        
    // Init takes multiple closures to be called in each step of the photco capture process
    init(with requestedPhotoSettings: AVCapturePhotoSettings, willCapturePhotoAnimation: @escaping () -> Void, completionHandler: @escaping (PhotoCaptureProcessor) -> Void, photoProcessingHandler: @escaping (Bool) -> Void) {
        
        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.completionHandler = completionHandler
        self.photoProcessingHandler = photoProcessingHandler
    }
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    
    // This extension adopts AVCapturePhotoCaptureDelegate protocol methods.
    
    /// - Tag: WillBeginCapture
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        maxPhotoProcessingTime = resolvedSettings.photoProcessingTimeRange.start + resolvedSettings.photoProcessingTimeRange.duration
    }
    
    /// - Tag: WillCapturePhoto
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        DispatchQueue.main.async {
            self.willCapturePhotoAnimation()
        }
        
        guard let maxPhotoProcessingTime = maxPhotoProcessingTime else {
            return
        }
        
        // Show a spinner if processing time exceeds one second.
        let oneSecond = CMTime(seconds: 2, preferredTimescale: 1)
        if maxPhotoProcessingTime > oneSecond {
            DispatchQueue.main.async {
                self.photoProcessingHandler(true)
            }
        }
    }
    
    /// - Tag: DidFinishProcessingPhoto
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        DispatchQueue.main.async {
            self.photoProcessingHandler(false)
        }
        
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            // captured photo data
            photoData = photo.fileDataRepresentation()
            
            // depth data
            if let depthData = photo.depthData {
                print("📷: \(depthData.description)")
                
                // depth map image
                depthMapImage = convertDepthMapImage(from: depthData)
                // depth map array
                let array = convertDepthMapArray(from: depthData)
                // NOTE: 深度マップが取れていないとき、配列は空
                if array.count > 0 {
                    depthMapArray = array
                    print("📷 depth map: \(array.count)x\(array[0].count)")
                }
            }
        }
    }
    
    /// - Tag: DidFinishCapture
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            DispatchQueue.main.async {
                self.completionHandler(self)
            }
            return
        } else {
            guard let data  = photoData else {
                DispatchQueue.main.async {
                    self.completionHandler(self)
                }
                return
            }
            
            // save captured photo
            self.saveToPhotoLibrary(data)
            
            // save depth map as image
            if let uiImage = depthMapImage {
                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            }
            
            // save depth map as array
            if let array = depthMapArray {
                saveToFile(array)
            }
        }
    }
}

// MARK: - PhotoCaptureProcessor+Extensions
extension PhotoCaptureProcessor {
    
    // This extension summarize utilities for PhotoCaptureProcessor
    
    // MARK: - Save catured photo to photo libary
    // save capture to photo library
    func saveToPhotoLibrary(_ photoData: Data) {
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        self.completionHandler(self)
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.completionHandler(self)
                }
            }
        }
    }
    
    // MARK: - Convert AVDepthData
    // convert to AVDepthData (kCVPixelFormatType_DisparityFloat32)
    private func convertToFloat32(from depthData: AVDepthData) -> AVDepthData {
        var convertedDepthData: AVDepthData
        
        // Convert 16 bit floats up to 32 bit
        // https://stackoverflow.com/questions/55009162/filtering-depth-data-on-ios-12-appears-to-be-rotated
        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
            convertedDepthData = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        } else {
            convertedDepthData = depthData
        }
        
        return convertedDepthData
    }
    
    // convert AVDepthData to UIImage
    func convertDepthMapImage(from depthData: AVDepthData) -> UIImage? {
        let convertedDepthData = convertToFloat32(from: depthData)
        let normalizedDepthMap = convertedDepthData.depthDataMap.normalize()
        return normalizedDepthMap.uiImage
    }
    
    // convert AVDepthData to Array<Array<Float32>>
    func convertDepthMapArray(from depthData: AVDepthData) -> [[Float32]] {
        let convertedDepthData = convertToFloat32(from: depthData)
        let array = convertedDepthData.depthDataMap.array
        return array
    }
    
    // MARK: - Save array to CSV file
    var documentURL: NSURL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        return documentURL
    }
    
    var depthMapArrayURL: NSURL {
        let depthMapURL = documentURL.appendingPathComponent("DepthMap", isDirectory: true)
        if !FileManager.default.fileExists(atPath: depthMapURL!.path) {
            do {
                try FileManager.default.createDirectory(at: depthMapURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return depthMapURL! as NSURL
    }
    
    var dateFormat: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmssSSS"
        return format
    }
    
    func saveToFile(_ array: [[Float32]]) {
        // 2D array to CSV format
        // https://teratail.com/questions/107200
        let flatString = array.map { line in
            line.map { "\($0)" }.joined(separator: ",")
        }.joined(separator: "\n")
        
        let timestamp = dateFormat.string(from: Date())
        let filename = "depthmap_\(timestamp).csv"
        let fileURL = depthMapArrayURL.appendingPathComponent(filename)
        
        guard let filepath = fileURL?.path else {
            return
        }
        
        do {
            try flatString.write(toFile: filepath, atomically: true, encoding: .utf8)
        }
        catch let error as NSError {
            print("Failure to Write File\n\(error)")
        }
    }
}
