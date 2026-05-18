// HowlAlertPopover.swift
//
// MenuBarExtra popover surface. Matches Section B of docs/design/HowlAlert.html:
// 320pt-wide Liquid Glass dropdown — provider header, TwoBarMeter, PaceChip,
// ResetCountdown, model rows, action footer.

import SwiftUI
import HowlAlertKit

struct HowlAlertPopover: View {
    @Bindable var model: UsageViewModel
    @AppStorage("demoMode") private var demoMode: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.4)
            meterBlock
            Divider().opacity(0.4)
            modelList
            footer
        }
        .frame(width: 320)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: HowlRadius.lg, style: .continuous))
        .padding(HowlSpacing.s2)
        .onChange(of: demoMode) { _, new in
            model.setDemoMode(new)
        }
    }

    private var header: some View {
        HStack(spacing: HowlSpacing.s3) {
            WolfMark(tint: model.iconState.color, size: 18)
            VStack(alignment: .leading, spacing: 0) {
                Text("HowlAlert")
                    .font(.howlTitle2)
                    .foregroundStyle(Color.howlInk100)
                Text(demoMode ? "Demo Mode" : "Watching ~/.claude")
                    .font(.howlMicro)
                    .foregroundStyle(Color.howlInk500)
            }
            Spacer()
            StateIcon(state: model.iconState, size: 14)
        }
        .padding(.horizontal, HowlSpacing.s4)
        .padding(.vertical, HowlSpacing.s3)
    }

    private var meterBlock: some View {
        VStack(alignment: .leading, spacing: HowlSpacing.s3) {
            HStack(alignment: .top) {
                ResetCountdown(windowEnd: model.snapshot.window.windowEnd)
                Spacer()
                PaceChip(model.snapshot.projected.pace)
            }
            TwoBarMeter(
                reading: TwoBarMeter.Reading(
                    percentUsed: percentUsed,
                    percentProjected: model.snapshot.projected.percentProjected,
                    state: model.snapshot.projected.usageState,
                    projectedState: model.snapshot.projected.projectedState
                )
            )
        }
        .padding(.horizontal, HowlSpacing.s4)
        .padding(.vertical, HowlSpacing.s3)
    }

    @ViewBuilder
    private var modelList: some View {
        if model.snapshot.models.isEmpty {
            Text("No requests yet this window.")
                .font(.howlCaption)
                .foregroundStyle(Color.howlInk500)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, HowlSpacing.s4)
                .padding(.vertical, HowlSpacing.s3)
        } else {
            VStack(spacing: HowlSpacing.s1) {
                ForEach(model.snapshot.models) { m in
                    ModelRow(m)
                }
            }
            .padding(.horizontal, HowlSpacing.s4)
            .padding(.vertical, HowlSpacing.s2)
        }
    }

    private var footer: some View {
        HStack {
            SettingsLink {
                Label("Settings", systemImage: "gearshape")
                    .font(.howlCaption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.howlInk300)
            Spacer()
            Button {
                NSApp.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
                    .font(.howlCaption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.howlInk300)
        }
        .padding(.horizontal, HowlSpacing.s4)
        .padding(.vertical, HowlSpacing.s3)
    }

    private var percentUsed: Double {
        Double(model.snapshot.requestsSoFar) / Double(max(1, model.snapshot.planLimit))
    }
}
