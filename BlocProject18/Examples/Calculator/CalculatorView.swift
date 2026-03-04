//
//  CalculatorView.swift
//  BlocProject18
//

import Bloc
import SwiftUI

// MARK: - Root View

struct CalculatorView: View {
    let bloc = BlocRegistry.resolve(CalculatorBloc.self)

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                CalculatorPadView(bloc: bloc)
                    .frame(width: min(360, geo.size.width * 0.5))

                Divider()
                    .background(Color.white.opacity(0.08))

                LifecycleLogView(log: bloc.lifecycleLog)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.08),
                    Color(red: 0.07, green: 0.07, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationTitle("Calculator — Lifecycle Hooks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Calculator Pad

private struct CalculatorPadView: View {
    let bloc: CalculatorBloc

    private let buttonSpacing: CGFloat = 10

    var body: some View {
        VStack(spacing: 0) {
            DisplayView(state: bloc.state)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

            VStack(spacing: buttonSpacing) {
                // Row 1: AC, +/−, %, ÷
                HStack(spacing: buttonSpacing) {
                    CalcButton(label: bloc.state.hasError ? "AC" : "AC", style: .function) {
                        bloc.send(.clear)
                    }
                    CalcButton(label: "+/−", style: .function) { bloc.send(.toggleSign) }
                    CalcButton(label: "%",   style: .function) { bloc.send(.percentage) }
                    CalcButton(label: "÷",   style: .operation,
                               isActive: bloc.state.pendingOperation == .divide) {
                        bloc.send(.operation(.divide))
                    }
                }
                // Row 2: 7, 8, 9, ×
                HStack(spacing: buttonSpacing) {
                    CalcButton(label: "7", style: .digit) { bloc.send(.digit(7)) }
                    CalcButton(label: "8", style: .digit) { bloc.send(.digit(8)) }
                    CalcButton(label: "9", style: .digit) { bloc.send(.digit(9)) }
                    CalcButton(label: "×", style: .operation,
                               isActive: bloc.state.pendingOperation == .multiply) {
                        bloc.send(.operation(.multiply))
                    }
                }
                // Row 3: 4, 5, 6, −
                HStack(spacing: buttonSpacing) {
                    CalcButton(label: "4", style: .digit) { bloc.send(.digit(4)) }
                    CalcButton(label: "5", style: .digit) { bloc.send(.digit(5)) }
                    CalcButton(label: "6", style: .digit) { bloc.send(.digit(6)) }
                    CalcButton(label: "−", style: .operation,
                               isActive: bloc.state.pendingOperation == .subtract) {
                        bloc.send(.operation(.subtract))
                    }
                }
                // Row 4: 1, 2, 3, +
                HStack(spacing: buttonSpacing) {
                    CalcButton(label: "1", style: .digit) { bloc.send(.digit(1)) }
                    CalcButton(label: "2", style: .digit) { bloc.send(.digit(2)) }
                    CalcButton(label: "3", style: .digit) { bloc.send(.digit(3)) }
                    CalcButton(label: "+", style: .operation,
                               isActive: bloc.state.pendingOperation == .add) {
                        bloc.send(.operation(.add))
                    }
                }
                // Row 5: 0 (wide), ., ⌫, =
                HStack(spacing: buttonSpacing) {
                    CalcButton(label: "0", style: .digit, wide: true) { bloc.send(.digit(0)) }
                    CalcButton(label: ".", style: .digit)  { bloc.send(.decimal) }
                    CalcButton(label: "⌫", style: .function) { bloc.send(.delete) }
                    CalcButton(label: "=", style: .equals)   { bloc.send(.equals) }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Display

private struct DisplayView: View {
    let state: CalculatorState

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Pending operation indicator
            HStack {
                Spacer()
                if let op = state.pendingOperation {
                    Text(op.rawValue)
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .foregroundColor(.orange.opacity(0.8))
                        .transition(.opacity)
                }
            }
            .frame(height: 24)

            // Main display value
            Text(state.displayValue)
                .font(.system(size: displayFontSize(for: state.displayValue),
                              weight: .thin, design: .rounded))
                .foregroundStyle(
                    state.hasError
                        ? LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [.white, .white.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25), value: state.displayValue)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func displayFontSize(for value: String) -> CGFloat {
        switch value.count {
        case ..<7:  return 64
        case 7..<10: return 48
        default:     return 36
        }
    }
}

// MARK: - Button

private enum ButtonStyle { case digit, operation, function, equals }

private struct CalcButton: View {
    let label: String
    let style: ButtonStyle
    var isActive: Bool = false
    var wide: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.15)) { isPressed = true }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.2)) { isPressed = false }
            }
        }) {
            Text(label)
                .font(.system(size: 22, weight: labelWeight, design: .rounded))
                .foregroundColor(labelColor)
                .frame(maxWidth: wide ? .infinity : nil)
                .frame(width: wide ? nil : buttonSize, height: buttonSize)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(fillColor)
                        .shadow(color: shadowColor, radius: isPressed ? 2 : 6, y: isPressed ? 1 : 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(strokeColor, lineWidth: 0.5)
                )
                .scaleEffect(isPressed ? 0.93 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }

    private var buttonSize: CGFloat { 68 }

    private var fillColor: Color {
        switch style {
        case .digit:
            return Color(red: 0.18, green: 0.18, blue: 0.22)
        case .function:
            return Color(red: 0.28, green: 0.28, blue: 0.32)
        case .operation:
            return isActive
                ? Color(red: 1.0, green: 0.65, blue: 0.2).opacity(0.25)
                : Color(red: 0.95, green: 0.6, blue: 0.1)
        case .equals:
            return Color(red: 0.2, green: 0.75, blue: 0.5)
        }
    }

    private var labelColor: Color {
        switch style {
        case .digit, .equals, .operation: return .white
        case .function: return Color(red: 0.9, green: 0.9, blue: 0.95)
        }
    }

    private var labelWeight: Font.Weight {
        style == .digit ? .regular : .semibold
    }

    private var strokeColor: Color {
        switch style {
        case .operation: return isActive ? Color.orange.opacity(0.6) : Color.orange.opacity(0.2)
        default:         return Color.white.opacity(0.06)
        }
    }

    private var shadowColor: Color {
        switch style {
        case .equals:    return Color.green.opacity(0.3)
        case .operation: return Color.orange.opacity(0.2)
        default:         return Color.black.opacity(0.3)
        }
    }
}

// MARK: - Lifecycle Log Panel

private struct LifecycleLogView: View {
    let log: BlocLifecycleLog

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lifecycle Log")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(log.entries.count) events")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                // Legend pills
                HStack(spacing: 6) {
                    ForEach([
                        BlocLifecycleLog.LogEntry.Kind.event,
                        .change,
                        .transition,
                        .error
                    ], id: \.label) { kind in
                        HStack(spacing: 4) {
                            Image(systemName: kind.symbol)
                                .font(.system(size: 9, weight: .bold))
                            Text(kind.label)
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(kind.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(kind.color.opacity(0.12))
                        )
                    }
                }

                Button {
                    withAnimation { log.clear() }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.03))

            Divider().background(Color.white.opacity(0.08))

            // Log entries
            if log.entries.isEmpty {
                emptyState
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(log.entries) { entry in
                                LogEntryRow(entry: entry)
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
            Text("No events yet")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
            Text("Tap a button on the calculator\nto watch the lifecycle hooks fire.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.18))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Log Entry Row

private struct LogEntryRow: View {
    let entry: BlocLifecycleLog.LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Kind badge
            HStack(spacing: 4) {
                Image(systemName: entry.kind.symbol)
                    .font(.system(size: 9, weight: .bold))
                Text(entry.kind.label)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
            }
            .foregroundColor(entry.kind.color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(entry.kind.color.opacity(0.12))
            )
            .frame(width: 100, alignment: .leading)

            // Message
            Text(entry.message)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // Timestamp
            Text(entry.timestamp.logTimestamp)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(entry.kind == .error ? Color.red.opacity(0.06) : Color.clear)
        .overlay(alignment: .bottom) {
            Divider().background(Color.white.opacity(0.04))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BlocProvider(with: [CalculatorBloc()]) {
            CalculatorView()
        }
    }
    .frame(width: 800, height: 600)
}
