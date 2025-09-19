import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Тёмная тема")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blackDay)
                Spacer()
                Toggle("", isOn: $viewModel.isDarkMode)
                    .labelsHidden()
                    .onChange(of: viewModel.isDarkMode) { _, _ in
                        viewModel.toggleDarkMode()
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.whiteDay.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            
            Button(action: {
                viewModel.showAgreementScreen()
            }) {
                HStack {
                    Text("Пользовательское соглашение")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.blackDay)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.blackDay)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(width: 34, height: 34)
                }
            }
            
            Button(action: {
                viewModel.showNoInternetScreen()
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
                viewModel.showServerErrorScreen()
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
            
            VStack(alignment: .center, spacing: 16) {
                Text("Приложение использует API «Яндекс.Расписания»")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.blackDay)
                    .lineLimit(1)
                   
                Text("Версия 1.0 (beta)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.blackDay)
                    .lineLimit(1)
            }
            .frame(width: 343, height: 44)
            .padding(.horizontal, 30)
        }
        .toolbar(.visible, for: .tabBar)
        .preferredColorScheme(viewModel.selectedTheme == .auto ? nil : (viewModel.selectedTheme == .dark ? .dark : .light))
        .onChange(of: colorScheme) { _, newValue in
            viewModel.updateForColorScheme(newValue)
        }
        .fullScreenCover(isPresented: $viewModel.showNoInternet) {
            NavigationStack {
                NoInternetViewWrapper(isPresented: $viewModel.showNoInternet)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showServerError) {
            NavigationStack {
                ServerErrorViewWrapper(isPresented: $viewModel.showServerError)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showAgreement) {
            NavigationStack {
                AgreementViewWrapper(isPresented: $viewModel.showAgreement)
            }
        }
    }
}

struct AgreementViewWrapper: View {
    @Binding var isPresented: Bool
    @State private var isNetworkAvailable: Bool = true
    private let agreementURLString = "https://yandex.ru/legal/practicum_offer"
    
    var body: some View {
        VStack {
            if isNetworkAvailable {
                if let url = URL(string: agreementURLString) {
                    WebView(url: url, isNetworkAvailable: $isNetworkAvailable)
                } else {
                    NoInternetViewWrapper(isPresented: $isPresented)
                }
            } else {
                NoInternetViewWrapper(isPresented: $isPresented)
            }
        }
        .background(Color(.whiteDay))
        .navigationTitle("Пользовательское соглашение")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blackDay)
                }
            }
        }
    }
}

struct NoInternetViewWrapper: View {
    @Binding var isPresented: Bool
    
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
