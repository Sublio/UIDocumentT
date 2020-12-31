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

private extension String {
  static let cellID = "PhotoKeeperCell"
}

class ViewController: UIViewController {
  private var selectedEntry: Entry?
  private var entries: [Entry] = []
  private lazy var localRoot: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
  private var selectedDocument: Document?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    refresh()
  }
  
  private func loadDoc(at fileURL: URL){
    if fileURL.absoluteString.range(of: ".DS_Store") != nil {
      return
    }
    let doc = Document(fileURL: fileURL)
    doc.open { (success) in
      guard success else { fatalError("Failed to open doc") }
    }
    
    let metadata = doc.metaData
    let fileURl = doc.fileURL
    let version = NSFileVersion.currentVersionOfItem(at: fileURL)
    
    doc.close { (success) in
      guard success else { fatalError("Failed to close doc")}
    }
    
    if let version = version {
      addOrUpdateEntry(for: fileURl, metadata: metadata, version: version)
    }
  }
  
  private func loadLocal(){
    guard let root = localRoot else { return }
    do {
      let localDocs = try FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil, options: [])
      
      for localDoc in localDocs {
        loadDoc(at: localDoc)
      }
    }catch let error{
      fatalError("Couldn't load local content. \(error.localizedDescription)")
    }
  }
  
  private func refresh(){
    loadLocal()
    tableView.reloadData()
  }
  
  private func getDocumentURL(for filename:String) -> URL? {
    return localRoot?.appendingPathComponent(filename, isDirectory:  false)
  }
  
  private func docNameExists(for docName: String) -> Bool {
    return !entries.filter{ $0.fileURL.lastPathComponent == docName }.isEmpty
  }
  
  private func indexOfEntry(for name: String) -> Int? {
    return entries.firstIndex(where: { $0.description == name })
  }
  
  
  @IBAction func addEntry(_ sender: Any) {
    insertNewDocument()
  }
  
  @IBAction func editEntries(_ sender: Any) {
    mode = mode.otherMode
  }
  
  private func delete(entry: Entry) {
    guard let entryIndex = indexOfEntry(for: entry.description) else {
      return
    }
    entries.remove(at: entryIndex)
    tableView.reloadData()
  }
  
  private func rename(_ entry: Entry, with name: String) {
  }
  
  private var mode: Mode = .viewing {
    didSet {
      switch mode {
      case .editing:
        tableView.setEditing(true, animated: true)
        leftBarButtonItem.title = "Done"
      case .viewing:
        tableView.setEditing(false, animated: true)
        leftBarButtonItem.title = "Edit"
      }
    }
  }
  
  private func getDocFileName(for prefix: String) -> String {
    var newDocName = String(format: "%@.%@", prefix, String.appExtensions)
    var docCount = 1
    while docNameExists(for: newDocName) {
      newDocName = String(format: "%@ %d. %@", prefix, docCount, String.appExtensions)
      docCount += 1
    }
    return newDocName
  }
  
  private func addOrUpdateEntry(for fileURL: URL, metadata:PhotoMetaData?, version: NSFileVersion) {
    if let index = indexOfEntry(for: fileURL.absoluteString) {
      let entry = entries[index]
      entry.metaData = metadata
      entry.version = version
    }else {
      let entry = Entry(fileUrl: fileURL, metadata: metadata, version: version)
      entries.append(entry)
    }
    entries = entries.sorted(by: >)
    tableView.reloadData()
  }
  
  private func insertNewDocument(with photoEntry: PhotoEntry? = nil, title: String? = nil) {
    // 1
    guard let fileURL = getDocumentURL(for: getDocFileName(for: title ?? .photoKey)) else { return }
    
    //2
    
    let doc = Document(fileURL: fileURL)
    doc.photo = photoEntry
    
    // 3
    doc.save(to: fileURL, for: .forCreating) { [weak self](success) in
      guard success else { fatalError("Failed to create file")}
    }
    
    print("File created at: \(fileURL)")
    
    let metadata = doc.metaData
    let url = doc.fileURL
    
    if let version = NSFileVersion.currentVersionOfItem(at: fileURL){
      self.addOrUpdateEntry(for: url, metadata: metadata, version: version)
    }
  }
  
  private func showDetailVC(){
    if let detailVC = storyboard!.instantiateViewController(identifier: "DetailViewControllerID") as? DetailViewController{
      detailVC.delegate = self
      detailVC.document = selectedDocument
      mode = .viewing
      present(detailVC, animated: true, completion: nil)
    }
  }
}

//MARK: DetailViewControllerDelegate
extension ViewController: DetailViewControllerDelegate {
  func detailViewControllerDidFinish(_ viewController: DetailViewController, with photoEntry: PhotoEntry?, title: String?) {
  }
}

//MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let entry = entries[indexPath.row]
      delete(entry: entry)
    }
  }
}

//MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return entries.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: .cellID, for: indexPath) as? PhotoKeeperCell else { return UITableViewCell() }
    
    let entry = entries[indexPath.row]
    cell.titleTextField?.text = entry.description
    cell.photoImageView?.image = entry.metaData?.image
    cell.subtitleLabel?.text = entry.version.modificationDate?.mediumString
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let enrty = entries[indexPath.row]
    selectedEntry = enrty
    selectedDocument = Document(fileURL: enrty.fileURL)
    showDetailVC()
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

//MARK: UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    mode = .viewing
    
    guard
      let entry = selectedEntry,
      let newName = textField.text
      else {
        return true
    }
    
    rename(entry, with: newName)
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    let filteredEntries = entries.filter { (entry) -> Bool in
      return entry.description == textField.text
    }
    
    guard let entry = filteredEntries.first else { return }
    
    selectedEntry = entry
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    textField.resignFirstResponder()
  }
}

////MARK: Additional Conveniences
//extension ViewController {
//  private var detailVC: DetailViewController? {
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    let detailNavVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController")
//
////    guard
////      let navVC = detailNavVC as? UINavigationController,
////      let detailVC = navVC.topViewController as? DetailViewController
////      else {
////        return nil
////    }
//
//    return detailVC
//  }
//}

private enum Mode {
  case editing
  case viewing
  
  var otherMode: Mode {
    switch self {
    case .editing:
      return .viewing
    case .viewing:
      return .editing
    }
  }
}
