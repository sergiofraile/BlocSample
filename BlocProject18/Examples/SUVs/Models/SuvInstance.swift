//
//  SuvInstance.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Foundation

/// Represents a SUV (Single-User Version) test instance.
///
/// SUV instances are development environments that can be started, stopped,
/// and have their expiration times extended.
public struct SuvInstance: Identifiable, Codable, Hashable {
    /// Unique SUV instance identifier
    public let instanceId: String
    
    /// SUV hostname/URL
    public let wdHostname: String
    
    /// SUV password for access
    public let wdPassword: String
    
    /// Current build state (e.g., "building", "running")
    public let wdCurrentState: String?
    
    /// Auto-stop time in ISO8601 format
    public let wdAutoStopTime: String?
    
    /// Instance state (running, stopped, etc.)
    public let state: String
    
    /// SUV description
    public let wdDescription: String
    
    /// Auto-restart time in ISO8601 format
    public let wdAutoRestartTime: String?
    
    /// Auto-terminate time in ISO8601 format
    public let wdAutoTerminateTime: String?
    
    /// Conformance to Identifiable
    public var id: String { instanceId }
    
    public init(
        instanceId: String,
        wdHostname: String,
        wdPassword: String,
        wdCurrentState: String?,
        wdAutoStopTime: String?,
        state: String,
        wdDescription: String,
        wdAutoRestartTime: String?,
        wdAutoTerminateTime: String?
    ) {
        self.instanceId = instanceId
        self.wdHostname = wdHostname
        self.wdPassword = wdPassword
        self.wdCurrentState = wdCurrentState
        self.wdAutoStopTime = wdAutoStopTime
        self.state = state
        self.wdDescription = wdDescription
        self.wdAutoRestartTime = wdAutoRestartTime
        self.wdAutoTerminateTime = wdAutoTerminateTime
    }
}

// MARK: - Instance State

extension SuvInstance {
    /// Represents the possible states of a SUV instance.
    public enum InstanceState: String, CaseIterable {
        case running
        case building
        case pending
        case stopping
        case stopped
        case terminated
        case shuttingDown = "shutting-down"
        case impaired
        
        public var displayName: String {
            switch self {
            case .running: return "Running"
            case .building: return "Building"
            case .pending: return "Pending"
            case .stopping: return "Stopping"
            case .stopped: return "Stopped"
            case .terminated: return "Terminated"
            case .shuttingDown: return "Shutting Down"
            case .impaired: return "Impaired"
            }
        }
        
        public var isActive: Bool {
            switch self {
            case .running, .building, .pending:
                return true
            case .stopping, .stopped, .terminated, .shuttingDown, .impaired:
                return false
            }
        }
    }
    
    /// Parsed instance state
    public var instanceState: InstanceState? {
        InstanceState(rawValue: state)
    }
}
