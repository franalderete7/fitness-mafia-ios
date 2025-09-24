//
//  PaywallView.swift
//  FitnessMafia
//
//  Recreated by Assistant on 23/09/2025.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager

    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var offering: Offering?
    @State private var purchasingIdentifier: String?
    @State private var selectedPlan: Plan = .annual
    @State private var isAnimatingCTA: Bool = false
    @State private var isFinalizing: Bool = false
    @State private var animateArrow: Bool = false

    // Provided configuration
    private let entitlementId: String = "Pro"
    private let offeringId: String = "default"
    // Prefer explicit product identifiers, but gracefully fall back to RevenueCat shorthand
    private let monthlyProductId: String = "com.vibelabs.fitnessmafia.pro.monthly"
    private let annualProductId: String = "com.vibelabs.fitnessmafia.pro.annual"
    private let monthlyIdentifierFallback: String = "$rc_monthly"
    private let annualIdentifierFallback: String = "$rc_annual"

    enum Plan { case monthly, annual }

    var body: some View {
        NavigationView {
            ZStack {
                // Premium gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.9), Color(.systemTeal).opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()

                if isLoading {
                    ProgressView("Cargando ofertas…")
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("No se pudieron cargar las suscripciones")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Button("Reintentar", action: loadOfferings)
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Hero header
                            VStack(spacing: 10) {
                                Text("Transforma tu cuerpo. Domina tu rutina.")
                                    .font(.system(size: 28, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                Text("Accede a planes premium y rutinas personalizadas")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                            // Glass card content
                            VStack(spacing: 18) {
                                // Benefits list
                                VStack(alignment: .leading, spacing: 10) {
                                    BenefitRow(text: "Programas premium nuevos cada mes")
                                    BenefitRow(text: "Rutinas personalizadas para tus objetivos")
                                    BenefitRow(text: "Estadísticas avanzadas y progreso visible")
                                    BenefitRow(text: "Acceso completo sin anuncios")
                                }

                                // Plans selector
                                if let monthly = findPackageByIds(primary: monthlyProductId, fallback: monthlyIdentifierFallback, type: .monthly),
                                   let annual = findPackageByIds(primary: annualProductId, fallback: annualIdentifierFallback, type: .annual) {
                                    PlanSelector(
                                        selected: $selectedPlan,
                                        monthly: monthly,
                                        annual: annual
                                    )
                                }

                                // CTA
                                if let targetPackage = packageForSelectedPlan() {
                                    VStack(spacing: 8) {
                                        Button(action: {
                                            Haptics.tap()
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                                isAnimatingCTA = true
                                            }
                                            Task { await purchase(targetPackage.pkg, identifier: targetPackage.identifier) }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                                isAnimatingCTA = false
                                            }
                                        }) {
                                            HStack {
                                                Text(ctaTitle(for: targetPackage.pkg))
                                                    .font(.headline.weight(.bold))
                                                Spacer()
                                                if purchasingIdentifier == targetPackage.identifier {
                                                    ProgressView().tint(.white)
                                                } else {
                                                     Image(systemName: "arrow.right.circle.fill")
                                                        .font(.title2)
                                                        .scaleEffect(animateArrow ? 1.2 : 1.0)
                                                        .offset(x: animateArrow ? 6 : 0)
                                                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateArrow)
                                                }
                                            }
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(
                                                LinearGradient(
                                                    colors: [Color(.systemTeal), Color(.systemBlue)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(14)
                                            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                                            .scaleEffect(isAnimatingCTA ? 0.98 : 1.0)
                                            .accessibilityLabel("Continuar con suscripción")
                                            .accessibilityHint("Proceder al pago del plan seleccionado")
                                        }
                                        .onAppear { animateArrow = true }

                                        // Risk-free copy
                                        Text("Prueba sin riesgo. Cancela cuando quieras.")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                            .accessibilityLabel("Prueba sin riesgo, cancela cuando quieras")
                                    }
                                }

                                // Restore & manage
                                HStack {
                                    Button("Restaurar compras") { Task { await restorePurchases() } }
                                        .buttonStyle(.plain)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Button("Gestionar suscripción") { Task { try? await Purchases.shared.showManageSubscriptions() } }
                                        .buttonStyle(.plain)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 6)
                            }
                            .padding(20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .padding(.horizontal, 20)

                            // Legal / footer
                            Text("Los precios pueden variar según la región. Los pagos se cargarán a tu cuenta de Apple. La suscripción se renueva automáticamente salvo cancelación 24h antes del fin del periodo.")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.75))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                        }
                        .padding(.top, 8)
                    }
                }
                
                // Finalizing overlay
                if isFinalizing {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                        Text("Activando Pro…")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { Haptics.light(); dismiss() }) {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.15), in: Circle())
                    }
                    .accessibilityLabel("Cerrar paywall")
                }
            }
        }
        .task { loadOfferings() }
        .onChange(of: authManager.currentUser?.isPremium) { _, isPremium in
            // Auto-dismiss when user becomes premium
            if isPremium == true {
                dismiss()
            }
        }
    }

    private func loadOfferings() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let offerings = try await Purchases.shared.offerings()
                // Prefer current; fall back to explicit id
                if let current = offerings.current {
                    offering = current
                } else {
                    offering = offerings.all[offeringId]
                }
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func findPackage(id: String, type: PackageType) -> Package? {
        guard let offering else { return nil }
        if let byId = offering.package(identifier: id) { return byId }
        return offering.availablePackages.first { $0.packageType == type }
    }

    private func findPackageByIds(primary: String, fallback: String, type: PackageType) -> Package? {
        if let pkg = findPackage(id: primary, type: type) { return pkg }
        return findPackage(id: fallback, type: type)
    }

    private func pricingSubtitle(for pkg: Package) -> String {
        let sp = pkg.storeProduct
        var parts: [String] = []
        parts.append(sp.localizedPriceString)
        if sp.introductoryDiscount != nil {
            parts.append("Oferta de introducción disponible")
        }
        if sp.subscriptionPeriod?.unit == .month, sp.subscriptionPeriod?.value == 1 {
            parts.append("al mes")
        } else if sp.subscriptionPeriod?.unit == .year, sp.subscriptionPeriod?.value == 1 {
            parts.append("al año")
        }
        return parts.joined(separator: " · ")
    }

    private func packageForSelectedPlan() -> (pkg: Package, identifier: String)? {
        if selectedPlan == .annual,
           let annual = findPackageByIds(primary: annualProductId, fallback: annualIdentifierFallback, type: .annual) {
            return (annual, annualProductId)
        }
        if let monthly = findPackageByIds(primary: monthlyProductId, fallback: monthlyIdentifierFallback, type: .monthly) {
            return (monthly, monthlyProductId)
        }
        return nil
    }

    private func ctaTitle(for pkg: Package) -> String {
        if pkg.packageType == .annual {
            if let monthlyPkg = findPackageByIds(primary: monthlyProductId, fallback: monthlyIdentifierFallback, type: .monthly) {
                let percent = PlanSelector.savingsPercent(annual: pkg, monthly: monthlyPkg)
                return "Continuar con Pro anual (\(percent)% OFF)"
            }
            return "Continuar con Pro anual"
        }
        if pkg.packageType == .monthly {
            return "Continuar con Pro mensual"
        }
        return "Continuar"
    }

    private func monthlyBreakdown(for annual: Package) -> String {
        let sp = annual.storeProduct
        guard let formatter = sp.priceFormatter else { return "" }
        let perMonth = (sp.price as NSDecimalNumber).decimalValue / 12
        let number = NSDecimalNumber(decimal: perMonth)
        return formatter.string(from: number) ?? ""
    }

    private func savingsBadgeText(annual: Package, monthly: Package) -> String {
        let annualTotal = (annual.storeProduct.price as NSDecimalNumber).decimalValue
        let monthlyPrice = (monthly.storeProduct.price as NSDecimalNumber).decimalValue
        guard monthlyPrice > 0 else { return "" }
        let perMonthAnnual = annualTotal / 12
        let savings = 1 - (perMonthAnnual / monthlyPrice)
        let percentDouble = (NSDecimalNumber(decimal: savings).doubleValue * 100.0).rounded()
        let percent = max(0, Int(percentDouble))
        return percent > 0 ? "Ahorra \(percent)%" : ""
    }

    private func purchase(_ pkg: Package, identifier: String) async {
        purchasingIdentifier = identifier
        defer { purchasingIdentifier = nil }
        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            let info = result.customerInfo
            let active = info.entitlements[entitlementId]?.isActive == true
            if active {
                await finalizeAndDismiss()
            }
        } catch {
            Haptics.error()
            errorMessage = error.localizedDescription
        }
    }

    private func restorePurchases() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            let active = info.entitlements[entitlementId]?.isActive == true
            if active {
                await finalizeAndDismiss()
            }
        } catch {
            Haptics.error()
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func setFinalizing(_ value: Bool) {
        isFinalizing = value
    }

    private func finalizeAndDismiss() async {
        Haptics.success()
        await setFinalizing(true)
        // Fetch latest user state so is_premium changes are reflected immediately
        await authManager.loadUserProfile()
        // The onChange listener will auto-dismiss when isPremium becomes true
        await setFinalizing(false)
    }
}

