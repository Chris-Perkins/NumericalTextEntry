//
//  UIViewExtensions.swift
//  NumberEntryField
//
//  Created by Christopher Perkins on 7/8/18.
//

extension UIView {
    /// Removes all constrains for this view
    internal func removeConstraints() {
        let constraints = self.superview?.constraints.filter{
            $0.firstItem as? UIView == self || $0.secondItem as? UIView == self
            } ?? []
        
        self.superview?.removeConstraints(constraints)
        self.removeConstraints(self.constraints)
    }
}
