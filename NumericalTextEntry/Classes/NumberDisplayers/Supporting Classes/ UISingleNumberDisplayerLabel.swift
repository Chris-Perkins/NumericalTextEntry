//
//  UIFittedTextAndConstrainedLabel.swift
//  NumericalTextField
//
//  Created by Christopher Perkins on 8/5/18.
//

/// A UIFittedTextLabel that also contain properties for the different constraints used by the
/// different numberDisplayers
internal class UISingleCharacterNumberDisplayerLabel: UILabel {
    /// An enum dictating the different types of number displayer labels.
    ///
    /// - groupingSeparator: This label represents a grouping separator
    /// - mantissa: This label represents a mantissa
    /// - integer: This label represents an integer
    public enum type {
        case groupingSeparator, mantissa, integer, genericNumeric, genericNonNumeric
    }
    
    /// The constraint for this label's right edge.
    public var rightEdgeConstraint: NSLayoutConstraint?
    
    /// The constraint for this label's top edge.
    public var topEdgeConstraint: NSLayoutConstraint?
    
    /// The constraint for this label's width.
    public var widthConstraint: NSLayoutConstraint?
    
    /// The constraint for this label's height.
    public var heightConstraint: NSLayoutConstraint?
    
    /// The type of label this is.
    public var labelType: type
    
    /// Whether or not this label is showing default text (text not yet filled in).
    public var isDefaultText: Bool
    
    /// Initializes a UISingleNumberDisplayerLabel with the provided input variables.
    ///
    /// - Parameters:
    ///   - isDecimal: Whether or not this label is representing a decimal
    ///   - isDefaultText: Whether or not this label is representing a value that is non-default
    public init(labelType: type, isDefaultText: Bool) {
        self.labelType = labelType
        self.isDefaultText = isDefaultText
        
        super.init(frame: .zero)
    }
    
    /// - Warning: Unimplemented; throws.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
