//
//  NSLayoutConstraintExtension.swift
//  ClingConstraintsDemo
//
//  Created by Christopher Perkins on 6/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

public extension NSLayoutConstraint {
    /**
     Creates a new constraint with the given multiplier and the original constraint's other
     properties, deactivates and removes the old constraint, activates the created constraint, and
     returns the created constraint.
     
     - Parameter newMultiplier: The multiplier that should be set for the new constraint
     - Returns: The new activated constraint with the provided `newMultiplier` value
     */
    @discardableResult public func withMultiplier(_ newMultiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(item: firstItem!, attribute: firstAttribute,
                                               relatedBy: relation, toItem: secondItem,
                                               attribute: secondAttribute,
                                               multiplier: newMultiplier, constant: constant)
        isActive = false
        firstItem?.removeConstraint(self)
        newConstraint.isActive = true
        
        return newConstraint
    }
    
    /**
     Sets the offset of the constraint and returns this constraint.
     
     - Parameter offset: The offset that the constraint should have
     - Returns: This constraint with the offset of the provided offset value
    */
    @discardableResult public func withOffset(_ offset: CGFloat) -> NSLayoutConstraint {
        isActive = false
        constant = offset
        isActive = true
        
        return self
    }
    
    /**
     Creates a new constraint with the given priority and the original constraint's other
     properties, deactivates and removes the old constraint, activates the created constraint, and
     returns the created constraint.
     
     - Parameter priority: The priority that should be set for the new constraint
     - Returns: The new activated constraint with the provided `priority` value
     */
    @discardableResult public func withPriority( _ priority: UILayoutPriority)
        -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(item: firstItem!, attribute: firstAttribute,
                                               relatedBy: relation, toItem: secondItem,
                                               attribute: secondAttribute,
                                               multiplier: multiplier, constant: constant)
        newConstraint.priority = priority
            
        isActive = false
        firstItem?.removeConstraint(self)
        newConstraint.isActive = true
        return self
    }
    
    /**
     Creates a new constraint with the given relation and the original constraint's other
     properties, deactivates and removes the old constraint, activates the created constraint, and
     returns the created constraint.
     
     - Parameter newRelation: The relation that should be set for the new constraint
     - Returns: The new activated constraint with the provided `newRelation` value
     */
    @discardableResult public func withRelation(_ newRelation: NSLayoutRelation)
        -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(item: firstItem!, attribute: firstAttribute,
                                               relatedBy: newRelation, toItem: secondItem,
                                               attribute: secondAttribute,
                                               multiplier: multiplier, constant: constant)
        isActive = false
        firstItem?.removeConstraint(self)
        newConstraint.isActive = true
        
        return newConstraint
    }
}
