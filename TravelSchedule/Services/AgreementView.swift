import SwiftUI
import WebKit


struct AgreementView: View {
    @Binding var navigationPath: NavigationPath
    @State private var isNetWorkAvailable: Bool = true
    private let agreementURLString = "https://yandex.ru/legal/practicum_offer"
    
    var body: some View {
        VStack {
            if  isNetWorkAvailable {
                if let url = URL(string: agreementURLString) {
                    WebView(url: url, isNetworkAvailable: $isNetWorkAvailable)
                        .navigationBarBackButtonHidden(true)
                    
                        .navigationBarBackButtonHidden(true)
                } else {
                    NoInternetView(navigationPath: $navigationPath)
                }
            }
        }
        .background(Color(.whiteDay))
        
        .navigationTitle("Пользовательское соглашение")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blackDay)
                }
            }
            
        }
    }
}

#Preview {
    AgreementView(navigationPath: .constant(NavigationPath()))
}
