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

extension String {
    static let appExtensions: String = "ptk"
    static let versionKey: String = "Version"
    static let photoKey: String = "Photo"
    static let thumbnailKey: String = "Thumbmail"
}

typealias PhotoEntry = (mainImage: UIImage?, thumbnailImage: UIImage?)

private extension String {
    static let dataKey: String = "Data"
    static let metadataFilename: String = "photo.metadata"
    static let dataFilename: String = "photo.data"
}

class Document: UIDocument {
    
    override var description: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }
    
    var fileWrapper: FileWrapper?
    
    lazy var photoData: PhotoData = {
        
        guard
          fileWrapper != nil,
          let data = decodeFromWrapper(for: .dataFilename) as? PhotoData
          else {
            return PhotoData()
        }

        return data}()
    
    lazy var metaData: PhotoMetaData = {
        guard
          fileWrapper != nil,
          let data = decodeFromWrapper(for: .metadataFilename) as? PhotoMetaData
          else {
            return PhotoMetaData()
        }
        return data
    }()
    
    var photo: PhotoEntry? {
        get {
            return PhotoEntry(mainImage:photoData.image, thumbnailImage: metaData.image)
        }
        set {
            photoData.image = newValue?.mainImage
            metaData.image = newValue?.thumbnailImage
        }
    }
    
    private func encodeToWrapper(object: NSCoding) -> FileWrapper {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.encode(object, forKey: .dataKey)
        archiver.finishEncoding()
        
        return FileWrapper(regularFileWithContents: archiver.encodedData)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        let metaDataWrapper = encodeToWrapper(object: metaData)
        let photoDataWrapper = encodeToWrapper(object: photoData)
        let wrappers: [String: FileWrapper] = [.metadataFilename: metaDataWrapper, .dataFilename: photoDataWrapper]
        
        return FileWrapper(directoryWithFileWrappers: wrappers)
    }
    
    override func load (fromContents contents: Any, ofType typeName: String?) throws  {
        guard let contents = contents as? FileWrapper else { return }
        fileWrapper = contents
    }
    
    func decodeFromWrapper(for name: String) -> Any? {
      guard
        let allWrappers = fileWrapper,
        let wrapper = allWrappers.fileWrappers?[name],
        let data = wrapper.regularFileContents
        else {
          return nil
        }
      
      do {
        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        return unarchiver.decodeObject(forKey: .dataKey)
      } catch let error {
        fatalError("Unarchiving failed. \(error.localizedDescription)")
      }
    }
}
