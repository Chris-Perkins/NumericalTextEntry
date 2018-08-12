//
//  NumberDisplayerUtils.swift
//  NumericalTextField
//
//  Created by Christopher Perkins on 8/4/18.
//

/// A Utils Class that holds methods used by the Number Displayers.
internal class NumberDisplayerUtils {
    /// Gets an attributed string where text that starts with the same strings receives one color,
    /// and that does not start the same in both receives a different color. Ignores the
    /// `numberFormatter`'s grouping separator and currency symbol when figuring out where the
    /// strings differ.
    ///
    /// - Parameters:
    ///   - displayedString: The string being displayed
    ///   - rawString: The raw string
    ///   - numberFormatter: The numberFormatter that will be used to retrieve grouping separator
    /// and currencySymbols from
    ///   - matchingTextColor: The color to assign for text that starts the same
    ///   - missingTextColor: The color to assign when text starts to differ
    ///   - font: The font to use for the attributed string
    /// - Returns: An attributed string where text that starts the same in the two input strings
    /// has the input `font` and `matchingTextColor` and text that differs receives the same
    /// input `font` and `missingTextColor`.
    internal static func getAttributedStringForStrings(displayedString: String, rawString: String?,
                                                       numberFormatter: NumberFormatter,
                                                       matchingTextColor: UIColor,
                                                       missingTextColor: UIColor,
                                                       font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        if let rawString = rawString,
            let differLocation = getFirstIndexWhereStringsDoNotMatch(
                displayedString: displayedString, rawValue: rawString, ignoredStrings:
                [numberFormatter.groupingSeparator, numberFormatter.currencySymbol]),
            differLocation < displayedString.count {
            
            let realStringDifferIndex = displayedString.index(displayedString.startIndex,
                                                              offsetBy: differLocation)
            let realStringFilledIn = String(displayedString[..<realStringDifferIndex])
            let realStringNotFilledIn =
                String(displayedString[realStringDifferIndex..<displayedString.endIndex])
            
            attributedString.stringWithFont(realStringFilledIn, font: font)
            attributedString.addAttribute(.foregroundColor, value: matchingTextColor,
                                          range: NSRange(location: 0, length: differLocation))
            attributedString.stringWithFont(realStringNotFilledIn, font: font)
            attributedString.addAttribute(.foregroundColor,
                                          value: missingTextColor,
                                          range: NSRange(location:differLocation,
                                                         length:displayedString.count
                                                            - differLocation))
        } else {
            attributedString.stringWithFont(displayedString, font: font)
        }
        
        return attributedString
    }
    
    /// Finds the first index where the strings differed. Order of input of the strings does not
    /// matter.
    ///
    /// - Parameters:
    ///   - displayedString: input; ignore ignoredCharacters
    ///   - otherString: input
    ///   - ignoredCharacters: Strings that should be ignored in the displayedString
    /// - Returns: The first index where the strings differed
    internal static func getFirstIndexWhereStringsDoNotMatch(displayedString: String,
                                                             rawValue: String,
                                                             ignoredStrings: [String?]) -> Int? {
        var currentRawValueIndex = 0
        var currentDisplayedIndex = 0
        
        while currentDisplayedIndex < displayedString.count {
            // Start out by determining if we're checking an ignored string; if we are, skip it.
            let currentDisplayedStringIndex =
                displayedString.index(displayedString.startIndex,
                                      offsetBy: currentDisplayedIndex)
            let displayedStringSuffixAfterIndex =
                displayedString[currentDisplayedStringIndex..<displayedString.endIndex]
            for ignoredString in ignoredStrings {
                if let ignoredString = ignoredString, !ignoredString.isEmpty
                    &&  displayedStringSuffixAfterIndex.hasPrefix(ignoredString) {
                    currentDisplayedIndex += ignoredString.count
                    continue
                }
            }
            
            // If we're out of bounds of the other string, this is where the difference occurred.
            if  rawValue.count <= currentRawValueIndex {
                return currentDisplayedIndex
            }
            
            // If the characters did not match, this is where they differed.
            let character1 = displayedString[displayedString.index(displayedString.startIndex,
                                                                   offsetBy: currentDisplayedIndex)]
            let character2 = rawValue[rawValue.index(rawValue.startIndex,
                                                     offsetBy: currentRawValueIndex)]
            if character1 != character2 {
                return currentDisplayedIndex
            }
            
            currentDisplayedIndex += 1
            currentRawValueIndex += 1
        }
        
        // If the displayedString is shorter than the rawValue, then the last index is where they
        // differed.
        if displayedString.count < rawValue.count {
            return displayedString.count
        }
        
        // The strings did not differ.
        return nil
    }
}
