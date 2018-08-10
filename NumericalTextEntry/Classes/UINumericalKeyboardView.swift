//
//  UINumericalKeyboardView.swift
//  NumberEntryField
//
//  Created by Christopher Perkins on 7/5/18.
//

import ClingConstraints
import PrettyButtons

/// A keyboard which only has Numerical Input Keys.
open class UINumericalKeyboardView: UIInputView {
    // MARK: - Properties
    
    /// The animation time for button presses
    private static let animationTime: CFTimeInterval = 0.075
    
    /// The width of the done button where the multiplied width is width of self.
    private static let doneButtonWidthOfSelfMultiplier: CGFloat = 1.0 / 3.0
    
    /// The done button title.
    private static let doneButtonTitle = "Done"
    
    /// The string representing a backspace action.
    private static let backspaceButtonString = "<"
    
    /// The amount of rows in the numerical keyboard view.
    private static let rowCount: Int = 4;
    
    /// The amount of spacing between buttons.
    private static let buttonSpacing: CGFloat = 0;
    
    /// The default color of the done button.
    private static let doneButtonPrimaryTextColor = UIColor(red: 0, green: 0.43, blue: 0.92,
                                                            alpha: 0.8)
    
    /// The primary button color for the created buttons.
    private static let numericalButtonsPrimaryColor = UIColor.darkGray
    
    /// The overlay style for when buttons are pressed.
    private static let buttonOverlayStyle = PrettyButton.OverlayStyle.fade
    
    /// The decimal separator that should be displayed on the keyboard.
    public var decimalSeparator = Locale.current.decimalSeparator {
        didSet {
            decimalButton?.setTitle(decimalSeparator, for: .normal)
        }
    }
    
    /// The decimal separator button on the keyboard.
    private var decimalButton: PrettyButton?
    
    /// The current numerical text entry field that is being edited.
    private var currentNumericalTextEntryBeingEdited: UINumberEntryField?
    
    // MARK: - Initializers
    
