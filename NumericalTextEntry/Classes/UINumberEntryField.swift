//
//  UINumberEntryField.swift
//  NumberEntryField
//
//  Created by Christopher Perkins on 7/5/18.
//
// Some dynamic-sizing work imported from https://github.com/tbaranes/FittableFontLabel

import ClingConstraints

// MARK: - UIControl initialization

/// A view that takes in numerical data and displays it. A custom keyboard is used for numerical
/// input.
open class UINumberEntryField: UIControl {
    /// The default number formatter for this NumericalTextEntry
    private static var defaultNumberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.allowsFloats = true
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.groupingSize = 3
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        return numberFormatter
    }
    
    /// The Locale Identifier that is used when converting Strings to Doubles.
    private static let localeIdentifierForDefaultDecimalSeparator = "en_US"
    
    /// The default number displayer.
    private static let defaultNumberDisplayer: UINumberDisplayer = UIFittedFlatNumberDisplayer()
    
    /// The default string to show when there are no characters in the field yet.
    private static var defaultText = "0"
    
    /// The numerical keyboard created when the view becomes the first responder.
    lazy private var numericalKeyboard: UINumericalKeyboardView = {
        let keyboard = UINumericalKeyboardView(frame: CGRect(x: 0, y: 0, width: 300, height: 250),
                                               inputViewStyle: .keyboard)
        keyboard.decimalSeparator =
            numberFormatter.allowsFloats ? numberFormatter.decimalSeparator : ""
        return keyboard
    }()
    
    /// Allows this view to become a first responder.
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    /// Returns the numerical keyboard since this is a numerical text entry. :)
    override open var inputView: UIView? {
        return numericalKeyboard
    }
    
    /// The frame for this view; if it changes, trigger a display change so text always fits
    /// within bounds.
    open override var frame: CGRect {
        didSet {
            triggerDisplayChange()
        }
    }
    
    // MARK: - Stored Properties
    
    /// The number formatter for this text entry.
    ///
    /// - Warning: The grouping separator must also not consist of the decimal separator's character
    /// This also assumes the number formatter will NOT be changed after injection.
    public var numberFormatter: NumberFormatter! = UINumberEntryField.defaultNumberFormatter {
        didSet {
            if numberFormatter.groupingSeparator.contains(numberFormatter.decimalSeparator.first!) {
                fatalError("The number formatter's grouping separator must not consist of the "
                    + "decimal separator.")
            }
            
            if numberFormatter.allowsFloats == false {
                numericalKeyboard.decimalSeparator = ""
            } else {
            // Make sure we always have a valid raw value by replacing decimals
                rawValue = rawValue.replacingOccurrences(
                    of: numericalKeyboard.decimalSeparator!, with: numberFormatter.decimalSeparator)
                numericalKeyboard.decimalSeparator = numberFormatter.decimalSeparator
            }
            // Update display to use the new number formatter
            triggerDisplayChange()
        }
    }
    
    /// The class that takes care of displaying the number.
    /// Re-formats the previously created display views upon change.
    public var numberDisplayer: UINumberDisplayer = UINumberEntryField.defaultNumberDisplayer {
        didSet {
            if let numberDisplayerViews = lastCreatedNumberDisplayerViews {
                for view in numberDisplayerViews {
                    view.removeFromSuperview()
                }
            }
            
            triggerDisplayChange()
        }
    }
    
    /// Determines if the number formatter should hide decimals if the number is an integer.
    @IBInspectable public var hideDecimalsIfIntegerValue = true {
        didSet {
            triggerDisplayChange()
        }
    }
    
    /// The maximum value for this field to store
    @IBInspectable public var maximumValue: Double = 9_999_999_999_999.99 {
        didSet {
            // Do not allow raw value, even if previous set, to exceed the maximum value.
            if doubleValue > maximumValue {
                rawValue = String(describing: maximumValue)
            }
        }
    }
    
    /// The raw value of the number being displayed.
    ///
    /// - Note: If you're a developer asking why the value is stored as a String.. Hi!
    /// A string was chosen since doubles often lose true precision.
    /// Think of the nightmare of trying to remove the correct decimal in a double of 0.49999999...
    @IBInspectable public var rawValue: String = "" {
        didSet {
            lastCreatedNumberDisplayerViews = numberDisplayer.displayValue(
                displayedStringValue, withRawString: rawValue, numberFormatter: numberFormatter,
                inView: self)
        }
    }
    
    /// The Double representing `rawValue`; computed by computing the double value of `rawValue`.
    public var doubleValue: Double {
        // For some reason, the String -> Double cast only uses the US decimal separator.
        // Therefore, we have to change all number formatter decimal separator occurrences with
        // with the US's decimal separator
        return Double(rawValue.replacingOccurrences(
            of: numberFormatter.decimalSeparator,
            with: Locale(identifier: UINumberEntryField.localeIdentifierForDefaultDecimalSeparator)
                .decimalSeparator!)) ?? 0
    }
    
    /// The string that is currently being displayed in this view. Computed by running the
    /// `numberFormatter` injected in this class to format the `String` from `doubleValue`.
    public var displayedStringValue: String {
        if hideDecimalsIfIntegerValue && currentDecimalEditingPosition == nil {
            return String(numberFormatter.string(from: doubleValue as NSNumber)!
                .components(separatedBy: numberFormatter.decimalSeparator).first!)
        }
        // Go back and forth to "cleanse" the rawValue string.
        return numberFormatter.string(from: doubleValue as NSNumber)!
    }
    
    /// The number displayer views that were created
    private var lastCreatedNumberDisplayerViews: [UIView]?
    
    /// The current decimal position being edited in the view; 0-indexed.
    /// `nil` if a decimal is not being edited.
    private var currentDecimalEditingPosition: Int? = nil
    
    /// Whether or not we're updating from the interface builder (IB).
    private var isUpdatingFromIB = false
    
    // MARK: - Initializers
    
    /// Initializes a NumericalTextEntry with a frame of zero-sized dimensions.
    public init() {
        super.init(frame: .zero)
        
        assignTargets()
        triggerDisplayChange()
    }
    
    /// Initializes a NumericalTextEntry with the provided frame.
    ///
    /// - Parameter frame: The frame of the initialized NumericalTextEntry
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        assignTargets()
        triggerDisplayChange()
    }
    
    /// Initializes a NumericalTextEntry with an NSDecoder.
    ///
    /// - Parameter aDecoder: The NSDecoder used to initialize this NumericalTextEntry
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        assignTargets()
        triggerDisplayChange()
    }
    
    // MARK: - Life cycle - Used to set font size on start / on size change.
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        triggerDisplayChange()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        triggerDisplayChange()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !isUpdatingFromIB {
            triggerDisplayChange()
        }
        isUpdatingFromIB = false
    }
    
    // MARK: - Private QoL functions
    
    // Causes the "didSet" event to occur for `rawValue`.
    private func triggerDisplayChange() {
        rawValue = rawValue + ""
    }
    
    /// Assigns the view to call didTouchUpInside when this view receives the .touchUpInside event.
    private func assignTargets() {
        addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }
    
    // MARK: - Events
    
    /// Called when the view was touched up inside. Causes this view to become the first responder.
    ///
    /// - Parameter sender: The sending view; should be this view.
    @objc func didTouchUpInside(_ sender: UIView) {
        becomeFirstResponder()
    }
    
    /// Causes this view to become first responder.
    ///
    /// Posts a Notification named `numericalTextEntryDidBeginEditing` and sends `self` as the
    /// object if this view became the first responder.
    ///
    /// - Returns: True if this view became the first responder; false otherwise.
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let becameFirstResponder = super.becomeFirstResponder()
        if becameFirstResponder {
            NotificationCenter.default.post(name: NumericalTextEntryNotifications.didBeginEditing,
                                            object: self)
        }
        
        return becameFirstResponder
    }
    
    /// Causes this view to resign first responder.
    ///
    /// Posts a Notification named `numericalTextEntryDidEndEditing` and sends `self` as the
    /// object if this view became the first responder.
    ///
    /// - Returns: True if this view became the first responder; false otherwise.
    @discardableResult override open func resignFirstResponder() -> Bool {
        let resignedFirstResponder = super.resignFirstResponder()
        if resignedFirstResponder {
            NotificationCenter.default.post(name: NumericalTextEntryNotifications.didEndEditing,
                                            object: self)
        }
        
        return resignedFirstResponder
    }
}

