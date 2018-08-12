![](https://github.com/Chris-Perkins/NumericalTextEntry/raw/master/Readme_Imgs/NumericalTextEntryHeader.png)

NumericTextEntry is a powerful, extensible library made for your application's numeric entry needs.

Available NumberDisplayer components: 

| &nbsp;&nbsp;UIFittedFlatNumberDisplayer &nbsp;&nbsp;&nbsp; | UIFloatingDecimalNumberDisplayer | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;UIFlatNumberDisplayer&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
|:---------------------------:|:--------------------------------:|:---------------------:|
![](https://github.com/Chris-Perkins/NumericalTextEntry/raw/master/Readme_Imgs/UIFittedFlatNumberDisplayer.gif) | ![](https://github.com/Chris-Perkins/NumericalTextEntry/raw/master/Readme_Imgs/UIFloatingDecimalNumberDisplayer.gif) | ![](https://github.com/Chris-Perkins/NumericalTextEntry/raw/master/Readme_Imgs/UIFlatNumberDisplayer.gif)

| Custom Keyboard | Disable Floats&nbsp; |
|:---------------:|:--------------:|
![](https://github.com/Chris-Perkins/NumericalTextEntry/raw/master/Readme_Imgs/CustomKeyboard.gif) | ![](https://github.com/Chris-Perkins/NumericalTextEntry/raw/master/Readme_Imgs/DisableFloatEntry.gif)

## Features

✅ Highly extensible  
✅ iPad friendly--uses a purely numeric keyboard  
✅ Locale-safe; don't worry about different localization issues  
✅ Display Numbers using 3 built-in NumberDisplayers (or your own!)  
✅ Displayers with dynamic-sizing text to always fit your view  
✅ Injectable NumberFormatter for custom number formatting  
✅ Set a maximum value for numeric text  
✅ Ability to hide decimals for text that can be represented by an Int  
✅ Built-in beautiful, custom keyboard  
✅ Define whether float values are allowed  

## Installation

1. Install [CocoaPods](https://cocoapods.org)
1. Add this repo to your `Podfile`

	```ruby
	target 'Example' do
		# IMPORTANT: Make sure use_frameworks! is included at the top of the file
		use_frameworks!

		pod 'NumericalTextEntry'
	end
	```
1. Run `pod install` in the podfile directory from your terminal
1. Open up the `.xcworkspace` that CocoaPods created
1. Done!

## How Do I Work With It?

NumericalTextEntry is intended to be very extensible. Despite its extensibility, NumericalTextEntry is very easy to work with.

### Basics

To create a numeric text entry field: `let numberField = UINumberEntryField()`

To get the different values in the number field:  
```Swift
let userInputValue = numberField.rawValue
let numericValue = numberField.doubleValue
let displayedValue = numberField.displayedStringValue
```

### Customization

The following values are customizable for `UINumberEntryFields`:  
```Swift
// Cap the maximum value for entry to 987.2 (default  9_999_999_999_999.99; exceeding the default value may cause formatting errors due to double-precision.)
numberField.maximumValue = 987.2

// Set the starting value for the number field
numberField.startingValue = 37.2

// Determines if decimals should not be in the displayedString if the number can be represented by an integer 
// e.g.: rawValue: "23" - formattedNumber: "23.00" - displayedNumber: "23")
// e.g. 2: rawValue: "23.0" - formattedNumber: "23.00" - displayedNumber: "23.00"
numberField.hideDecimalsIfIntegerValue = false

// Change the number formatter for the view
numberField.numberFormatter = userDefinedNumberFormatter

// Change the number displayer.
numberField.numberDisplayer = UIFloatingDecimalNumberDisplayer()
numberField.numberDisplayer = UIFlatNumberDisplayer()
numberField.numberDisplayer = UIFittedFlatNumberDisplayer()

// NumberDisplayer customization: both the UIFloatingDecimalNumberDisplayer and UIFittedFlatNumberDisplayer have toggleable animations.
let numberDisplayer = UIFittedFlatNumberDisplayer()
numberDisplayer.animated = false

// Custom fonts and text colors are available for every number displayer as well!
let numberDisplayer = UIFittedFlatNumberDisplay(withFont: customFont, withTextColor: UIColor.red)
```

Want to disallow float values? Simply inject a NumberFormatter that doesn't allow floats!  
```Swift
let numberFormatter = NumberFormatter()
numberFormatter.allowsFloats = false
numberField.numberFormatter = numberFormatter
```

### Custom NumberDisplayers

Want to create your own NumberDisplayer? Follow this simple protocol!

```Swift
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
```

### Component Diagram

![](https://github.com/Chris-Perkins/NumericalTextEntry/raw/master/Readme_Imgs/UINumberEntryFieldComponentDiagram.png)


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 10.0 is required.

## Documentation

Read the [docs](https://htmlpreview.github.io/?https://github.com/Chris-Perkins/NumericalTextEntry/blob/master/docs/index.html)

## Author

Ya Boi

## License

NumericalTextEntry is available under the MIT license. See the LICENSE file for more info.
