//
//  UIImage+Scale.swift
//  Notes
//
//  Created by Lol Kek on 04/02/2024.
//

import UIKit

extension UIImage {
    func scaledTo(maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage? {
        let ratio = size.width / size.height
        let targetWidth: CGFloat
        let targetHeight: CGFloat
        
        if ratio >= 1 {
            targetWidth = maxWidth
            targetHeight = maxWidth / ratio
        } else {
            targetWidth = maxHeight * ratio
            targetHeight = maxHeight
        }
        
        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        
        UIGraphicsBeginImageContext(targetSize)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: targetSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
