//
//  CustomAccessoryView.swift
//  Notes
//
//  Created by Lol Kek on 02/02/2024.
//
import UIKit

enum FontStyle {
    case bold,
         italic,
         regular,
         stillCurrent
}

enum FontSize: CGFloat {
    case regular = 17.0
    case large = 24.0
    case stillCurrent = 0.0
}

protocol CustomInputAccessoryViewDelegate: AnyObject {
    func boldButtonTapped()
    func italicButtonTapped()
    func fontButtonTapped(currentSize: FontSize)
    func colorButtonTapped(currentColor: UIColor)
    func imageButtonTapped()
}

class CustomInputAccessoryView: UIView {
    weak var delegate: CustomInputAccessoryViewDelegate?
    private var selectedColor: UIColor = .black
    private var selectedFontSize: FontSize = .regular

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func updateToolbar(typingAttributes: [NSAttributedString.Key: Any]) {
        for attribute in typingAttributes {
            if attribute.key == .font {
                updateFontRelatedItems(attributeValue: attribute.value)
            }

            if attribute.key == .foregroundColor {
                updateColor(attributeValue: attribute.value)
            }
        }
    }

    // MARK: - Private

    private lazy var boldButton: UIButton = {
        let button = UIButton(type: .system)
        let boldImage = UIImage(systemName: "bold")
        button.setImage(boldImage, for: .normal)
        button.addTarget(self, action: #selector(boldButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var italicButton: UIButton = {
        let button = UIButton(type: .system)
        let regularImage = UIImage(systemName: "italic")
        button.setImage(regularImage, for: .normal)
        button.addTarget(self, action: #selector(italicButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var colorButton: UIButton = {
        let button = UIButton(type: .system)
        var colorImage = UIImage(systemName: "circle.fill")
        button.setImage(colorImage, for: .normal)
        button.tintColor = selectedColor
        button.addTarget(self, action: #selector(colorButtonTapped(currentColor:)), for: .touchUpInside)
        return button
    }()

    private lazy var fontSizeButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "\(FontSize.regular.rawValue)"
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle(title, for: .normal)
        button.tintColor = selectedColor
        button.addTarget(self, action: #selector(fontSizeButtonTapped(currentSize:)),
                         for: .touchUpInside)
        return button
    }()

    private lazy var imageButton: UIButton = {
        let button = UIButton(type: .system)
        var colorImage = UIImage(systemName: "photo.on.rectangle.angled")
        button.setImage(colorImage, for: .normal)
        button.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        return button
    }()

    private func setupView() {
        backgroundColor = .lightGray
        addSubview(boldButton)
        addSubview(italicButton)
        addSubview(colorButton)
        addSubview(fontSizeButton)
        addSubview(imageButton)

        boldButton.translatesAutoresizingMaskIntoConstraints = false
        italicButton.translatesAutoresizingMaskIntoConstraints = false
        colorButton.translatesAutoresizingMaskIntoConstraints = false
        fontSizeButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.translatesAutoresizingMaskIntoConstraints = false

        let buttonWidth: CGFloat = 44

        NSLayoutConstraint.activate([
            boldButton.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                constant: 8),
            boldButton.topAnchor.constraint(equalTo: topAnchor,
                                            constant: 2),
            boldButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            boldButton.heightAnchor.constraint(equalToConstant: buttonWidth),

            italicButton.leadingAnchor.constraint(equalTo: boldButton.trailingAnchor,
                                                  constant: 8),
            italicButton.topAnchor.constraint(equalTo: topAnchor,
                                              constant: 2),
            italicButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            italicButton.heightAnchor.constraint(equalToConstant: buttonWidth),

            colorButton.leadingAnchor.constraint(equalTo: italicButton.trailingAnchor,
                                                 constant: 8),
            colorButton.topAnchor.constraint(equalTo: topAnchor,
                                             constant: 2),
            colorButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            colorButton.heightAnchor.constraint(equalToConstant: buttonWidth),

            fontSizeButton.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor,
                                                    constant: 8),
            fontSizeButton.topAnchor.constraint(equalTo: topAnchor,
                                                constant: 2),
            fontSizeButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            fontSizeButton.heightAnchor.constraint(equalToConstant: buttonWidth),

            imageButton.leadingAnchor.constraint(equalTo: fontSizeButton.trailingAnchor,
                                                 constant: 8),
            imageButton.topAnchor.constraint(equalTo: topAnchor,
                                             constant: 2),
            imageButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            imageButton.heightAnchor.constraint(equalToConstant: buttonWidth),
        ])
    }

    private func updateColor(attributeValue: Any) {
        guard let currentTextColor = attributeValue as? UIColor else {
            return
        }
        colorButton.tintColor = currentTextColor
        selectedColor = currentTextColor
    }

    @objc private func boldButtonTapped() {
        delegate?.boldButtonTapped()
    }

    @objc private func italicButtonTapped() {
        delegate?.italicButtonTapped()
    }

    @objc private func colorButtonTapped(currentColor: UIColor) {
        delegate?.colorButtonTapped(currentColor: selectedColor)
    }

    @objc private func fontSizeButtonTapped(currentSize: CGFloat) {
        selectedFontSize = selectedFontSize == .large ? .regular : .large
        let title = "\(selectedFontSize.rawValue)"
        fontSizeButton.setTitle(title, for: .normal)
        delegate?.fontButtonTapped(currentSize: selectedFontSize)
    }

    @objc private func imageButtonTapped() {
        delegate?.imageButtonTapped()
    }

    private func updateFontRelatedItems(attributeValue: Any) {
        if attributeValue is UIFont {
            let fontSize = CTFontGetSize(attributeValue as! CTFont)
            let fontTraits = CTFontGetSymbolicTraits(attributeValue as! CTFont)
            let title = "\(fontSize)"
            fontSizeButton.setTitle(title, for: .normal)
            let isBold = fontTraits.contains(.traitBold)
            let isItalic = fontTraits.contains(.traitItalic)
            setSelected(boldButton, isSelected: isBold)
            setSelected(italicButton, isSelected: isItalic)

        } else {
            setSelected(boldButton, isSelected: false)
            setSelected(italicButton, isSelected: false)
        }
    }

    private func setSelected(_ button: UIButton, isSelected: Bool) {
        button.layer.cornerRadius = isSelected ? 15 : 0
        button.layer.backgroundColor = isSelected ? UIColor.white.cgColor : UIColor.clear.cgColor
        button.layer.masksToBounds = true
    }
}
