/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

extension UIImage {
  static var `default`: UIImage {
    return #imageLiteral(resourceName: "default")
  }
  
  func imageWith(newSize: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let image = renderer.image {_ in
      draw(in: CGRect(origin: .zero, size: newSize))
    }
    
    return image
  }
  
  func imageByBestFit(for targetSize: CGSize) -> UIImage {
    let aspectRatio = size.width / size.height
    let targetHeight = targetSize.height
    let scaledWidth = targetSize.height * aspectRatio
    
    let bestSize = CGSize(width: scaledWidth, height: targetHeight)
    return imageWith(newSize: bestSize)
  }
  
}

extension Optional where Wrapped == UIImage {
  func isSame(photo: UIImage?) -> Bool {
    switch (self, photo) {
    case (nil, nil):
      return true
    case (nil, _), (_, nil):
      return false
    case (let p1, let p2):
      return p1!.isEqual(p2)
    }
  }
}
