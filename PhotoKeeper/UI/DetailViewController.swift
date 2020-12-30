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
import Photos
import AssetsLibrary

protocol DetailViewControllerDelegate: class {
  func detailViewControllerDidFinish(_ viewController: DetailViewController, with photoEntry: PhotoEntry?, title: String?)
}

class DetailViewController: UIViewController {
  weak var delegate: DetailViewControllerDelegate?
  var document: Document? {
    didSet {
      guard let doc = document else { return }
      title = doc.description
    }
  }
  
  @IBOutlet weak var addPhotoButton: UIButton!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var fullImageView: UIImageView!
  
  private var newImage: UIImage?
  private var newThumbnailImage: UIImage?
  private var hasChanges = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if PHPhotoLibrary.authorizationStatus() == .notDetermined  {
      PHPhotoLibrary.requestAuthorization { _ in }
    }
    
    openDocument()
  }
  
  private func showImagePicker() {
    let imagePicker = UIImagePickerController()
    guard UIImagePickerController.isSourceTypeAvailable(imagePicker.sourceType) else { return }
    
    imagePicker.sourceType = .photoLibrary
    imagePicker.allowsEditing = false
    imagePicker.delegate = self
    
    present(imagePicker, animated: true, completion: nil)
  }
  
  private func openDocument() {
  }
  
  @IBAction func editPhoto(_ sender: Any) {
    showImagePicker()
  }
  
  @IBAction func donePressed(_ sender: Any) {
  }
  
  @IBAction func dismiss(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
    fullImageView.image = image
    picker.dismiss(animated: true, completion: nil)
  }
  
  @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}

extension DetailViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