    /// Initializes the keyboard with the provided frame.
    ///
    /// - Parameters:
    ///   - frame: The frame of the keyboard
    ///   - inputViewStyle: The style of input
    public override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        setupNotificationListeners()
        setupButtons()
    }
    
    /// Initializes the NumericalKeyboardView from the provided NSCoder.
    ///
    /// - Parameter aDecoder: The NSDecoder received from Storyboard interactions.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupNotificationListeners()
        setupButtons()
    }
    
    /// Sets up the button views: create, assign actions, then constrain.
    private func setupButtons() {
        let topBar = UIView()
        addSubview(topBar)
        topBar.copy(.left, .right, .top, of: self)
        topBar.setHeight(40)
        addDoneButton(toView: topBar)
        
        let numericalButtonsView = UIView()
        addSubview(numericalButtonsView)
        numericalButtonsView.copy(.left, .bottom, .right, of: self)
        numericalButtonsView.cling(.top, to: topBar, .bottom)
        
        let numericalButtons = createNumericalInputButtons()
        constrainRowsOfViewsToFillView(numericalButtons, viewToFill: numericalButtonsView)
    }
    
    /// Sets up the notifications for the numerical keyboard view.
    private func setupNotificationListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: NumericalTextEntryNotifications.didBeginEditing,
                                               object: nil)
    }
    
    /// Adds a "Done" button to this view
    ///
    /// - Parameter view: The view that will have a "Done" button added to it
    open func addDoneButton(toView view: UIView) {
        let doneButton = PrettyButton()
        view.addSubview(doneButton)
        
        doneButton.copy(.top, of: view)
        doneButton.copy(.bottom, of: view)
        doneButton.copy(.right, of: view)
        
        doneButton.copy(.width, of: view)
            .withMultiplier(UINumericalKeyboardView.doneButtonWidthOfSelfMultiplier)
        doneButton.setTitle(UINumericalKeyboardView.doneButtonTitle, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonPress(_:)), for: .touchUpInside)
        
        doneButton.animationTimeInSeconds = UINumericalKeyboardView.animationTime
        doneButton.style = UINumericalKeyboardView.buttonOverlayStyle
        doneButton.setTitleColor(UINumericalKeyboardView.doneButtonPrimaryTextColor, for: .normal)
    }
    
    /// Creates the numerical input buttons.
    ///
    /// - Returns: The buttons representing the keyboard's layout on a per-row basis
    open func createNumericalInputButtons() -> [[UIButton]] {
        // 3 Columns
        var numericalButtons = [[PrettyButton]].init(repeating: [],
                                                    count: UINumericalKeyboardView.rowCount)
        
        for index in 1...9 {
            let numericalButton = PrettyButton()
            numericalButton.animationTimeInSeconds = UINumericalKeyboardView.animationTime
            numericalButton.setTitle("\(index)", for: .normal)
            
            numericalButtons[(index - 1) / 3].append(numericalButton)
        }
        
        let decimalSeparatorButton = PrettyButton()
        decimalSeparatorButton.animationTimeInSeconds = UINumericalKeyboardView.animationTime
        decimalSeparatorButton.setTitle(decimalSeparator, for: .normal)
        let zeroButton = PrettyButton()
        zeroButton.animationTimeInSeconds = UINumericalKeyboardView.animationTime
        zeroButton.setTitle("\(0)", for: .normal)
        let backspaceButton = PrettyButton()
        backspaceButton.animationTimeInSeconds = UINumericalKeyboardView.animationTime
        backspaceButton.setTitle(UINumericalKeyboardView.backspaceButtonString, for: .normal)
        
        decimalButton = decimalSeparatorButton
        
        numericalButtons[UINumericalKeyboardView.rowCount - 1].append(contentsOf:
            [decimalSeparatorButton, zeroButton, backspaceButton])

        for buttonGroup in numericalButtons {
            for button in buttonGroup {
                button.style = UINumericalKeyboardView.buttonOverlayStyle
                button.backgroundColor = UINumericalKeyboardView.numericalButtonsPrimaryColor
                
                button.addTarget(self, action: button == backspaceButton
                    ? #selector(deleteButtonPress(_:)) : #selector(numericalButtonPress(_:)),
                                 for: .touchUpInside)
            }
        }
        
        return numericalButtons
    }
    
    /// Fills an input view with the different rows of views provided from top to bottom.
    ///
    /// - Parameter rowsOfViews: The different rows that should be stacked in this view
    /// - Parameter viewToFill: The view that should be filled with the input rows
    /// - Returns: The constraints created to stack the views
    @discardableResult
    private func constrainRowsOfViewsToFillView(_ rowsOfViews: [[UIView]],
                                                viewToFill: UIView) -> [NSLayoutConstraint] {
        var rowViews = [UIView]()
        var constraints = [NSLayoutConstraint]()
        
        for rowOfViews in rowsOfViews {
            let rowView = UIView()
            self.addSubview(rowView)
            rowViews.append(rowView)
            
            for viewInRow in rowOfViews {
                rowView.addSubview(viewInRow)
                viewInRow.copy(.top, .bottom, of: rowView)
            }
            
            constraints.append(contentsOf: rowView.copy(.left, .right, of: viewToFill))
            constraints.append(contentsOf:
                rowView.fill(.leftToRight, withViews: rowOfViews,
                             withSpacing: UINumericalKeyboardView.buttonSpacing,
                             spacesInternally: true))
        }
        
        constraints.append(contentsOf: viewToFill.fill(.topToBottom, withViews: rowViews,
                                            withSpacing: UINumericalKeyboardView.buttonSpacing,
                                            spacesInternally: true))
        
        return constraints
    }
    
    // MARK: - Event Functions
    
    /// Should be called when the Done button is pressed. Calls the field being edited to resign.
    ///
    /// - Parameter sender: The Done button
    @objc func doneButtonPress(_ sender: UIButton) {
        currentNumericalTextEntryBeingEdited?.resignFirstResponder()
    }
    
    /// Should be called when the deletion button was pressed.
    ///
    /// - Parameter sender: The Deletion button
    @objc func deleteButtonPress(_ sender: UIButton) {
        currentNumericalTextEntryBeingEdited?.deleteBackward()
    }
    
    /// Should be called when a numerical button was pressed.
    ///
    /// - Parameter sender: The numerical button that was pressed
    @objc func numericalButtonPress(_ sender: UIButton) {
        currentNumericalTextEntryBeingEdited?.insertText(sender.titleLabel?.text ?? "")
    }
    
    /// Should be called when the keyboard should show.
    ///
    /// - Parameter sender: The sent notification.
    @objc func keyboardWillShow(_ sender: Notification) {
        if let numericalTextEntry = sender.object as? UINumberEntryField {
            currentNumericalTextEntryBeingEdited = numericalTextEntry
        } else {
            fatalError("Expected to receive the current text field being edited.")
        }
    }
}
