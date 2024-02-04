//
//  Note.swift
//  Notes
//
//  Created by Lol Kek on 31/01/2024.
//

import Foundation
import SwiftData

@Model
final class Note {
    var timestamp: Date
    var id: UUID
    var title: String
    var completed: Bool
    var attributedTextData: Data?

    init(timestamp: Date,
         id: UUID,
         title: String,
         completed: Bool,
         attributedTextData: Data?)
    {
        self.timestamp = timestamp
        self.id = id
        self.title = title
        self.completed = completed
        self.attributedTextData = attributedTextData
    }

    func setAttributedText(_ attributedText: NSMutableAttributedString) {
        do {
            self.attributedTextData = try attributedText.data(from: NSRange(location: 0,
                                                                            length: attributedText.length),
                                                              documentAttributes: [.documentType: NSMutableAttributedString.DocumentType.rtfd])
            let range = NSRange(location: 0, length: 15)
            let text = attributedText.attributedSubstring(from: range)
            if text.length > 0 {
          
                let str = text.string.replacingOccurrences(of: "  ", with: "")
                    .replacingOccurrences(of: "\n", with: "")
                
                self.title = str
            }
            
        } catch {
            print("Error encoding NSAttributedString: \(error)")
        }
    }

    func getAttributedText() -> NSMutableAttributedString? {
        guard let data = attributedTextData else {
            return nil
        }

        do {
            let attributedString = try NSMutableAttributedString(data: data,
                                                                 options: [.documentType: NSAttributedString.DocumentType.rtfd],
                                                                 documentAttributes: nil)
            return attributedString
        } catch {
            print("Error decoding NSAttributedString: \(error)")
            return nil
        }
    }
}
