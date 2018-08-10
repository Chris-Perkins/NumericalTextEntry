//
//  UINumberDisplayer.swift
//  NumberEntryField
//
//  Created by Christopher Perkins on 8/3/18.
//

/// A protocol used to display numbers
public protocol UINumberDisplayer {
    /// Displays the provided value.
    ///
    /// - Parameters:
    ///   - stringToDisplay: The complete string to display.
    ///   - rawValue: The raw value of the string to display (not formatted)
    ///   - numberFormatter: The formatter used to generate the stringToDisplay
    ///   - view: The view where the value should be displayed in
    /// - Returns: The views that were created to hold the displayed value.
    func displayValue(_ stringToDisplay: String, withRawString rawString: String,
                      numberFormatter: NumberFormatter, inView view: UIView) -> [UIView]
}
