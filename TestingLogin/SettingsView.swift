//
//  SettingsView.swift
//  TestingLogin
//
//  Created by Meriem Abid on 11/12/2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedLanguage: String = LanguageManager.shared.getLanguage()
    @AppStorage("selectedTheme") private var selectedTheme: String = "system"
    var body: some View {
        NavigationView {
            List {
                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: .constant(true))
                    NavigationLink("Customize Notifications", destination: NotificationsSettingsView())
                }

                // Language and Region Section
                List {
                             Section(header: Text("Language")) {
                                 Picker("Select Language", selection: $selectedLanguage) {
                                     Text("English").tag("en")
                                     Text("Français").tag("fr")
                                 }
                                 .pickerStyle(SegmentedPickerStyle())
                                 .onChange(of: selectedLanguage) { newLanguage in
                                     LanguageManager.shared.setLanguage(newLanguage)
                                     // Forcer la mise à jour de l'interface utilisateur
                                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                         UIApplication.shared.windows.first?.rootViewController =
                                         UIHostingController(rootView: SettingsView())
                                     }
                                 }
                             }
                         }
                         .listStyle(InsetGroupedListStyle())

                // Appearance Mode Section
                Section(header: Text("Appearance Mode")) {
                    Picker("Appearance Mode", selection: $selectedTheme) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Privacy Section
                Section(header: Text("Privacy")) {
                    NavigationLink("Manage Permissions", destination: PermissionsSettingsView())
                    NavigationLink("Delete My Data", destination: DeleteDataSettingsView())
                }

                // Security Section
                Section(header: Text("Security")) {
                    NavigationLink("Change Password", destination: ChangePasswordView())
                    NavigationLink("Two-Factor Authentication", destination: TwoFactorSettingsView())
                    NavigationLink("Manage Devices", destination: ManageDevicesView())
                }

                // Account Management Section
                Section(header: Text("Account Management")) {
                    NavigationLink("Update Email", destination: UpdateEmailView())
                    NavigationLink("Delete My Account", destination: DeleteAccountView())
                }

                // User Support Section
                Section(header: Text("Support")) {
                    NavigationLink("Contact Support", destination: ContactSupportView())
                    NavigationLink("FAQ", destination: FAQView())
                    NavigationLink("Send Feedback", destination: FeedbackView())
                }

                // About Section
                Section(header: Text("About")) {
                    NavigationLink("App Information", destination: AppInfoView())
                    NavigationLink("Legal Notices", destination: LegalInfoView())
                    NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
        }
    }
}

// Placeholder Views for Navigation Links
struct NotificationsSettingsView: View { var body: some View { Text("Notification Settings") } }
struct LanguageSettingsView: View { var body: some View { Text("Change Language") } }
struct RegionSettingsView: View { var body: some View { Text("Change Region") } }
struct FontSizeSettingsView: View { var body: some View { Text("Font Size") } }
struct PermissionsSettingsView: View { var body: some View { Text("Manage Permissions") } }
struct DeleteDataSettingsView: View { var body: some View { Text("Delete My Data") } }
struct ChangePasswordView: View { var body: some View { Text("Change Password") } }
struct TwoFactorSettingsView: View { var body: some View { Text("Two-Factor Authentication") } }
struct ManageDevicesView: View { var body: some View { Text("Manage Devices") } }
struct UpdateEmailView: View { var body: some View { Text("Update Email") } }
struct DeleteAccountView: View { var body: some View { Text("Delete My Account") } }
struct ContactSupportView: View { var body: some View { Text("Contact Support") } }
struct FAQView: View { var body: some View { Text("FAQ") } }
struct FeedbackView: View { var body: some View { Text("Send Feedback") } }
struct AppInfoView: View { var body: some View { Text("App Information") } }
struct LegalInfoView: View { var body: some View { Text("Legal Notices") } }
struct PrivacyPolicyView: View { var body: some View { Text("Privacy Policy") } }


#Preview {
    SettingsView()
}
