//
//  EditNoteView.swift
//  Notes
//
//  Created by Lol Kek on 02/02/2024.
//

import SwiftUI

final class Coordinator: NSObject, UINavigationControllerDelegate {
    var parent: CustomTextEditor
    var fontName: String
    
    fileprivate var isBold = false
    fileprivate var isItalic = false
    
    init(_ parent: CustomTextEditor) {
        self.parent = parent
        self.fontName = parent.defaultFontName
    }
}

struct CustomTextEditor: UIViewControllerRepresentable {
    @Binding fileprivate var attributedText: NSMutableAttributedString
    
    fileprivate var controller: UIViewController
    fileprivate var textView: UITextView
    fileprivate var accessoryView: CustomInputAccessoryView
    
    fileprivate let placeholder: String
    fileprivate let placeholderColor = UIColor.placeholderText
    fileprivate let defaultFontName = UIFont.systemFont(ofSize: 17.0).fontName
    
    init(attributedText: Binding<NSMutableAttributedString>, placeholder: String) {
        self._attributedText = attributedText
        self.controller = UIViewController()
        self.textView = UITextView()
        self.placeholder = placeholder
        self.accessoryView = CustomInputAccessoryView()
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        setUpTextView()
        textView.delegate = context.coordinator
        textView.delegate?.textViewDidChange!(textView)
        textView.font = UIFont.systemFont(ofSize: FontSize.regular.rawValue)
        accessoryView.delegate = context.coordinator
        textView.inputAccessoryView = accessoryView
    
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        accessoryView.frame = CGRect(x: 0, y: -uiViewController.view.safeAreaInsets.bottom, width: 0, height: 48 + uiViewController.view.safeAreaInsets.bottom)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func setUpTextView() {
        textView.attributedText = attributedText
        
        controller.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.centerYAnchor),
            textView.widthAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.widthAnchor),
            textView.heightAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.heightAnchor),
        ])
    }
}

// MARK: - UITextViewDelegate

