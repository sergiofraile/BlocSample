//
//  SUVView.swift
//  BlocProject
//
//  Created by Sergio Fraile on 19/01/2026.
//

import Bloc
import SwiftUI

#if os(iOS)
import UIKit
#endif

// MARK: - ⚠️ CONFIGURATION REQUIRED
//
// This example requires a valid SUVify API key to function.
//
// Setup Instructions:
// 1. Copy `Suvify.plist.example` to `Suvify.plist`
// 2. Replace `YOUR_API_KEY_HERE` with your actual API key
// 3. Add `Suvify.plist` to your Xcode target (Build Phases → Copy Bundle Resources)
//
// ⚠️ IMPORTANT: Never commit Suvify.plist to version control!
//    It contains sensitive API credentials. The file is already in .gitignore.
//
// API Key: Contact your team lead for the SUVify API key (suvify_key)
//

/// Main view for the SUVs example.
///
/// This view demonstrates:
/// - Login flow with authentication
/// - Displaying a list of SUV instances
/// - Extending instance expiration times
/// - State-driven UI with the Bloc pattern
///
/// - Important: Requires `Suvify.plist` with a valid `suvify_key`. See setup instructions above.
struct SUVView: View {
    
    let suvBloc = BlocRegistry.resolve(SUVBloc.self)
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showExtendSuccess: Bool = false
    @State private var extendedInstanceName: String = ""
    