// MARK: - UIKeyInput Extension

extension UINumberEntryField: UIKeyInput {
    /// Returns true if entry has non-zero entries
    public var hasText: Bool {
        return !rawValue.isEmpty
    }
    
    /// Inserts the given text into this NumericalTextEntry.
    ///
    /// - Warning: Assumes the text is only composed of one numerical character.
    /// Incorrect behavior if this is not the case!
    ///
    /// - Parameter text: The text to be inserted
    public func insertText(_ text: String) {
        if text != numberFormatter.decimalSeparator && Double(text) == nil {
            print("Input string [\(text)] is not a valid input!")
            return
        }
        
        // If we're currently in the process of editing the decimals...
        if let decimalEditPosition = currentDecimalEditingPosition {
            // If the user tried to input another decimal or exceeded the maximum digits,
            // then we do not accept their input.
            // NOTE: it's safe to cast here since decimals don't cause floats to go out of bounds :)
            if text == numberFormatter.decimalSeparator
                || decimalEditPosition >= numberFormatter.maximumFractionDigits {
                // Some error here
            } else {
                /* Checks to see if we exceeded bounds; done this way to prevent overflow :)
                    Simple algebra:
                        maximumValue < doubleValue + decimalValueOfIncomingText
                        maximumValue - decimalValueOfIncomingText < doubleValue */
                if (maximumValue - Double(text)!
                    * Double(truncating: pow(1 / 10, decimalEditPosition + 1) as NSNumber)
                    < doubleValue) {
                    print("NumericalTextEntry WARNING: user attempted to exceed maximum value!")
                } else {
                    rawValue.append(text)
                    
                    currentDecimalEditingPosition = decimalEditPosition + 1
                }
            }
        } else {
            if text == numberFormatter.decimalSeparator {
                // If the number formatter doesn't allow floats in any way, we shouldn't either
                if !numberFormatter.allowsFloats || numberFormatter.maximumFractionDigits == 0 {
                    // Some error here
                } else {
                    if rawValue.isEmpty {
                        // Insert the default 0 value first
                        insertText(UINumberEntryField.defaultText)
                    }
                    // Start editing the decimal field
                    currentDecimalEditingPosition = 0
                    rawValue.append(text)
                }
            } else {
                /* Checks to see if we exceeded bounds; done this way to prevent overflow :)
                    Simple algebra:
                        maximumValue < 10 * doubleValue + addedDoubleValue
                        (maximumValue - addedDoubleValue) / 10 < doubleValue
 
                    Note: The multiplication by 10 is done since the added digit causes the
                    doubleValue to multiply by 10 (digits shift left 1; aka * 10 */
                if (maximumValue - Double(text)!) / 10.0 < doubleValue {
                    print("NumericalTextEntry WARNING: user attempted to exceed maximum value!")
                } else {
                    // If zero value
                    if (rawValue.elementsEqual(UINumberEntryField.defaultText)) {
                        rawValue = text
                    } else {
                        rawValue.append(text)
                    }
                }
            }
        }
    }
    
    /// Deletes the last character being displayed in the character text box.
    ///
    /// Unsets the currentDecimalEditingPosition if it's not filled in.
    public func deleteBackward() {
        if hasText {
            // Different behaviors for the different states of editing.
            // If we're editing a decimal, we have some funky checks we have to do for deletion.
            // If we're editing an integer, it's safe to just remove the last character.
            if let currentDecimalPosition = currentDecimalEditingPosition {
                // This shouldn't be less than 0... but just in case.
                // By checking if we're at 0, we're essentially saying "do we have any decimal
                // numbers?". If we're at 0, that means we're safe to go back into integer-land.
                currentDecimalEditingPosition = currentDecimalPosition <= 0 ? nil
                    : currentDecimalPosition - 1
            }
            
            rawValue.removeLast()
        } else {
            // Some error here
        }
    }
}
