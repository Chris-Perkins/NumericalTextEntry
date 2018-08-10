//
//  UIFloatingDecimalNumberDisplayer.swift
//  NumericalTextField
//
//  Created by Christopher Perkins on 8/4/18.
//

/// A UINumberDisplayer that displays a number with the mantissa raised. All text is fitted.
open class UIFloatingDecimalNumberDisplayer: UINumberDisplayer {
    /// The amount of time it takes in seconds for the animation of a number scrub to complete.
    private static let animationTime: CFTimeInterval = 0.2
    
    /// The alpha that determines if something is hidden.
    private static let hiddenAlphaOpacity: CGFloat = 0
    
    /// The weight of integer strings when determining string total width/height.
    private static let integerStringWeight: CGFloat = 1.0
    
    /// The weight of mantissa strings when determining string total width/height.
    private static let mantissaStringWeight: CGFloat = 0.6
    
    /// The maximum number of parts in a valid decimal. 2 since there is before the decimal and
    /// after the decimal.
    private static let maximumPartsInValidDecimal = 2
    
    /// The height of the grouping separator fade height.
    private static let groupingSeparatorFadeHeightMultiplier: CGFloat = 1.0 / 4.0
    
    /// The height of the number fade height.
    private static let numberFadeHeightMultiplier: CGFloat = 1.0 / 2.0
    
    /// The index of the part preceding the decimal point in a string.
    private static let listIndexOfInteger = 0
    
    /// The index of the part following the decimal point in a string.
    private static let listIndexOfMantissa = 1
    
    /// The alpha component of faded colors.
    private static let fadedColorAlpha: CGFloat = 0.25
    
    /// Whether or not this view is animated.
    public var animated: Bool = true
    
    /// The font that the label should use.
    private let font: UIFont
    
    /// The text color of the label.
    private let textColor: UIColor
    
    /// The UISingleNumberDisplayer labels sorted in ascending order of their index
    private var numberLabelsWithIndex = [(UISingleCharacterNumberDisplayerLabel, Int)]()
    
    /// The GroupingSeparator labels sorted in ascending order of their index
    private var groupingSeparatorWithIndex = [(UISingleCharacterNumberDisplayerLabel, Int)]()
    
    /// Initializes this number displayer with the provided font and fontColor
    ///
    /// - Parameters:
    ///   - font: the font for the displayer
    ///   - fontColor: the color of the font for the displayer
    /* Note: font size of 12.0 does nothing; is overriden later. We only care about system font. */
    public init(withFont font: UIFont = UIFont.systemFont(ofSize: 12.0),
                withTextColor textColor: UIColor = UIColor.black) {
        self.font = font
        self.textColor = textColor
    }
    
    /// Displays the input value within a single UILabel that is generated by this method.
    /// Characters in both the `stringToDisplay` and the `rawValue` are bolded, and characters that
    /// are not in both are given an opacity of 0.25.
    ///
    /// - Parameters:
    ///   - stringToDisplay: The complete string to display.
    ///   - rawValue: The raw value of the string to display (not formatted)
    ///   - numberFormatter: The formatter used to generate the stringToDisplay.
    ///   - view: The view where the value should be displayed in
    /// - Returns: The views that were created to hold the displayed value.
    open func displayValue(_ stringToDisplay: String, withRawString rawString: String,
                           numberFormatter: NumberFormatter,
                           inView view: UIView) -> [UIView] {
        createLabels(stringToDisplay, withRawString: rawString, numberFormatter: numberFormatter,
                     inView: view)
        constrainNumberLabels(inView: view)
        
        var allLabels = [UIView]()
        allLabels.append(contentsOf: numberLabelsWithIndex.map({ (label, index) -> UIView in
            return label
        }))
        allLabels.append(contentsOf: groupingSeparatorWithIndex.map({ (label, index) -> UIView in
            return label
        }))
        
        return allLabels
    }
    