    var body: some View {
        Group {
            switch suvBloc.state {
            case .initial, .authenticating, .authError:
                loginView
                
            case .authenticated, .loadingInstances, .loaded, .extending, .error:
                instancesView
            }
        }
        .navigationTitle("SUV Instances")
        .animation(.easeInOut(duration: 0.3), value: suvBloc.state.isAuthenticated)
        .onChange(of: suvBloc.state) { oldValue, newValue in
            // Detect successful extend completion
            if case .extending(_, _, let extendingId) = oldValue,
               case .loaded(_, let instances, _) = newValue {
                if let instance = instances.first(where: { $0.id == extendingId }) {
                    extendedInstanceName = instance.instanceId
                    showExtendSuccess = true
                    
                    #if os(iOS)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    #endif
                    
                    // Auto-hide after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showExtendSuccess = false
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if showExtendSuccess {
                successBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showExtendSuccess)
            }
        }
    }
    
    // MARK: - Success Banner
    
    private var successBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            
            Text("Extended \(extendedInstanceName) by 2 hours")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.green)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
        .padding(.top, 8)
    }
    
    // MARK: - Login View
    
    private var loginView: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                loginHeader
                
                // Form
                loginForm
                
                // Login Button
                loginButton
                
                // Error Display
                if case .authError(let error) = suvBloc.state {
                    errorBanner(error: error)
                }
                
                // Help Section
                helpSection
            }
            .padding(24)
            .frame(maxWidth: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.15),
                    Color(red: 0.1, green: 0.15, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var loginHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.teal, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                
                Image(systemName: "server.rack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
            
            Text("SUVify")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Manage your Single-User Versions")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }
    
    private var loginForm: some View {
        VStack(spacing: 16) {
            // Username Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.white.opacity(0.5))
                    
                    TextField("Enter your AD username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .foregroundColor(.white)
                        .onSubmit {
                            performLogin()
                        }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white.opacity(0.5))
                    
                    SecureField("Enter your password", text: $password)
                        .textContentType(.password)
                        .foregroundColor(.white)
                        .onSubmit {
                            performLogin()
                        }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func performLogin() {
        guard suvBloc.state != .authenticating else { return }
        suvBloc.send(.login(username: username, password: password))
    }
    
    private var loginButton: some View {
        Button {
            performLogin()
        } label: {
            HStack(spacing: 12) {
                if suvBloc.state == .authenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: suvBloc.state == .authenticating
                        ? [Color.teal.opacity(0.5), Color.cyan.opacity(0.5)]
                        : [Color.teal, Color.cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.teal.opacity(0.3), radius: 10, y: 5)
        }
        .disabled(suvBloc.state == .authenticating)
    }
    
    private var helpSection: some View {
        VStack(spacing: 8) {
            Text("Use your Active Directory credentials")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "key.fill")
                    Text("Requires valid API key in Suvify.plist")
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Suvify.plist.example → Suvify.plist")
                }
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.4))
        }
        .padding(.top, 16)
    }
    
    // MARK: - Instances View
    
    private var instancesView: some View {
        VStack(spacing: 0) {
            // User Header
            if let user = suvBloc.state.currentUser {
                userHeader(user: user)
            }
            
            // Content
            Group {
                switch suvBloc.state {
                case .loadingInstances:
                    loadingView
                    
                case .loaded(_, let instances, _):
                    instancesList(instances: instances)
                    
                case .extending(_, let instances, let extendingId):
                    instancesList(instances: instances, extendingId: extendingId)
                    
                case .error(let error):
                    errorView(error: error)
                    
                default:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private func userHeader(user: SuvActiveDirectoryUser) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(user.userName)
                    .font(.headline)
            }
            
            Spacer()
            
            Button {
                suvBloc.send(.logout)
                username = ""
                password = ""
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading your SUV instances...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func instancesList(instances: [SuvInstance], extendingId: String? = nil) -> some View {
        Group {
            if instances.isEmpty {
                emptyInstancesView
            } else {
                List {
                    ForEach(instances) { instance in
                        instanceRow(instance: instance, isExtending: instance.id == extendingId)
                            .id("\(instance.id)-\(instance.wdAutoStopTime ?? "")")
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    suvBloc.send(.refreshInstances)
                }
                .animation(.easeInOut(duration: 0.3), value: instances.map { $0.wdAutoStopTime })
            }
        }
    }
    
    private var emptyInstancesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No SUV Instances")
                .font(.headline)
            
            Text("You don't have any SUV instances assigned.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                suvBloc.send(.refreshInstances)
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func instanceRow(instance: SuvInstance, isExtending: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(instance.instanceId)
                        .font(.system(.headline, design: .monospaced))
                    
                    Text(instance.wdDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                stateIndicator(for: instance)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                detailRow(icon: "globe", label: "Hostname", value: instance.wdHostname)
                
                if let stopTime = instance.wdAutoStopTime {
                    autoStopRow(stopTime: stopTime)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                Button {
                    #if os(iOS)
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    #endif
                    suvBloc.send(.extendInstance(instanceId: instance.id, hours: 2))
                } label: {
                    HStack {
                        if isExtending {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                        Text("Extend 2h")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .tint(.teal)
                .disabled(isExtending)
                .animation(.easeInOut(duration: 0.2), value: isExtending)
                
                Spacer()
                
                Button {
                    copyToClipboard(instance.wdHostname)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func stateIndicator(for instance: SuvInstance) -> some View {
        let state = instance.instanceState ?? .stopped
        let color: Color = state.isActive ? .green : .orange
        
        return HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(state.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 16)
                .foregroundColor(.secondary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }
    
    private func autoStopRow(stopTime: String) -> some View {
        let timeInfo = parseTimeRemaining(stopTime)
        let color = timeInfo.color
        
        return HStack(spacing: 8) {
            Image(systemName: timeInfo.icon)
                .frame(width: 16)
                .foregroundColor(color)
            
            Text("Auto-stop")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(timeInfo.text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
    
    private struct TimeRemainingInfo {
        let text: String
        let color: Color
        let icon: String
    }
    
    private func parseTimeRemaining(_ isoString: String) -> TimeRemainingInfo {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date: Date?
        date = formatter.date(from: isoString)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }
        
        guard let stopDate = date else {
            return TimeRemainingInfo(text: isoString, color: .secondary, icon: "clock")
        }
        
        let now = Date()
        let timeInterval = stopDate.timeIntervalSince(now)
        
        // Expired
        if timeInterval <= 0 {
            let elapsed = abs(timeInterval)
            let hours = Int(elapsed) / 3600
            let minutes = (Int(elapsed) % 3600) / 60
            
            let text: String
            if hours > 0 {
                text = "Expired \(hours)h \(minutes)m ago"
            } else if minutes > 0 {
                text = "Expired \(minutes)m ago"
            } else {
                text = "Expired just now"
            }
            return TimeRemainingInfo(text: text, color: .red, icon: "exclamationmark.circle.fill")
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        // Determine color based on time remaining
        let color: Color
        let icon: String
        if hours < 1 {
            color = .red
            icon = "exclamationmark.triangle.fill"
        } else if hours < 2 {
            color = .orange
            icon = "clock.badge.exclamationmark"
        } else {
            color = .green
            icon = "clock"
        }
        
        let text: String
        if hours > 0 {
            text = "\(hours)h \(minutes)m remaining"
        } else if minutes > 0 {
            text = "\(minutes)m remaining"
        } else {
            text = "Less than 1m"
        }
        
        return TimeRemainingInfo(text: text, color: color, icon: icon)
    }
    
    // MARK: - Error Views
    
    private func errorBanner(error: SuvifyError) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.red.opacity(0.8))
        .cornerRadius(12)
    }
    
    private func errorView(error: SuvifyError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                suvBloc.send(.refreshInstances)
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: isoString) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: isoString) else {
                return isoString
            }
            return formatTimeRemaining(until: date)
        }
        
        return formatTimeRemaining(until: date)
    }
    
    private func formatTimeRemaining(until date: Date) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)
        
        // If the date has passed
        if timeInterval <= 0 {
            let elapsed = abs(timeInterval)
            let hours = Int(elapsed) / 3600
            let minutes = (Int(elapsed) % 3600) / 60
            
            if hours > 0 {
                return "Expired \(hours)h \(minutes)m ago"
            } else if minutes > 0 {
                return "Expired \(minutes)m ago"
            } else {
                return "Expired just now"
            }
        }
        
        // Time remaining
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else if minutes > 0 {
            return "\(minutes)m remaining"
        } else {
            return "Less than 1m remaining"
        }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SUVView()
    }
}
