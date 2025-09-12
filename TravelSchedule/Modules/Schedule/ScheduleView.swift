import SwiftUI

struct ScheduleView: View {
    @StateObject private var storiesViewModel = StoriesViewModel() // Изменено с @State
    @Binding var fromCity: Cities?
    @Binding var fromStation: RailwayStations?
    @Binding var toCity: Cities?
    @Binding var toStation: RailwayStations?
    @Binding var navigationPath: NavigationPath
    @ObservedObject var carrierViewModel: CarrierRouteViewModel

    var body: some View {
        VStack(spacing: 44) {
            storiesScrollView
            routeSelectionSection
            Spacer()
            Divider().frame(height: 3)
        }
        .padding(.top, 24)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .tabBar)
    }
    
    // MARK: - Private Views
    
    private var storiesScrollView: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 12) {
                ForEach(storiesViewModel.stories) { story in // Изменено с .story
                    StoriesCell(stories: story)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 140)
        .scrollIndicators(.hidden)
    }
    
    private var routeSelectionSection: some View {
        VStack(spacing: 16) {
            routeSelectionCard
            
            if isFindButtonEnabled {
                findButton
            }
        }
    }
    
    private var routeSelectionCard: some View {
        ZStack {
            Color(UIColor(resource: .blueUniversal))
                .clipShape(RoundedRectangle(cornerRadius: 20))

            HStack {
                stationSelectionButtons
                swapButton
            }
            .padding(.vertical, 16)
        }
        .frame(height: 128)
        .padding(.horizontal, 16)
    }
    
    private var stationSelectionButtons: some View {
        VStack(alignment: .leading, spacing: 0) {
            fromStationButton
            toStationButton
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
        )
        .padding(.horizontal, 16)
    }
    
    private var fromStationButton: some View {
        Button(action: {
            navigationPath.append(ContentView.Destination.cities(isSelectingFrom: true))
        }) {
            Text(fromText)
                .foregroundStyle(fromCity == nil ? .appGray : .blackUniversal)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var toStationButton: some View {
        Button(action: {
            navigationPath.append(ContentView.Destination.cities(isSelectingFrom: false))
        }) {
            Text(toText)
                .foregroundStyle(toCity == nil ? .appGray : .blackUniversal)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var swapButton: some View {
        Button(action: {
            let tempCity = fromCity
            let tempStation = fromStation
            fromCity = toCity
            fromStation = toStation
            toCity = tempCity
            toStation = tempStation
        }) {
            Image("ChangeButton")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)
                .foregroundStyle(.blue)
                .padding(6)
                .background(.white)
                .clipShape(Circle())
        }
        .padding(.trailing, 16)
    }
    
    private var findButton: some View {
        Button(action: {
            if let fromCity = fromCity,
               let fromStation = fromStation,
               let toCity = toCity,
               let toStation = toStation {
                navigationPath.append(ContentView.Destination.carriers(
                    fromCity: fromCity,
                    fromStation: fromStation,
                    toCity: toCity,
                    toStation: toStation
                ))
            }
        }) {
            Text("Найти")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 150, height: 40)
                .padding(.vertical, 12)
                .background(Color(UIColor(resource: .blueUniversal)))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Computed Properties
    
    private var fromText: String {
        if let city = fromCity, let station = fromStation {
            return "\(city.cityName) (\(station.RailwayStationName))"
        } else if let city = fromCity {
            return city.cityName
        }
        return "Откуда"
    }

    private var toText: String {
        if let city = toCity, let station = toStation {
            return "\(city.cityName) (\(station.RailwayStationName))"
        } else if let city = toCity {
            return city.cityName
        }
        return "Куда"
    }

    private var isFindButtonEnabled: Bool {
        return fromStation != nil && toStation != nil
    }
}

#Preview {
    ScheduleView(
        fromCity: .constant(nil),
        fromStation: .constant(nil),
        toCity: .constant(nil),
        toStation: .constant(nil),
        navigationPath: .constant(NavigationPath()),
        carrierViewModel: CarrierRouteViewModel()
    )
}
