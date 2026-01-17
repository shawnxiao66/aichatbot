import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    private struct Plan: Identifiable {
        let id = UUID()
        let title: String
        let price: String
        let diamonds: String
        let value: String
        let highlight: Bool
    }

    private let plans: [Plan] = [
        Plan(
            title: "Monthly",
            price: "$9.99",
            diamonds: "4,000 💎",
            value: "2000 messages • 80 images",
            highlight: false
        ),
        Plan(
            title: "Quarterly",
            price: "$19.99",
            diamonds: "10,000 💎",
            value: "5000 messages • 200 images",
            highlight: true
        ),
        Plan(
            title: "Yearly",
            price: "$49.99",
            diamonds: "30,000 💎",
            value: "15,000 messages • 600 images",
            highlight: false
        )
    ]

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerView

                        VStack(spacing: 14) {
                            ForEach(plans) { plan in
                                planCard(plan)
                            }
                        }
                        .padding(.horizontal, 20)

                        primaryButton
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        Text("Mock purchase only. No charge will be made.")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textMuted)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 10) {
            Text("Get Diamonds")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text("Unlock more chats and gallery views.")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private func planCard(_ plan: Plan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plan.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(plan.price)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }

            Text(plan.diamonds)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.accentPrimary)

            Text(plan.value)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(plan.highlight ? AppColors.cardBackground.opacity(0.95) : AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(plan.highlight ? AppColors.accentPrimary.opacity(0.7) : AppColors.border.opacity(0.6), lineWidth: 1)
        )
    }

    private var primaryButton: some View {
        Button(action: {}) {
            Text("Continue")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.accentPrimary.opacity(0.9),
                            AppColors.accentSecondary.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(14)
        }
    }
}

#Preview {
    PaywallView()
        .preferredColorScheme(.dark)
}
