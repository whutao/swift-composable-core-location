import CasePaths
import ComposablePermission
import CoreLocation
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct LocationClient: DependencyKey, Sendable {
    
    /// The delegate event stream.
    public var delegate: () -> AsyncStream<Delegate> = { .finished }
    
    /// The last location received.
    ///
    /// Will be nil until a location has been received.
    public var location: () -> CLLocation?
    
    /// Retrieve a set of objects for the regions that are currently being monitored.
    ///
    /// If any location manager has been instructed to monitor a region, during this or previous
    /// launches of the application, it will be present in this set.
    public var monitoredRegions: () -> Set<Region> = { Set() }
    
    /// Request a single location update.
    ///
    /// The service will attempt to determine location with accuracy according
    /// to the `desiredAccuracy` property.  The location update will be delivered
    /// via the standard delegate callback, i.e. `locationManager:didUpdateLocations:`
    ///
    /// If the best available location has lower accuracy, then it will be
    /// delivered via the standard delegate callback after timeout.
    ///
    /// If no location can be determined, the `locationManager:didFailWithError:`
    /// delegate callback will be delivered with error location unknown.
    ///
    /// There can only be one outstanding location request and this method can
    /// not be used concurrently with `startUpdatingLocation` or
    /// `allowDeferredLocationUpdates`.  Calling either of those methods will
    /// immediately cancel the location request.  The method
    /// `stopUpdatingLocation` can be used to explicitly cancel the request.
    public var requestLocation: () -> Void
    
    /// User’s permission to use location services regardless of whether the app is in use.
    public var alwaysAuthorizationStatus: () -> PermissionStatus = { .denied }
    
    /// User’s permission to use location services while the app is in use.
    public var whenInUseAuthorizationStatus: () -> PermissionStatus = { .denied }
    
    /// Requests the user’s permission to use location services
    /// regardless of whether the app is in use.
    ///
    /// Action `Delegate.didChangeAuthorizationStatus` will be sent when a status changes.
    public var requestAlwaysAuthorization: () -> Void
    
    /// Requests the user’s permission to use location services
    /// regardless of whether the app is in use.
    ///
    /// Returns the most recent permission status.
    /// No need to track `Delegate.didChangeAuthorizationStatus`.
    public var requestAlwaysAuthorizationWaitingForStatus: () async -> PermissionStatus = {
        return .denied
    }
    
    /// Requests the user’s permission to use location services while the app is in use.
    ///
    /// Action `Delegate.didChangeAuthorizationStatus` will be sent when a status changes.
    public var requestWhenInUseAuthorization: () -> Void
    
    /// Requests the user’s permission to use location services while the app is in use.
    ///
    /// Returns the most recent permission status.
    /// No need to track `Delegate.didChangeAuthorizationStatus`.
    public var requestWhenInUseAuthorizationWaitingForStatus: () async -> PermissionStatus = {
        return .denied
    }
    
    /// Determines whether the user has location services enabled.
    ///
    /// If location services disabled, and you proceed to call `CoreLocation` API, user will be
    /// prompted with the warning dialog. So, check this property and
    /// use location services only when explicitly requested by the user.
    public var areLocationServicesEnabled: () -> Bool = { false }
    
    /// Returns `true` if the device supports significant location change monitoring, otherwise `false`.
    public var isSignificantLocationChangeMonitoringAvailable: () -> Bool = { false }
    
    /// Returns `true` if the device supports the heading service, otherwise `false`.
    public var isHeadingAvailable: () -> Bool = { false }
    
    /// Determines whether the device supports ranging.
    ///
    /// If ranging is unsupported, all attempts to range beacons will fail.
    public var isRangingAvailable: () -> Bool = { false }
    
    /// Start updating heading.
    public var startUpdatingHeading: () -> Void
    
    /// Stop updating heading.
    public var stopUpdatingHeading: () -> Void

    /// Start updating locations.
    public var startUpdatingLocation: () -> Void
    
    /// Stop updating locations.
    public var stopUpdatingLocation: () -> Void
    
    /// Begin monitoring for visits.
    ///
    /// All location managers allocated by the application, both current and future,
    /// will deliver detected visits to their delegates.
    ///
    /// This will continue until `stopMonitoringVisits` is sent to any such manager,
    /// even across application relaunch events.
    public var startMonitoringVisits: () -> Void
    
    /// Stop monitoring for visits.
    ///
    /// Stopping and starting are asynchronous operations and may not
    /// immediately reflect in delegate callback patterns.
    public var stopMonitoringVisits: () -> Void
    
    // Monitoring significant location changes
    
    /// Start monitoring significant location changes.
    ///
    /// The behavior is not affected by the `desiredAccuracy` or `distanceFilter` properties.
    /// Locations will be delivered through the same delegate callback as the standard location service.
    public var startMonitoringSignificantLocationChanges: () -> Void
    
    /// Stop monitoring significant location changes.
    public var stopMonitoringSignificantLocationChanges: () -> Void
    
    /// Actions for corresponding `CLLocationManagerDelegate` methods.
    @CasePathable
    public enum Delegate: Sendable {
        
        /// Invoked when either the authorization status or accuracy authorization change.
        case didChangeAuthorizationStatus
        
        /// Invoked when an error has occurred.
        case didFail(error: Error)
        
        /// Invoked when deferred updates will no longer be delivered.
        ///
        /// Stopping location, disallowing deferred updates, and meeting a specified criterion
        /// are all possible reasons for finishing deferred updates.
        ///
        /// An error will be returned if deferred updates end before the specified
        /// criteria are met (see ``CLError``), otherwise error will be nil.
        case didFinishDeferredUpdates(error: Error?)
        
        /// Invoked when the user enters a monitored region.
        case didEnter(region: Region)

        /// Invoked when the user exits a monitored region.
        case didExit(region: Region)
        
        /// Invoked when location updates are automatically paused.
        case didPauseLocationUpdates
        
        /// Invoked when location updates are automatically resumed.
        ///
        /// In the event that the application is terminated while suspended, you will
        /// not receive this notification.
        case didResumeLocationUpdates
        
        /// Invoked when a monitoring for a region started successfully.
        case didStartMonitoring(region: Region)
        
        /// Invoked when a region monitoring error has occurred.
        case didFailMonitoring(region: Region?, error: Error)
    }
}

extension DependencyValues {
    
    /// A dependecy that allows to interact with user location.
    public var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}
