//
//  TextData.swift
//  PhotoKeeperDocument
//
//  Created by Lea Marolt Sonnenschein on 6/17/19.
//  Copyright © 2019 Elemes. All rights reserved.
//

import Foundation

private extension String {
    static let titleKey: String = "Title"
    static let noteKey: String = "Note"
}

class TextData: NSObject, NSCoding {
    
    var title: String?
    var note: String?
    
    init(title: String? = nil, note: String? = nil) {
        self.title = title
        self.note = note
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encodeCInt(1, forKey: .versionKey)
        guard let title = title, let note = note else { return }
        
        aCoder.encode(title, forKey: .titleKey)
        aCoder.encode(note, forKey: .noteKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        aDecoder.decodeCInt(forKey: .versionKey)
        
        guard let cTitle = aDecoder.decodeObject(forKey: .titleKey) as? String, let cNote = aDecoder.decodeObject(forKey: .noteKey) as? String else { return }
        
        title = cTitle
        note = cNote
    }
    
    
}