    /// Creates the labels that will be constrained later.
    ///
    /// - Parameters:
    ///   - stringToDisplay: The String to display
    ///   - rawString: The raw value of the string
    ///   - numberFormatter: The `NumberFormatter` used to create the stringToDisplay
    ///   - view: The view where the labels should be put inside
    private func createLabels(_ stringToDisplay: String, withRawString rawString: String,
                              numberFormatter: NumberFormatter, inView view: UIView) {
        // Gets the first index where the two strings differ; string length if no difference.
        let indexOfDiffering = NumberDisplayerUtils.getFirstIndexWhereStringsDoNotMatch(
            displayedString: stringToDisplay.replacingOccurrences(
                of: numberFormatter.decimalSeparator, with: ""),
            rawValue: rawString.replacingOccurrences(
                of: numberFormatter.decimalSeparator, with: ""),
            ignoredStrings: [numberFormatter.groupingSeparator]) ?? stringToDisplay.count
        
        let decimalComponents =
            stringToDisplay.components(separatedBy: numberFormatter.decimalSeparator)
        if decimalComponents.count > UIFloatingDecimalNumberDisplayer.maximumPartsInValidDecimal {
            fatalError("The input string was not a valid decimal.")
        }
        
        // Set up the fonts for when they're needed in the below for loops.
        let unweightedFontSize = getFontSizeForDecimalParts(decimalComponents, inView: view)
        let integerWeightedFont =
            font.withSize(unweightedFontSize * UIFloatingDecimalNumberDisplayer.integerStringWeight)
        let mantissaWeightedFont =
            font.withSize(unweightedFontSize * UIFloatingDecimalNumberDisplayer.mantissaStringWeight)
        
        /* Holds the current index that is being turned into a character; needed to determine
         if the string went into a default string and to get the current index in the displayed
         labels. */
        var currentParsedCharacterIndex = 0
        var currentNumberCount = 0
        var currentGroupingSeparatorCount = 0
        
        var remainingGroupingSeparatorLength = 0
        let integerString = decimalComponents[UIFloatingDecimalNumberDisplayer.listIndexOfInteger]
        while currentParsedCharacterIndex < integerString.count {
            let currentIntegerStringIndex = integerString.index(
                integerString.startIndex, offsetBy: currentParsedCharacterIndex)
            
            if remainingGroupingSeparatorLength == 0 {
                let displayedIntegerSuffixAfterIndex =
                    integerString[currentIntegerStringIndex..<integerString.endIndex]
                if displayedIntegerSuffixAfterIndex.hasPrefix(numberFormatter.groupingSeparator) {
                    remainingGroupingSeparatorLength = numberFormatter.groupingSeparator.count
                }
            }
            
            setupNumberLabel(withValue: integerString[currentIntegerStringIndex],
                             withFont: integerWeightedFont,
                             atListIndex: remainingGroupingSeparatorLength > 0
                                ? currentGroupingSeparatorCount : currentNumberCount,
                             isGroupingSeparator: remainingGroupingSeparatorLength > 0,
                             isDecimal: false,
                             isDefaultText: currentParsedCharacterIndex >= indexOfDiffering,
                             displayIndex: currentParsedCharacterIndex)
            
            if remainingGroupingSeparatorLength > 0 {
                remainingGroupingSeparatorLength -= 1
                currentGroupingSeparatorCount += 1
            } else {
                currentNumberCount += 1
            }
            currentParsedCharacterIndex += 1
        }
        
        // If we can create decimal labels, create them.
        if decimalComponents.count == UIFloatingDecimalNumberDisplayer.listIndexOfMantissa + 1 {
            let decimalString =
                decimalComponents[UIFloatingDecimalNumberDisplayer.listIndexOfMantissa]
            for character in decimalString {
                setupNumberLabel(withValue: character, withFont: mantissaWeightedFont,
                                 atListIndex: currentNumberCount,
                                 isGroupingSeparator: false, isDecimal: true,
                                 isDefaultText: currentParsedCharacterIndex >= indexOfDiffering,
                                 displayIndex: currentParsedCharacterIndex)
                
                currentNumberCount += 1
                currentParsedCharacterIndex += 1
            }
        }
        
        // If we have unused labels, we should remove them.
        if currentNumberCount <= numberLabelsWithIndex.count {
            for tuple in numberLabelsWithIndex[currentNumberCount..<numberLabelsWithIndex.count] {
                animateIfAnimatedThenRemoveFromSuperview(tuple.0)
            }
            numberLabelsWithIndex = Array(numberLabelsWithIndex[..<currentNumberCount])
        }
        if currentGroupingSeparatorCount <= groupingSeparatorWithIndex.count {
            for tuple in groupingSeparatorWithIndex[
                currentGroupingSeparatorCount..<groupingSeparatorWithIndex.count] {
                    animateIfAnimatedThenRemoveFromSuperview(tuple.0)
            }
            groupingSeparatorWithIndex =
                Array(groupingSeparatorWithIndex[..<currentGroupingSeparatorCount])
        }
    }
    
