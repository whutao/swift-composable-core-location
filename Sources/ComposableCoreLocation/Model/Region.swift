import CoreLocation
import Foundation

/// A testable and sendable wrapper for `CLRegion` model.
public struct Region: Equatable, Hashable, @unchecked Sendable {
    
    /// CoreLocation region model.
    public let rawValue: CLRegion?
    
    /// The identifier for the region object.
    public let identifier: String
    
    /// A boolean indicating that notifications are generated upon entry into the region.
    public let notifyOnEntry: Bool
    
    /// A boolean indicating that notifications are generated upon exit from the region.
    public let notifyOnExit: Bool
    
    /// Create an instance from the raw value.
    /// - Parameter clRegion: CoreLocation region model.
    public init(clRegion: CLRegion) {
        self.rawValue = clRegion
        self.identifier = clRegion.identifier
        self.notifyOnExit = clRegion.notifyOnExit
        self.notifyOnEntry = clRegion.notifyOnEntry
    }
    
    /// Create an instance member-wise.
    public init(
        identifier: String,
        notifyOnEntry: Bool,
        notifyOnExit: Bool
    ) {
        self.rawValue = nil
        self.identifier = identifier
        self.notifyOnExit = notifyOnExit
        self.notifyOnEntry = notifyOnEntry
    }
    
    public static func == (lhs: Region, rhs: Region) -> Bool {
        return lhs.identifier == rhs.identifier
            && lhs.notifyOnEntry == rhs.notifyOnEntry
            && lhs.notifyOnExit == rhs.notifyOnExit
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(notifyOnEntry)
        hasher.combine(notifyOnExit)
    }
}
