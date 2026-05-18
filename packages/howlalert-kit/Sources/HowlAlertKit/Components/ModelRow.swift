// ModelRow.swift
//
// Per-model usage row in the popover model list.
// icon · name · sessions · % of window.

import SwiftUI

public struct ModelRow: View {
    public struct Model: Sendable, Equatable, Identifiable {
        public let id: String
        public let name: String
        public let sessions: Int
        public let percentOfWindow: Double

        public init(id: String, name: String, sessions: Int, percentOfWindow: Double) {
            self.id = id
            self.name = name
            self.sessions = sessions
            self.percentOfWindow = percentOfWindow
        }
    }

    private let model: Model

    public init(_ model: Model) {
        self.model = model
    }

    public var body: some View {
        HStack(spacing: HowlSpacing.s3) {
            RoundedRectangle(cornerRadius: HowlRadius.sm, style: .continuous)
                .fill(Color.howlCyan500.opacity(0.18))
                .frame(width: 22, height: 22)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.howlCyan300)
                )
            VStack(alignment: .leading, spacing: 1) {
                Text(model.name)
                    .font(.howlTitle2)
                    .foregroundStyle(Color.howlInk100)
                Text("\(model.sessions) session\(model.sessions == 1 ? "" : "s")")
                    .font(.howlCaption)
                    .foregroundStyle(Color.howlInk500)
            }
            Spacer(minLength: HowlSpacing.s2)
            Text("\(Int((max(0, min(1, model.percentOfWindow))) * 100))%")
                .font(.howlCaption)
                .monospacedDigit()
                .foregroundStyle(Color.howlInk300)
        }
        .padding(.vertical, HowlSpacing.s1)
        .accessibilityElement(children: .combine)
    }
}
