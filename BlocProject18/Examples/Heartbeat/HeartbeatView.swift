//
//  HeartbeatView.swift
//  BlocProject18
//
//  Demonstrates **scoped Bloc lifecycle management**.
//
//  HeartbeatBloc is NOT registered in BlocProvider — it is created directly
//  using @State so its lifetime is tied to this view. onAppear starts the
//  ticker; onDisappear calls close(), which cancels the async task immediately
//  and fires onClose(). Navigate away and back to see a fresh Bloc start from zero.
//

import Bloc
import SwiftUI

// MARK: - Root View

struct HeartbeatView: View {

    /// The Bloc is owned by this view, not the global BlocProvider.
    /// A new instance is created each time the view appears from scratch.
    @State private var bloc = HeartbeatBloc()

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                MonitorPanel(bloc: bloc) {
                    // "New Session" — explicitly close the current Bloc and start fresh.
                    bloc.close()
                    bloc = HeartbeatBloc()
                    bloc.send(.start)
                }
                .frame(width: min(380, geo.size.width * 0.5))

                Divider().background(Color.white.opacity(0.08))

                LifecycleLogPanel(bloc: bloc)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.10),
                    Color(red: 0.06, green: 0.04, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .safeAreaInset(edge: .top, spacing: 0) {
            LifecycleFeatureBanner()
        }
        .navigationTitle("Heartbeat — Scoped Lifecycle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Only start if the bloc is fresh (not already running from a previous appear).
            if !bloc.state.isRunning && !bloc.isClosed {
                bloc.send(.start)
            }
        }
        .onDisappear {
            // Close the Bloc when the screen is dismissed. This is the key
            // pattern for scoped Blocs: tie close() to the view's disappearance.
            bloc.close()
        }
    }
}

// MARK: - Monitor Panel

private struct MonitorPanel: View {
    let bloc: HeartbeatBloc
    let onNewSession: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Pulsing ring animation
            PulseRing(tickCount: bloc.state.tickCount, isClosed: bloc.isClosed)
                .frame(width: 200, height: 200)

            Spacer().frame(height: 32)

            // Session stats
            VStack(spacing: 8) {
                Text(bloc.isClosed ? "CLOSED" : bloc.state.formattedDuration)
                    .font(.system(size: 48, weight: .thin, design: .monospaced))
                    .foregroundColor(bloc.isClosed ? .orange : .white)
                    .animation(.easeInOut(duration: 0.3), value: bloc.isClosed)
                    .contentTransition(.numericText())

                Text(bloc.isClosed
                     ? "Navigate away to close automatically"
                     : "\(bloc.state.tickCount) tick\(bloc.state.tickCount == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer().frame(height: 40)

            // Explanation card
            VStack(alignment: .leading, spacing: 10) {
                Label("Scoped Bloc Pattern", systemImage: "info.circle")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))

                Text("This Bloc is **not** in BlocProvider. It is owned by the view via `@State` — created on appear, closed on disappear. Navigate away to trigger `close()` automatically, or tap New Session below.")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 28)

            Spacer().frame(height: 24)

            // New Session button
            Button(action: onNewSession) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("New Session")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.7, blue: 1.0),
                                    Color(red: 0.1, green: 0.5, blue: 0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(red: 0.1, green: 0.5, blue: 0.9).opacity(0.4), radius: 8, y: 4)
                )
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Pulse Ring Animation

private struct PulseRing: View {
    let tickCount: Int
    let isClosed: Bool

