import SwiftUI

enum PeriodofTime: String, CaseIterable, Hashable, Sendable {
    case morning = "Утро 06:00 - 12:00"
    case day = "День 12:00 - 18:00"
    case evening = "Вечер 18:00 - 00:00"
    case night = "Ночь 00:00 - 06:00"
}

struct FiltersView: View {
    
    @ObservedObject var viewModel: CarrierRouteViewModel
    let fromCity: Cities
    let fromStation: RailwayStations
    let toCity: Cities
    let toStation: RailwayStations
    @Binding var navigationPath: NavigationPath
    @State private var showWithTransfer: Bool?
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Время отправления")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.blackDay)
                .padding(.horizontal, 16)
            
            ForEach(PeriodofTime.allCases, id: \.self) { period in
                HStack {
                    Text(period.rawValue)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.blackDay)
                    Spacer()
                    Button(action: {
                        if viewModel.selectedPeriods.contains(period) {
                            viewModel.selectedPeriods.remove(period)
                        } else {
                            viewModel.selectedPeriods.insert(period)
                        }
                    }) { Image(systemName: viewModel.selectedPeriods.contains(period) ? "checkmark.square.fill" : "square")
                            .foregroundStyle(.blackDay)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            Text("Показывать варианты с пересадками")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.blackDay)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            HStack{
                Text("Да")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blackDay)
                Spacer()
                Button(action: {
                    showWithTransfer = true
                    viewModel.showWithTransfer = true
                }) {
                    Image(systemName: showWithTransfer == true ? "circle.fill" : "circle")
                        .foregroundStyle(.blackDay)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            HStack {
                           Text("Нет")
                               .font(.system(size: 17, weight: .regular))
                               .foregroundStyle(.blackDay)
                           Spacer()
                           Button(action: {
                               showWithTransfer = false
                               viewModel.showWithTransfer = false
                               print("Show with transfer: false")
                           }) {
                               Image(systemName: showWithTransfer == false ? "circle.fill" : "circle")
                                   .foregroundStyle(.blackDay)
                                   .font(.system(size: 20))
                           }
                       }
                       .padding(.horizontal, 16)
                       .padding(.top, 16)
            Spacer()
            
            Button(action: {
                navigationPath.removeLast()
            }) {
                Text("Применить фильтры")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.whiteUniversal)
                    .frame(width: 343, height: 35)
                    .padding(.vertical, 12)
                    .background(.blueUniversal)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
         .navigationBarItems(leading: Button(action: {
             navigationPath.removeLast()
         }) {
             Image(systemName: "chevron.left")
                 .foregroundStyle(.blackDay)
         })
         .toolbar(.hidden, for: .tabBar)
         .onAppear {
             showWithTransfer = viewModel.showWithTransfer
         }
     }
 }
