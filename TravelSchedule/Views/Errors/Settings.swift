import SwiftUI

struct SettingsView: View {
    @AppStorage("theme") private var selectedTheme: Theme = .auto
    @Environment(\.colorScheme) private var colorScheme
    @State private var isDarkMode: Bool = false
    @State private var showNoInternet = false
    @State private var showServerError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Тёмная тема")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blackDay)
                Spacer()
                Toggle("", isOn: $isDarkMode)
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.whiteDay.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            
            
            Button(action: {
                showNoInternet = true
            }) {
                Text("Показать экран 'Нет интернета'")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blackDay)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.whiteDay.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
            }
            
            Button(action: {
                showServerError = true
            }) {
                Text("Показать экран 'Ошибка сервера'")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blackDay)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.whiteDay.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
            }
            
            
            Spacer()
        }
        .toolbar(.visible, for: .tabBar)
        .preferredColorScheme(selectedTheme == .auto ? nil : (selectedTheme == .dark ? .dark : .light))
        .onAppear {
            isDarkMode = selectedTheme == .dark || (selectedTheme == .auto && colorScheme == .dark)
        }
        .onChange(of: isDarkMode) { newValue in
            selectedTheme = newValue ? .dark : .light
        }
        .onChange(of: colorScheme) { newValue in
            if selectedTheme == .auto {
                isDarkMode = newValue == .dark
            }
        }
        .fullScreenCover(isPresented: $showNoInternet) {
            NavigationStack {
                NoInternetViewWrapper(isPresented: $showNoInternet)
            }
        }
        .fullScreenCover(isPresented: $showServerError) {
            NavigationStack {
                ServerErrorViewWrapper(isPresented: $showServerError)
            }
        }
    }
}

// Обертки для правильной работы кнопки назад
struct NoInternetViewWrapper: View {
    @Binding var isPresented: Bool
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("NoInternet")
                .resizable()
                .scaledToFit()
                .frame(width: 233, height: 233)
                .foregroundStyle(.appGray)
            
            Text("Нет интернета")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.blackDay)
                .padding(.top, 16)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.blackDay)
                }
            }
        }
    }
}

struct ServerErrorViewWrapper: View {
    @Binding var isPresented: Bool
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        VStack {
            Spacer()

            Image("ServerError")
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .foregroundStyle(.appGray)

            Text("Ошибка сервера")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.blackDay)
                .padding(.top, 16)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.blackDay)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
