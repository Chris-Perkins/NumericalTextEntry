//
//  FittedStringDisplayer.swift
//  NumericalTextField
//
//  Created by Christopher Perkins on 8/3/18.
//
// Most heavy-work found in this library: https://github.com/tbaranes/FittableFontLabel
// Adapted to cause the maximum size to be bounded by height as well.

/// An enum just to make binary search operations more readable.
fileprivate enum FontSizeState {
    case fit, tooBig, tooSmall
}

/// A FittedStringDisplayer; a fake abstract class. Abstract methods implemented in the extension
/// below.
protocol FittedStringDisplayer {
}

extension FittedStringDisplayer {
    /// The maximum error that should be had when the font size is retrieved.
    private static var fontSizeMaxError: CGFloat {
        return 0.1
    }
    
    /// Returns a font size that fits in the provided maxSize. Uses binary search to find the
    /// correct font size with a maximum size error of 0.1.
    ///
    /// - Parameters:
    ///   - string: The string to find the maximum font size for
    ///   - font: The font to find to find the maximum size for
    ///   - minFontSize: The minimum font size to retrieve
    ///   - maxFontSize: The maximum font size to retrieve
    ///   - maxSize: The maximum size of the rectangle to fill
    /// - Returns: The font size that fits in the provided rectangle
    public func getSizeToFit(stringsWithWeights: [(String, CGFloat)], font: UIFont,
                             minFontSize: CGFloat = 0.1, maxFontSize: CGFloat = 1_000_000,
                             maxSize: CGSize) -> CGFloat {
        let fontSize = (minFontSize + maxFontSize) / 2
        // if the search range is smaller than 0.1 of a font size we stop
        // returning either side of min or max depending on the state
        guard maxFontSize - minFontSize > 0.1 else {
            return fontSize
        }
        
        // Will hold the total size of the strings with the given weights for the current font size.
        var totalStringSizeWithFont = CGSize.zero
        for stringAndWeightTuple in stringsWithWeights {
            let string = stringAndWeightTuple.0
            let weight = stringAndWeightTuple.1
            
            if weight < 0 {
                fatalError("A string's size in weight cannot be less than 0.")
            }
            
            let stringSizeWithFont =
                string.size(withAttributes: [NSAttributedStringKey.font
                    : font.withSize(fontSize * weight)])
            
            totalStringSizeWithFont =
                CGSize(width: totalStringSizeWithFont.width + stringSizeWithFont.width,
                       height: max(totalStringSizeWithFont.height, stringSizeWithFont.height))
        }
        
        switch getSizeState(stringSize: totalStringSizeWithFont, actualSize: maxSize) {
        case .fit:
            return fontSize
        case .tooBig:
            return getSizeToFit(stringsWithWeights: stringsWithWeights, font: font,
                                minFontSize: minFontSize, maxFontSize: fontSize, maxSize: maxSize)
        case .tooSmall:
            return getSizeToFit(stringsWithWeights: stringsWithWeights, font: font,
                                minFontSize: fontSize, maxFontSize: maxFontSize, maxSize: maxSize)
        }
    }
    
    /// Retrieves the state of the stringSize vs actualSize rect.
    ///
    /// - Parameters:
    ///   - stringSize: The size of the rect for the string
    ///   - actualSize: The actual size of the rectangle
    /// - Returns: .tooBig if the stringSize rect is greater than the actualSize rect
    /// .fit if the absolute difference between the string rect and actual rect is < 0.1
    /// .tooSmall otherwise
    private func getSizeState(stringSize: CGSize, actualSize: CGSize) -> FontSizeState {
        if stringSize.width > actualSize.width || stringSize.height > actualSize.height {
            return .tooBig
        } else if abs(stringSize.width - actualSize.width) < Self.fontSizeMaxError
            || abs(stringSize.height - actualSize.height) < Self.fontSizeMaxError {
            return .fit
        } else {
            return .tooSmall
        }
    }
}