private struct BenefitRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
            Text(text)
                .foregroundColor(.primary)
                .accessibilityLabel(text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PlanSelector: View {
    @Binding var selected: PaywallView.Plan
    let monthly: Package
    let annual: Package

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                PlanCard(
                    title: "Mensual",
                    price: monthly.storeProduct.localizedPriceString,
                    subline: "Pago cada mes",
                    badge: nil,
                    isSelected: selected == .monthly
                ) {
                    Haptics.light()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selected = .monthly
                    }
                }

                PlanCard(
                    title: "Anual",
                    price: annual.storeProduct.localizedPriceString,
                    subline: perMonthText(annual: annual, monthly: monthly),
                    badge: PlanCard.bestValueBadge(annual: annual, monthly: monthly),
                    isSelected: selected == .annual
                ) {
                    Haptics.light()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selected = .annual
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func perMonthText(annual: Package, monthly: Package) -> String {
        let sp = annual.storeProduct
        guard let formatter = sp.priceFormatter else { return "Mejor valor" }
        let perMonth = (sp.price as NSDecimalNumber).decimalValue / 12
        let number = NSDecimalNumber(decimal: perMonth)
        let perMonthString = formatter.string(from: number) ?? ""
        let savings = PlanSelector.savingsPercent(annual: annual, monthly: monthly)
        return "\(perMonthString)/mes · Ahorra \(savings)%"
    }

    static func savingsPercent(annual: Package, monthly: Package) -> Int {
        let annualTotal = (annual.storeProduct.price as NSDecimalNumber).decimalValue
        let monthlyPrice = (monthly.storeProduct.price as NSDecimalNumber).decimalValue
        guard monthlyPrice > 0 else { return 0 }
        let perMonthAnnual = annualTotal / 12
        let savings = 1 - (perMonthAnnual / monthlyPrice)
        let percentDouble = (NSDecimalNumber(decimal: savings).doubleValue * 100.0).rounded()
        return max(0, Int(percentDouble))
    }
}

private struct PlanCard: View {
    let title: String
    let price: String
    let subline: String
    let badge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    if let badge {
                        Text(badge)
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemTeal), in: Capsule())
                            .accessibilityLabel("Mejor valor")
                    }
                }
                Text(price)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                Text(subline)
                    .font(.caption)
                        .foregroundColor(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.thinMaterial)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                }
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.25 : 0.1), radius: isSelected ? 12 : 6, x: 0, y: isSelected ? 8 : 3)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    static func bestValueBadge(annual: Package, monthly: Package) -> String? {
        let savings = PlanSelector.savingsPercent(annual: annual, monthly: monthly)
        return savings > 0 ? "Más popular · Ahorra \(savings)%" : "Más popular"
    }
}

private enum Haptics {
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func tap() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}
