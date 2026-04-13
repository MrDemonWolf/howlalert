// PaywallView — RevenueCat subscription screen
// © 2026 MrDemonWolf, Inc.

import SwiftUI
import RevenueCat
import Config

struct PaywallView: View {
    @State private var offerings: Offerings?
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    let onPurchaseComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("🐺")
                    .font(.system(size: 56))
                Text("HowlAlert Pro")
                    .font(.title.bold())
                Text("Unlock the full experience")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 32)

            // Trial badge
            Text("7-day free trial")
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#0FACED").opacity(0.2))
                .foregroundStyle(Color(hex: "#0FACED"))
                .clipShape(Capsule())

            // Plan options
            if let offering = offerings?.current {
                VStack(spacing: 12) {
                    ForEach(offering.availablePackages, id: \.identifier) { pkg in
                        PlanCard(
                            package: pkg,
                            isSelected: selectedPackage?.identifier == pkg.identifier
                        ) {
                            selectedPackage = pkg
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                ProgressView("Loading plans...")
            }

            Spacer()

            // Subscribe button
            if let pkg = selectedPackage {
                Button {
                    Task { await purchase(pkg) }
                } label: {
                    Group {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Start Free Trial")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#0FACED"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isPurchasing)
                .padding(.horizontal)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            // Restore + legal
            VStack(spacing: 8) {
                Button("Restore Purchases") {
                    Task { await restore() }
                }
                .font(.caption)

                Text("Payment charged to Apple ID at confirmation. Auto-renews unless cancelled 24h before period ends.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 16) {
                    Link("Privacy", destination: HowlAlertConstants.privacyURL)
                    Link("Terms", destination: HowlAlertConstants.termsURL)
                }
                .font(.caption2)
            }
            .padding(.bottom, 16)
        }
        .background(Color(hex: "#091533").ignoresSafeArea())
        .foregroundStyle(.white)
        .task {
            await loadOfferings()
        }
    }

    private func loadOfferings() async {
        do {
            offerings = try await Purchases.shared.offerings()
            selectedPackage = offerings?.current?.availablePackages.first
        } catch {
            errorMessage = "Could not load plans"
        }
    }

    private func purchase(_ package: Package) async {
        isPurchasing = true
        errorMessage = nil
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                // Write entitlement to CloudKit for macOS pickup
                let syncManager = CloudKitSyncManager()
                let state = EntitlementState(
                    entitlementActive: true,
                    expiresAt: result.customerInfo.entitlements[HowlAlertConstants.revenueCatEntitlement]?.expirationDate,
                    productID: package.storeProduct.productIdentifier,
                    updatedAt: .now
                )
                try? await syncManager.saveEntitlement(state)
                onPurchaseComplete()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    private func restore() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            if info.entitlements[HowlAlertConstants.revenueCatEntitlement]?.isActive == true {
                onPurchaseComplete()
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }
}

struct PlanCard: View {
    let package: Package
    let isSelected: Bool
    let onTap: () -> Void

    private var isAnnual: Bool {
        package.storeProduct.productIdentifier.contains("annual")
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(isAnnual ? "Annual" : "Monthly")
                            .font(.headline)
                        if isAnnual {
                            Text("Save 25%")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#0FACED").opacity(0.3))
                                .clipShape(Capsule())
                        }
                    }
                    Text(package.localizedPriceString + (isAnnual ? "/year" : "/month"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color(hex: "#0FACED") : .secondary)
                    .font(.title2)
            }
            .padding()
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "#0FACED") : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
