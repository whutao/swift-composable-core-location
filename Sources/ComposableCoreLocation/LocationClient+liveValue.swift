import Combine
import CombineExtras
import ComposableLocationPermission
import CoreLocation
import Dependencies
import Foundation

extension LocationClient {
    
    public static var liveValue: LocationClient {
        @Dependency(\.locationPermissionClient) var permission
        
        let manager = CLLocationManager()
        
        let delegate = AnyPublisher<LocationClient.Delegate, Never> { subscriber in
            let delegate = LocationManagerDelegate(subscriber: subscriber)
            manager.delegate = delegate
            return AnyCancellable { [delegate] in
                _ = delegate
            }
        }
        .share()
        
        return LocationClient(
            delegate: delegate.asyncStream,
            location: {
                return manager.location
            },
            monitoredRegions: {
                return Set(manager.monitoredRegions.map(Region.init))
            },
            requestLocation: manager.requestLocation,
            alwaysAuthorizationStatus: permission.always,
            whenInUseAuthorizationStatus: permission.whenInUse,
            requestAlwaysAuthorization: {
                Task.detached(priority: .high) {
                    _ = await permission.requestAlways()
                }
            },
            requestAlwaysAuthorizationWaitingForStatus: permission.requestAlways,
            requestWhenInUseAuthorization: {
                Task.detached(priority: .high) {
                    _ = await permission.requestWhenInUse()
                }
            },
            requestWhenInUseAuthorizationWaitingForStatus: permission.requestWhenInUse,
            areLocationServicesEnabled: CLLocationManager.locationServicesEnabled,
            isSignificantLocationChangeMonitoringAvailable: CLLocationManager.significantLocationChangeMonitoringAvailable,
            isHeadingAvailable: CLLocationManager.headingAvailable,
            isRangingAvailable: CLLocationManager.isRangingAvailable,
            startUpdatingHeading: manager.startUpdatingHeading,
            stopUpdatingHeading: manager.stopUpdatingHeading,
            startUpdatingLocation: manager.startUpdatingLocation,
            stopUpdatingLocation: manager.stopUpdatingLocation,
            startMonitoringVisits: manager.startMonitoringVisits,
            stopMonitoringVisits: manager.stopMonitoringVisits,
            startMonitoringSignificantLocationChanges: manager.startMonitoringSignificantLocationChanges,
            stopMonitoringSignificantLocationChanges: manager.stopMonitoringSignificantLocationChanges
        )
    }
}

fileprivate final class LocationManagerDelegate: NSObject {
    
    private let subscriber: Publishers.Custom<LocationClient.Delegate, Never>.Subscriber
    
    init(subscriber: Publishers.Custom<LocationClient.Delegate, Never>.Subscriber) {
        self.subscriber = subscriber
        super.init()
    }
}

extension LocationManagerDelegate: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        subscriber.send(value: .didChangeAuthorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        subscriber.send(value: .didFail(error: error))
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFinishDeferredUpdatesWithError error: Error?
    ) {
        subscriber.send(value: .didFinishDeferredUpdates(error: error))
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        subscriber.send(value: .didPauseLocationUpdates)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        subscriber.send(value: .didResumeLocationUpdates)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        subscriber.send(value: .didEnter(region: Region(clRegion: region)))
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        subscriber.send(value: .didExit(region: Region(clRegion: region)))
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didStartMonitoringFor region: CLRegion
    ) {
        subscriber.send(value: .didStartMonitoring(region: Region(clRegion: region)))
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        monitoringDidFailFor region: CLRegion?,
        withError error: any Error
    ) {
        subscriber.send(value: .didFailMonitoring(
            region: region.flatMap(Region.init),
            error: error)
        )
    }
}
