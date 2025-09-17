import SwiftUI

struct CarrierDetailView: View {
    let route: CarrierRoute
    @Binding var navigationPath: NavigationPath
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Image( "carrierDetailMock")
                .resizable()
                .frame(width: 343, height: 104)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Text("ОАО «\(route.carrierName)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.blackUniversal)
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text("E-mail")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blackDay)
                Text("\(route.email)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.blueUniversal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Телефон")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.blackDay)
                    Text("\(route.phone)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.blueUniversal)
                    
                    
                }
                
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Информация о перевозчике")
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
        .toolbar(.hidden, for: .tabBar)
    }
}
