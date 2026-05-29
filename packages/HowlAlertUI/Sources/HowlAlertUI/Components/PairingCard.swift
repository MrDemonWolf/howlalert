import SwiftUI

/// Pairing card — QR (supply your own `Image`, else a placeholder) + 6-digit fallback code.
public struct PairingCard: View {
    private let code: String
    private let qr: Image?

    public init(code: String, qr: Image? = nil) {
        self.code = code
        self.qr = qr
    }

    public var body: some View {
        VStack(spacing: HowlSpacing.s3) {
            Group {
                if let qr {
                    qr.resizable().interpolation(.none).scaledToFit()
                } else {
                    Image(systemName: "qrcode")
                        .resizable().scaledToFit()
                        .foregroundStyle(HowlColor.navy900)
                        .padding(HowlSpacing.s3)
                }
            }
            .frame(width: 120, height: 120)
            .background(.white, in: RoundedRectangle(cornerRadius: HowlRadius.md, style: .continuous))

            Text(code)
                .font(HowlTypography.numeric(size: 22, weight: .semibold))
                .tracking(4)
                .foregroundStyle(HowlColor.ink100)
        }
        .padding(HowlSpacing.s5)
        .background(HowlColor.navy800, in: RoundedRectangle(cornerRadius: HowlRadius.lg, style: .continuous))
    }
}
