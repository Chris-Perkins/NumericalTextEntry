//
//  PrettyButton.swift
//  PrettyButtons
//
//  Created by Christopher Perkins on 7/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// A button with animations. It looks pretty. Pretty Button.

import UIKit
import ClingConstraints


/// A Button that has feedback whenever the button is pressed
@IBDesignable open class PrettyButton: UIButton {
    /// The different types of styles for a PrettyButton overlay view.
    ///
    /// - none: No overlay
    /// - slide: Slide from left-to-right
    /// - bloom: Blooms outward from the center of the button
    /// - fade: Fades in
    public enum OverlayStyle: Int {
        case none = 0
        case slide = 1
        case bloom = 2
        case fade = 3
    }
    
    /// Tag of overlay view.
    private static let overlayViewTag: Int = 1337
    
    /// The color of the overlay view's background.
    @IBInspectable public var overlayColor: UIColor = UIColor.white.withAlphaComponent(0.25)
    
    /// The amount of time it takes the overlay view to finish its animation.
    @IBInspectable public var animationTimeInSeconds: CFTimeInterval = 0.3
    
    // MARK: Properties
    
    /// The style for the button's overlay
    public var style: PrettyButton.OverlayStyle
    
    // MARK: Init Functions
    
    
    /// Initializes the button with the provided style.
    ///
    /// - Parameter style: The style of the overlay view's animation.
    public init(style: OverlayStyle = .none) {
        self.style = style
        
        super.init(frame: .zero)
        
        setupButton()
    }
    
    /// Initializes the PrettyButton with the provided frame. Sets overlay Style to `.none`.
    ///
    /// - Parameter frame: The frame of the inialized PrettyButton
    /// - Parameter style: The style of the overlay view's animation.
    public init(frame: CGRect, style: OverlayStyle = .none) {
        self.style = style
        
        super.init(frame: frame)
        
        setupButton()
    }
    
    
    /// Initializes the button using the provided NSDecoder. Sets the overlay Style to `.none`.
    ///
    /// - Parameter aDecoder: The NSDecoder for the initialized PrettyButton
    required public init?(coder aDecoder: NSCoder) {
        style = .none
        
        super.init(coder: aDecoder)
        
        setupButton()
    }
    
    
    /// Sets up the default button layout. Gives the button a background and a shadow;
    /// sets up button-release handling.
    private func setupButton() {
        // Don't allow anything to escape the button
        clipsToBounds = true
        
        // Set shadows for the button
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3.0
        
        // User selected button
        addTarget(self, action: #selector(startPress(sender:)), for: .touchDown)
        
        // User exited the button
        addTarget(self, action: #selector(releasePress(sender:)), for: .touchDragExit)
        addTarget(self, action: #selector(releasePress(sender:)), for: .touchUpInside)
        addTarget(self, action: #selector(releasePress(sender:)), for: .touchUpOutside)
        addTarget(self, action: #selector(releasePress(sender:)), for: .touchCancel)
    }
    
    // MARK: Event functions
    
    
    /// Handles tap events; used to prevent button animations from "hanging".
    ///
    /// - Parameters:
    ///   - touches: input
    ///   - event: input
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch: UITouch? = touches.first
        
        if touch?.view != self {
            removeOverlayView()
            layoutSubviews()
        }
    }
    
    
    /// Should be called when the button is starting to be pressed. Creates the overlay view.
    ///
    /// - Parameter sender: The PrettyButton that was pressed
    @objc private func startPress(sender: PrettyButton) {
        switch style {
        case .none:
            break;
        case .slide:
            createSlideView()
        case .bloom:
            createBloomView()
        case .fade:
            createFadeView()
        }
    }
    
    
    /// Should be called when the button is no longer being pressed. Removes the overlay view.
    ///
    /// - Parameter sender: The PrettyButton that was released.
    @objc private func releasePress(sender: PrettyButton) {
        removeOverlayView()
    }
    
    // MARK: Custom view handling
    
    
    /// Creates an overlay view with the provided frame.
    /// 1. Matches the cornerRadius of this view
    /// 1. Sets the background color to be `overlayColor`.
    /// 1. Sets the position of the view to be behind the button's text.
    /// 1. Sets the overlay view's tag, then returns it.
    ///
    /// - Returns: The UIView that was created.
    private func createOverlayView() -> UIView {
        if let overlayView = viewWithTag(PrettyButton.overlayViewTag) {
            return overlayView
        } else {
            // Create view that slides to bottom right on press
            let overlayView: UIView = UIView()
            overlayView.layer.cornerRadius = layer.cornerRadius
            overlayView.backgroundColor = overlayColor
            // Display behind the title
            overlayView.layer.zPosition = -1
            // Set tag to find this view later
            overlayView.tag = PrettyButton.overlayViewTag
            
            return overlayView
        }
    }
    
    /// Creates the sliding effect on the button's background.
    private func createSlideView() {
        // If slide view does not currently exist, create it
        if viewWithTag(PrettyButton.overlayViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = createOverlayView()
            addSubview(overlayView)
            
            // Prepare to slide; start by copying top, left, and bottom of this; width of 0.
            overlayView.copy(.left, .top, .bottom, of: self)
            let widthConstraint = overlayView.setWidth(0)
            // Set the view to these constraints
            layoutIfNeeded()
            
            // Then set it to expand
            widthConstraint.isActive = false
            overlayView.copy(.right, of: self)
            UIView.animate(withDuration: animationTimeInSeconds, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    /// Creates a bloom effect on the button's background.
    private func createBloomView() {
        // If slide view does not currently exist, create it
        if viewWithTag(PrettyButton.overlayViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = createOverlayView()
            addSubview(overlayView)
            
            // Prepare to zoom out of the center; center x and y
            overlayView.copy(.centerX, .centerY, of: self)
            let widthConstraint = overlayView.setWidth(0)
            let heightConstraint = overlayView.setHeight(0)
            // Set the view to these constraints
            layoutIfNeeded()
            
            // Now, bloom
            widthConstraint.isActive = false
            heightConstraint.isActive = false
            overlayView.copy(.height, .width, of: self)
            UIView.animate(withDuration: animationTimeInSeconds, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    /// Causes a fade effect on the button's background.
    private func createFadeView() {
        // If slide view does not currently exist, create it
        if viewWithTag(PrettyButton.overlayViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = createOverlayView()
            addSubview(overlayView)
            // Cause the button to cling to all edges
            overlayView.copy(.left, .right, .top, .bottom, of: self)
            
            // Fade view in
            overlayView.alpha = 0
            UIView.animate(withDuration: animationTimeInSeconds, animations: {
                overlayView.alpha = 1
            })
        }
    }
    
    
    /// Removes the overlay view.
    public func removeOverlayView() {
        // Delete slide view on release
        if let overlayView: UIView = viewWithTag(PrettyButton.overlayViewTag) {
            UIView.animate(withDuration: animationTimeInSeconds, animations: {
                overlayView.alpha = 0
            }, completion: { (finished: Bool) -> Void in
                overlayView.removeFromSuperview()
            })
        }
    }
}
