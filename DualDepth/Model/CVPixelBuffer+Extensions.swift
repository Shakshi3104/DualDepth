//
//  CVPixelBuffer+Extensions.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/26.
//

import Foundation
import CoreVideo
import CoreImage
import UIKit

extension CVPixelBuffer {
    // convert CVPixelBuffer to UIImage
    var uiImage: UIImage? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
        guard let image = cgImage else { return nil }
        let uiImage = UIImage(cgImage: image, scale: 0, orientation: .right)
        return uiImage
    }
    
    // normalize CVPixelBuffer
    /// https://www.raywenderlich.com/8246240-image-depth-maps-tutorial-for-ios-getting-started
    func normalize() -> CVPixelBuffer {
        let cvPixelBuffer = self
        
        let width = CVPixelBufferGetWidth(cvPixelBuffer)
        let height = CVPixelBufferGetHeight(cvPixelBuffer)
        
        CVPixelBufferLockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(cvPixelBuffer), to: UnsafeMutablePointer<Float>.self)
        
        var minPixel: Float = 1.0
        var maxPixel: Float = 0.0
        
        for y in stride(from: 0, to: height, by: 1) {
          for x in stride(from: 0, to: width, by: 1) {
            let pixel = floatBuffer[y * width + x]
            minPixel = min(pixel, minPixel)
            maxPixel = max(pixel, maxPixel)
          }
        }
        
        let range = maxPixel - minPixel
        for y in stride(from: 0, to: height, by: 1) {
          for x in stride(from: 0, to: width, by: 1) {
            let pixel = floatBuffer[y * width + x]
            floatBuffer[y * width + x] = (pixel - minPixel) / range
          }
        }
        
        CVPixelBufferUnlockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return cvPixelBuffer
    }
    
    // convert CVPixelBuffer to Array
    var array: Array<Array<Float32>> {
        let cvPixelBuffer = self
        
        CVPixelBufferLockBaseAddress(cvPixelBuffer, .readOnly)
        
        let base = CVPixelBufferGetBaseAddress(cvPixelBuffer)
        let width = CVPixelBufferGetWidth(cvPixelBuffer)
        let height = CVPixelBufferGetHeight(cvPixelBuffer)
        
        let bindPointer = base?.bindMemory(to: Float32.self, capacity: width * height)
        let bufPointer = UnsafeBufferPointer(start: bindPointer, count: width * height)
        let array = Array(bufPointer)
        
        CVPixelBufferUnlockBaseAddress(cvPixelBuffer, .readOnly)
        
        let fixedArray = array.map({ $0.isNaN ? 0 : $0 })
        let reshapedArray = reshape(from: fixedArray, width: width, height: height)
        return reshapedArray
    }
}

// MARK: -

// reshape 1D array to 2D array, like numpy
// https://stackoverflow.com/questions/59823900/turn-1d-array-into-2d-array-in-swift
private func reshape(from array: [Float32], width: Int, height: Int) -> [[Float32]] {
    let mask = Array(repeating: Array(repeating: 0.0, count: width), count: height)
    var iter = array.makeIterator()
    let reshapedArray = mask.map { $0.compactMap { _ in iter.next() } }
    return reshapedArray
}