extension Coordinator: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        let textRange = parent.textView.selectedRange
        
        if textRange.length == 0 {
            parent.accessoryView.updateToolbar(typingAttributes: parent.textView.typingAttributes)
        } else {
            parent.accessoryView.updateToolbar(typingAttributes: getAttributesForSelection)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        parent.attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        parent.attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        if textView.selectedRange.length > 0 {
            textView.scrollRangeToVisible(textView.selectedRange)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension Coordinator: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        guard let delegate = parent.textView.delegate,
              let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        else {
            return
        }

        delegate.textViewDidBeginEditing?(parent.textView)
        let newString = NSMutableAttributedString(attributedString: parent.textView.attributedText)

        let maxWidth = min(parent.textView.frame.size.width, parent.textView.frame.size.height)
        if let scaledImage = img.scaledTo(maxWidth: maxWidth, maxHeight: maxWidth) {
            let textAttachment = NSTextAttachment(image: scaledImage)
            let attachmentString = NSAttributedString(attachment: textAttachment)
            newString.append(attachmentString)
            parent.textView.attributedText = newString
            delegate.textViewDidChange?(parent.textView)
        }

        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CustomInputAccessoryViewDelegate

extension Coordinator: CustomInputAccessoryViewDelegate {
    func boldButtonTapped() {
        changeFontAttributes(fontStyle: .bold,
                             fontSize: .stillCurrent)
    }
    
    func italicButtonTapped() {
        changeFontAttributes(fontStyle: .italic,
                             fontSize: .stillCurrent)
    }
    
    func colorButtonTapped(currentColor: UIColor) {
        showColorPicker(currentColor: currentColor)
    }
    
    func imageButtonTapped() {
        showImagePicker()
    }
    
    func fontButtonTapped(currentSize: FontSize) {
        changeFontAttributes(fontStyle: .stillCurrent,
                             fontSize: currentSize)
    }
    
    func changeFontAttributes(fontStyle: FontStyle, fontSize: FontSize) {
        let attributes = parent.textView.selectedRange.length == 0
            ? parent.textView.typingAttributes : getAttributesForSelection
        
        let realFontSize = getFontSize(attributes: attributes)
        let defaultFontSize = fontSize == .stillCurrent ? realFontSize : fontSize.rawValue
        let currentFontWeight = getFontWeight(attributes: attributes)
        var font: UIFont? = getFontForWeight(weight: fontStyle, size: defaultFontSize)
        if font == nil {
            font = getFontForWeight(weight: currentFontWeight, size: defaultFontSize)
        }
    
        let defaultFont = UIFont.systemFont(ofSize: fontSize.rawValue)
        applyTextAttributes(type: UIFont.self,
                            key: .font,
                            value: font ?? UIFont.systemFont(ofSize: defaultFontSize),
                            defaultValue: defaultFont)
    }
    
    func getFontForWeight(weight: FontStyle, size: CGFloat) -> UIFont? {
        var font: UIFont? = nil
        switch weight {
        case .regular:
            font = UIFont.systemFont(ofSize: size)
        case .bold:
            font = UIFont.boldSystemFont(ofSize: size)
        case .italic:
            font = UIFont.italicSystemFont(ofSize: size)
        default:
            break
        }
        return font
    }
    
    private var getAttributesForSelection: [NSAttributedString.Key: Any] {
        let textRange = parent.textView.selectedRange
        guard textRange.length > 0, let attributedText = parent.textView.attributedText else {
            return [:]
        }
        
        var textAttributes: [NSAttributedString.Key: Any] = [:]
        attributedText.enumerateAttributes(in: textRange) { attributes, _, _ in
            for (key, value) in attributes {
                textAttributes[key] = value
            }
        }
        return textAttributes
    }
    
    private func getFontSize(attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        if let value = attributes[.font] as? UIFont {
            return value.pointSize
        } else {
            return FontSize.regular.rawValue
        }
    }
    
    private func getFontWeight(attributes: [NSAttributedString.Key: Any]) -> FontStyle {
        if let value = attributes[.font] as? UIFont {
            let fontTraits = CTFontGetSymbolicTraits(value as CTFont)
            let isBold = fontTraits.contains(.traitBold)
            let isItalic = fontTraits.contains(.traitItalic)
            if isBold {
                return FontStyle.bold
            } else if isItalic {
                return FontStyle.italic
            } else {
                return FontStyle.regular
            }
        }
        return FontStyle.stillCurrent
    }
    
    private func applyTextAttributes<T: Equatable>(type: T.Type,
                                                   key: NSAttributedString.Key,
                                                   value: Any, defaultValue: T)
    {
        let range = parent.textView.selectedRange
        if range.length != 0 {
            let isContain = doesContainAttribute(type: type, inRange: range, forKey: key, withValue: value)
            let mutableString = NSMutableAttributedString(attributedString: parent.textView.attributedText)
            if isContain {
                mutableString.removeAttribute(key, range: range)
                if key == .font {
                    mutableString.addAttributes([key: defaultValue], range: range)
                }
            } else {
                mutableString.addAttributes([key: value], range: range)
            }
            parent.textView.attributedText = mutableString
        } else {
            if let current = parent.textView.typingAttributes[key], current as! T == value as! T {
                parent.textView.typingAttributes[key] = defaultValue
            } else {
                parent.textView.typingAttributes[key] = value
            }
            parent.accessoryView.updateToolbar(typingAttributes: parent.textView.typingAttributes)
        }
    }
    
    private func doesContainAttribute<T: Equatable>(type: T.Type,
                                                    inRange range: NSRange,
                                                    forKey key: NSAttributedString.Key,
                                                    withValue value: Any) -> Bool
    {
        var isContain = false
        parent.textView.attributedText.enumerateAttributes(in: range, options: []) { attributes, _, _ in
            if let attributeValue = attributes[key] as? T, attributeValue == (value as? T) {
                isContain = true
            }
        }
        return isContain
    }
}

extension Coordinator: UIColorPickerViewControllerDelegate {
    func showImagePicker() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        parent.controller.present(imagePicker, animated: true, completion: nil)
    }

    func changeColorAttributes(color: UIColor) {
        applyTextAttributes(type: UIColor.self,
                            key: .foregroundColor,
                            value: color,
                            defaultValue: color)
    }
    
    func showColorPicker(currentColor: UIColor) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = currentColor
        picker.delegate = self
        parent.controller.present(picker, animated: true, completion: nil)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        viewController.dismiss(animated: true, completion: { [weak self] in
            if let range = self?.parent.textView.selectedRange, range.length > 0 {
                self?.parent.textView.scrollRangeToVisible(range)
            }
        })
    }
       
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        changeColorAttributes(color: viewController.selectedColor)
    }
}
