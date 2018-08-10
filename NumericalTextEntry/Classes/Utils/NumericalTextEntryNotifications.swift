//
//  NumericalTextEntryNotifications.swift
//  NumberEntryField
//
//  Created by Christopher Perkins on 7/7/18.
//

/// A class that holds the notification names for text entry notifications.
internal class NumericalTextEntryNotifications {
    /// A Notification Name for when a NumericalTextEntry began editing.
    internal static let didBeginEditing =
        Notification.Name(rawValue: "NumericalTextEntryDidBeginEditing")

    /// A Notification Name for when a NumericalTextEntry ended editing.
    internal static let didEndEditing =
        Notification.Name(rawValue: "NumericalTextEntryDidEndEditing")
}