    /// Each tick increments this, driving the ripple animation.
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Outer ripple rings — animate on each tick
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        isClosed ? Color.orange.opacity(0.15) : Color(red: 0.3, green: 0.85, blue: 0.6).opacity(0.2 - Double(i) * 0.05),
                        lineWidth: 1.5
                    )
                    .scaleEffect(pulse ? 1.0 + CGFloat(i + 1) * 0.25 : 1.0)
                    .opacity(pulse ? 0 : 1)
                    .animation(
                        .easeOut(duration: 0.9).delay(Double(i) * 0.15),
                        value: pulse
                    )
            }

            // Core circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: isClosed
                            ? [Color.orange.opacity(0.3), Color.orange.opacity(0.05)]
                            : [Color(red: 0.2, green: 0.85, blue: 0.55).opacity(0.4),
                               Color(red: 0.1, green: 0.5, blue: 0.35).opacity(0.1)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            isClosed ? Color.orange.opacity(0.5) : Color(red: 0.3, green: 0.9, blue: 0.6).opacity(0.6),
                            lineWidth: 1.5
                        )
                )
                .scaleEffect(pulse ? 1.04 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: pulse)

            // Icon
            Image(systemName: isClosed ? "xmark.circle" : "waveform.path.ecg")
                .font(.system(size: 32, weight: .thin))
                .foregroundColor(isClosed ? .orange.opacity(0.7) : Color(red: 0.3, green: 0.9, blue: 0.6).opacity(0.8))
                .animation(.easeInOut(duration: 0.3), value: isClosed)
        }
        .onChange(of: tickCount) { _, _ in
            guard !isClosed else { return }
            pulse = false
            withAnimation { pulse = true }
        }
    }
}

// MARK: - Lifecycle Log Panel

private struct LifecycleLogPanel: View {
    let bloc: HeartbeatBloc

    private var log: BlocLifecycleLog { bloc.lifecycleLog }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Lifecycle Log")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(bloc.isClosed ? Color.orange : Color.green)
                                .frame(width: 6, height: 6)
                            Text(bloc.isClosed ? "CLOSED" : "ACTIVE")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(bloc.isClosed ? .orange : .green)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill((bloc.isClosed ? Color.orange : Color.green).opacity(0.12))
                        )
                    }
                    Text("\(log.entries.count) events")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                Button {
                    withAnimation { log.clear() }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.03))

            Divider().background(Color.white.opacity(0.08))

            if log.entries.isEmpty {
                emptyState
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(log.entries) { entry in
                                LogRow(entry: entry)
                                    .id(entry.id)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onChange(of: log.entries.count) { _, _ in
                        if let last = log.entries.last {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 36, weight: .thin))
                .foregroundColor(.white.opacity(0.15))
            Text("Starting…")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Log Row

private struct LogRow: View {
    let entry: BlocLifecycleLog.LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: entry.kind.symbol)
                    .font(.system(size: 9, weight: .bold))
                Text(entry.kind.label)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
            }
            .foregroundColor(entry.kind.color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 4).fill(entry.kind.color.opacity(0.12)))
            .frame(width: 90, alignment: .leading)

            Text(entry.message)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Text(entry.timestamp.logTimestamp)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            entry.kind == .close ? Color.orange.opacity(0.06) : Color.clear
        )
        .overlay(alignment: .bottom) {
            Divider().background(Color.white.opacity(0.04))
        }
    }
}

// MARK: - Feature Disclaimer Banner

/// A non-intrusive banner that contextualises what feature this screen demonstrates.
private struct LifecycleFeatureBanner: View {
    @State private var expanded = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.85, blue: 0.6), Color(red: 0.1, green: 0.65, blue: 0.5)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )

                if expanded {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Demonstrates: close() — Lifecycle Management")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))

                        Text("This Bloc is **not** in BlocProvider. It is scoped to this screen via `@State`. Navigate away and the Bloc is closed automatically via `onDisappear { bloc.close() }`. Return to see a fresh Bloc start from zero. Tap **New Session** to close and recreate the Bloc inline.")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.55))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    Text("close() — Lifecycle Management")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { expanded.toggle() }
                } label: {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.35))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().background(Color.white.opacity(0.08))
        }
        .background(
            Color(red: 0.1, green: 0.2, blue: 0.15).opacity(0.85)
                .overlay(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.85, blue: 0.6).opacity(0.08), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HeartbeatView()
    }
    .frame(width: 800, height: 600)
}