    /// Sets up a number label with the provided parameters. If a number label does not need to be
    /// created (in the case of an identical number label already existing at the provided index),
    /// then this does nothing. If a number label will be replaced, then the previous number label
    /// will scrub upwards to prepare for the new number label insertion.
    ///
    /// If this is default text, then the text will receive a slightly lucent text color.
    ///
    /// - Parameters:
    ///   - value: The value that the number label should have
    ///   - labelFont: The font that the number label should have
    ///   - listIndex: The index of insertion
    ///   - isDecimal: Whether or not this will represent a decimal label
    ///   - isDefaultText: Whether or not this is default text.
    private func setupNumberLabel(withValue value: Character, withFont labelFont: UIFont,
                                  atListIndex listIndex: Int, isGroupingSeparator: Bool,
                                  isDecimal: Bool, isDefaultText: Bool,
                                  displayIndex: Int) {
        let characterString = String(describing: value)
        
        if isGroupingSeparator && listIndex < groupingSeparatorWithIndex.count {
            let labelAtIndex = groupingSeparatorWithIndex[listIndex].0
            if labelAtIndex.text == characterString && labelAtIndex.isDefaultText == isDefaultText {
                // Do nothing; text matches, no change in this text; just update the font + index.
                labelAtIndex.font = labelFont
                groupingSeparatorWithIndex[listIndex].1 = displayIndex
                return
            }
            // If we reached this point, we're going to change or remove the label.
            animateIfAnimatedThenRemoveFromSuperview(labelAtIndex)
        } else if !isGroupingSeparator && listIndex < numberLabelsWithIndex.count {
            let labelAtIndex = numberLabelsWithIndex[listIndex].0
            if labelAtIndex.text == characterString && labelAtIndex.isDefaultText == isDefaultText
                && labelAtIndex.labelType == (isDecimal ? .mantissa : .integer) {
                // Do nothing; text matches, no change in this text; just update the font + index.
                labelAtIndex.font = labelFont
                numberLabelsWithIndex[listIndex].1 = displayIndex
                return
            }
            // If we reached this point, we're going to change or remove the label.
            animateIfAnimatedThenRemoveFromSuperview(labelAtIndex)
        }
        
        // If this point was reached, then it becomes clear that we must set up the new label.
        var newLabel: UISingleCharacterNumberDisplayerLabel!
        if isGroupingSeparator {
            newLabel = UISingleCharacterNumberDisplayerLabel(labelType: .groupingSeparator,
                                                    isDefaultText: isDefaultText)
        } else if isDecimal {
            newLabel = UISingleCharacterNumberDisplayerLabel(labelType: .mantissa,
                                                    isDefaultText: isDefaultText)
        } else {
            newLabel = UISingleCharacterNumberDisplayerLabel(labelType: .integer,
                                                    isDefaultText: isDefaultText)
        }
        
        newLabel.text = characterString
        newLabel.textColor = isDefaultText
            ? textColor.withAlphaComponent(UIFloatingDecimalNumberDisplayer.fadedColorAlpha)
            : textColor
        newLabel.font = labelFont
        
        if isGroupingSeparator {
            if listIndex < groupingSeparatorWithIndex.count {
                groupingSeparatorWithIndex[listIndex] = (newLabel, displayIndex)
            } else {
                groupingSeparatorWithIndex.append((newLabel, displayIndex))
            }
        } else {
            if listIndex < numberLabelsWithIndex.count {
                numberLabelsWithIndex[listIndex] = (newLabel, displayIndex)
            } else {
                numberLabelsWithIndex.append((newLabel, displayIndex))
            }
        }
    }
    
