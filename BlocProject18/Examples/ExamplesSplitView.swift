//
//  ExamplesSplitView.swift
//  BlocProject
//
//  Created by Sergio Fraile Carmena on 02/07/2025.
//

import Bloc
import SwiftUI

#if DEBUG
import PulseUI
#endif

struct ExamplesSplitView: View {
    
    @State var selection: Examples? = nil
    @State var isConsoleViewPresenting = false
    @State private var hoveredItem: NavigationOptions? = nil
    @State private var showClearConfirm = false
    @State private var clearFeedback = false
    
    var body: some View {
        NavigationSplitView {
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.08, blue: 0.12),
                        Color(red: 0.05, green: 0.05, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Navigation Items
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(NavigationOptions.mainPages) { page in
                                NavigationLink(value: page) {
                                    ExampleRowView(
                                        page: page,
                                        isHovered: hoveredItem == page
                                    )
                                }
                                .buttonStyle(.plain)
                                .onHover { isHovered in
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        hoveredItem = isHovered ? page : nil
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // Footer
                    footerView
                }
            }
            .navigationDestination(for: NavigationOptions.self) { page in
                page.viewForPage()
            }
        } detail: {
            WelcomeDetailView()
        }
        .toolbar {
            #if DEBUG
            ToolbarItem(placement: .automatic) {
                Button("Pulse Console", systemImage: "stethoscope") {
                    isConsoleViewPresenting = true
                }
                .buttonStyle(.bordered)
            }
            #endif
        }
        .sheet(isPresented: $isConsoleViewPresenting) {
            #if DEBUG
            NavigationStack {
                ConsoleView()
                    .navigationTitle("Pulse Console")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                isConsoleViewPresenting = false
                            }
                        }
                    }
                    #else
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isConsoleViewPresenting = false
                            }
                        }
                    }
                    #endif
            }
            .frame(minWidth: 600, minHeight: 500)
            #endif
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "cube.transparent.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 2)
                
                Text("Bloc Examples")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            Text("State Management Patterns")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .tracking(1.5)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.03),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var footerView: some View {
        VStack(spacing: 8) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            #if DEBUG
            // Pulse Console Button
            Button {
                isConsoleViewPresenting = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Pulse Console")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.pink.opacity(0.4), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.top, 4)
            #endif
            
            // Clear All Hydrated Storage
            Button {
                showClearConfirm = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: clearFeedback ? "checkmark.circle.fill" : "externaldrive.badge.minus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(clearFeedback ? .green : .cyan.opacity(0.8))

                    Text(clearFeedback ? "Storage cleared!" : "Clear Hydrated Storage")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(clearFeedback ? .green : .white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(clearFeedback ? Color.green.opacity(0.1) : Color.cyan.opacity(0.07))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(clearFeedback ? Color.green.opacity(0.4) : Color.cyan.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .confirmationDialog(
                "Clear all hydrated state?",
                isPresented: $showClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Clear & Reset All", role: .destructive) {
                    // Reset every registered HydratedBloc to its initial state.
                    // Using AnyHydratedBloc avoids importing concrete types here.
                    BlocRegistry.resetAllHydratedBlocs()
                    withAnimation { clearFeedback = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { clearFeedback = false }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This calls resetToInitialState() on every HydratedBloc — storage is cleared and each Bloc immediately emits its initial state. Rehydration is creation-time only: this is the equivalent of starting the next session clean, applied right now.")
            }

            HStack(spacing: 6) {
                Image(systemName: "swift")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Built with Swift")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Example Row View

struct ExampleRowView: View {
    let page: NavigationOptions
    let isHovered: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: page.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(
                        color: page.gradientColors.first?.opacity(isHovered ? 0.5 : 0.25) ?? .clear,
                        radius: isHovered ? 8 : 4,
                        x: 0,
                        y: 2
                    )
                
                Image(systemName: page.symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(page.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(page.subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .opacity(isHovered ? 1 : 0.5)
                .offset(x: isHovered ? 2 : 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    isHovered
                        ? Color.white.opacity(0.08)
                        : Color.white.opacity(0.03)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: isHovered
                            ? [page.gradientColors.first?.opacity(0.4) ?? .clear, .clear]
                            : [.clear, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }
}

// MARK: - Welcome Detail View

struct WelcomeDetailView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated background
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.1),
                    Color(red: 0.08, green: 0.08, blue: 0.14)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            VStack(spacing: 24) {
                // Floating cubes animation
                ZStack {
                    ForEach(0..<3) { index in
                        Image(systemName: "cube.fill")
                            .font(.system(size: 40 - CGFloat(index * 8)))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.8 - Double(index) * 0.2), .purple.opacity(0.6 - Double(index) * 0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .offset(x: CGFloat(index * 15), y: CGFloat(index * 10))
                            .opacity(1 - Double(index) * 0.2)
                    }
                }
                .shadow(color: .cyan.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 12) {
                    Text("Welcome to Bloc Examples")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("Select an example from the sidebar to explore different state management patterns")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                }
                
                // Feature pills
                HStack(spacing: 12) {
                    FeaturePill(icon: "bolt.fill", text: "Reactive", color: .yellow)
                    FeaturePill(icon: "arrow.triangle.2.circlepath", text: "Predictable", color: .cyan)
                    FeaturePill(icon: "checkmark.seal.fill", text: "Testable", color: .green)
                }
                .padding(.top, 8)
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ExamplesSplitView()
}
