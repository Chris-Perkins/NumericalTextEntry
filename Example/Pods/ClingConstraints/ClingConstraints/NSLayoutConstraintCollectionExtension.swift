//
//  NSLayoutConstraintCollectionExtension.swift
//  ClingConstraintsDemo
//
//  Created by Christopher Perkins on 6/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

public extension Collection where Element == NSLayoutConstraint {
    /**
     Sets the `isActive` property for all constraints in this Collection to true.
     */
    public func activateAllConstraints() {
        for constraint in self {
            constraint.isActive = true
        }
    }
    
    /**
     Sets the `isActive` property for all constraints in this Collection to false.
    */
    public func deactivateAllConstraints() {
        for constraint in self {
            constraint.isActive = false
        }
    }
}