    /// If animations are enabled, this causes the input label to scrub upwards and fade out.
    /// After animations complete, the label calls `removeFromSuperview()`. If animations are not
    /// enabled, this will skip animations and immediately call `removeFromSuperview()`.
    ///
    /// - Parameter label: The label to animate then remove.
    private func animateIfAnimatedThenRemoveFromSuperview(_ label:
        UISingleCharacterNumberDisplayerLabel) {
        if animated {
            // If we reached this point, then the label will be removed. Scrub previous label up
            let originalFrame = label.frame
            label.removeConstraints()
            label.translatesAutoresizingMaskIntoConstraints = true
            UIView.animate(withDuration: UIFloatingDecimalNumberDisplayer.animationTime) {
                if label.labelType == .groupingSeparator {
                    label.frame = CGRect(x: originalFrame.minX,
                                         y: originalFrame.minY + label.frame.size.height
                                            * UIFloatingDecimalNumberDisplayer
                                                .groupingSeparatorFadeHeightMultiplier,
                                         width: originalFrame.size.width,
                                         height: originalFrame.size.height)
                } else {
                    label.frame = CGRect(x: originalFrame.minX,
                                         y: originalFrame.minY - label.frame.size.height
                                            * UIFloatingDecimalNumberDisplayer
                                                .numberFadeHeightMultiplier,
                                         width: originalFrame.size.width,
                                         height: originalFrame.size.height)
                }
                label.alpha = UIFloatingDecimalNumberDisplayer.hiddenAlphaOpacity
            }
            
            Timer.scheduledTimer(withTimeInterval: UIFloatingDecimalNumberDisplayer.animationTime,
                                 repeats: false) { (timer) in
                                    label.removeFromSuperview()
            }
        } else {
            label.removeFromSuperview()
        }
    }
    
    /// Constrains the currentDisplayedLabels within this view.
    ///
    /// - Parameter view: The view to constrain the labels inside.
    private func constrainNumberLabels(inView view: UIView) {
        var rightmostView = view
        var currentNumberLabelsTupleIndex = numberLabelsWithIndex.count - 1
        var currentGroupingSeparatorLabelsTupleIndex = groupingSeparatorWithIndex.count - 1
        
        while currentNumberLabelsTupleIndex >= 0 || currentGroupingSeparatorLabelsTupleIndex >= 0 {
            var labelToConstrain: UISingleCharacterNumberDisplayerLabel!
            if currentGroupingSeparatorLabelsTupleIndex < 0 {
                labelToConstrain = numberLabelsWithIndex[currentNumberLabelsTupleIndex].0
                currentNumberLabelsTupleIndex -= 1
            } else if currentNumberLabelsTupleIndex < 0 {
                labelToConstrain =
                    groupingSeparatorWithIndex[currentGroupingSeparatorLabelsTupleIndex].0
                currentGroupingSeparatorLabelsTupleIndex -= 1
            } else {
                let numberTuple = numberLabelsWithIndex[currentNumberLabelsTupleIndex]
                let groupingSeparatorTuple =
                    groupingSeparatorWithIndex[currentGroupingSeparatorLabelsTupleIndex]
                
                if numberTuple.1 > groupingSeparatorTuple.1 {
                    labelToConstrain = numberTuple.0
                    currentNumberLabelsTupleIndex -= 1
                } else {
                    labelToConstrain = groupingSeparatorTuple.0
                    currentGroupingSeparatorLabelsTupleIndex -= 1
                }
            }
            
            // Place the label in the correct position, attach constraints.
            if labelToConstrain.superview != view {
                labelToConstrain.removeFromSuperview()
                view.addSubview(labelToConstrain)
            } else {
                labelToConstrain.removeConstraints()
            }
            
            // Used to set the width of the number label
            let labelSize = labelToConstrain.text!.size(withAttributes:
                [NSAttributedStringKey.font : labelToConstrain.font])
            
            labelToConstrain.topEdgeConstraint = labelToConstrain.copy(.top, of: view)
            labelToConstrain.heightConstraint = labelToConstrain.copy(.height, of: view)
                .withMultiplier(labelToConstrain.labelType == .mantissa ?
                    UIFloatingDecimalNumberDisplayer.mantissaStringWeight
                        : UIFloatingDecimalNumberDisplayer.integerStringWeight)
            labelToConstrain.rightEdgeConstraint =
                labelToConstrain.cling(.right, to: rightmostView,
                                       rightmostView == view ? .right : .left)
            labelToConstrain.widthConstraint = labelToConstrain.setWidth(labelSize.width)
            
            rightmostView = labelToConstrain
        }
    }
}

