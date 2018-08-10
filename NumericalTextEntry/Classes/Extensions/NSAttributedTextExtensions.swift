//
//  NSAttributedTextExtensions.swift
//  NumericalTextField
//
//  Created by Christopher Perkins on 8/3/18.
//

extension NSMutableAttributedString {
    /// Creates an attributed string with the provided font.
    ///
    /// - Parameters:
    ///   - text: The text of the attributed string.
    ///   - font: The font of the attributed string.
    /// - Returns: The Attributed String that was created.
    @discardableResult
    func stringWithFont(_ text: String, font: UIFont) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: font]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    /// Sets the font size for the entirety.
    ///
    /// - Parameters:
    ///   - font: The font to set for all of self
    func setFontFace(font: UIFont) {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) {
            (value, range, stop) in
            if let f = value as? UIFont, let newFontDescriptor =
                f.fontDescriptor.withFamily(font.familyName)
                .withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
            }
        }
        endEditing()
    }
}
