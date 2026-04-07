import SwiftUI

struct CountdownRingView: View {
    let remaining: Int
    let period: Int

    private var progress: Double { Double(remaining) / Double(period) }
    private var isUrgent: Bool { remaining <= 5 }
    private var isCritical: Bool { remaining <= 3 }

    private var ringColor: Color {
        if isCritical { return .red }
        if isUrgent { return .orange }
        return .orange.opacity(0.7)
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(.quaternary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 24, height: 24)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remaining)

            // Number
            Text("\(remaining)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(isCritical ? .red : .secondary)
        }
        .opacity(isCritical ? (remaining % 2 == 0 ? 0.6 : 1.0) : 1.0)
        .animation(.easeInOut(duration: 0.3), value: remaining)
    }
}