extension UIFloatingDecimalNumberDisplayer: FittedStringDisplayer {
    /// Gets the font size given a list of decimal parts. Any string that is not of size 1 or 2
    /// will cause this function to throw a fatalError.
    ///
    /// - Parameters:
    ///   - decimalParts: The different decimal parts represented by a string
    ///   - view: The view to get the max font size for.
    /// - Returns: The weight = 1 font size to use to fit the view for the different decimal parts.
    private func getFontSizeForDecimalParts(_ decimalParts: [String],
                                            inView view: UIView) -> CGFloat {
        if decimalParts.count == UIFloatingDecimalNumberDisplayer.listIndexOfInteger + 1 {
            // Only the Integer part of a string
            let arrayOfCharactersWithWeights = getListOfCharactersWithWeight(
                decimalParts[UIFloatingDecimalNumberDisplayer.listIndexOfInteger],
                withWeight: UIFloatingDecimalNumberDisplayer.integerStringWeight)
            return getSizeToFit(stringsWithWeights: arrayOfCharactersWithWeights,
                                font: font, maxSize: view.frame.size)
        } else if decimalParts.count
            == UIFloatingDecimalNumberDisplayer.listIndexOfMantissa + 1 {
            // Integer + Decimal part of the string
            var arrayOfCharactersWithWeights = getListOfCharactersWithWeight(
                decimalParts[UIFloatingDecimalNumberDisplayer.listIndexOfInteger],
                withWeight: UIFloatingDecimalNumberDisplayer.integerStringWeight)
            arrayOfCharactersWithWeights.append(contentsOf:
                getListOfCharactersWithWeight(
                    decimalParts[UIFloatingDecimalNumberDisplayer.listIndexOfMantissa],
                    withWeight: UIFloatingDecimalNumberDisplayer.mantissaStringWeight))
            
            return getSizeToFit(stringsWithWeights: arrayOfCharactersWithWeights,
                                font: font, maxSize: view.frame.size)
        } else {
            fatalError("Input was not a valid double representation.")
        }
    }
    
    /// Create a list of individual characters to the input weight.
    ///
    /// - Parameters:
    ///   - characters: A string to convert to a list of characters
    ///   - weight: The weight for each character in the list
    /// - Returns: A list of tuples of single character strings and the provided weight.
    private func getListOfCharactersWithWeight(_ characters: String,
                                               withWeight weight: CGFloat) -> [(String, CGFloat)] {
        var charactersWithWeights = [(String, CGFloat)]()
        for character in characters {
            charactersWithWeights.append((String(describing: character), weight))
        }
        
        return charactersWithWeights
    }
}
