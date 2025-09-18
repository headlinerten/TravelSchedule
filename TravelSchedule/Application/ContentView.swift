import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var navigationPath = NavigationPath()
    @State private var fromCity: Cities?
    @State private var fromStation: RailwayStations?
    @State private var toCity: Cities?
    @State private var toStation: RailwayStations?
    @StateObject private var carrierViewModel = CarrierRouteViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                TabView(selection: $selectedTab) {
                    scheduleTab
                    settingsTab
                }
                .overlay(tabBarSeparator, alignment: .bottom)
            }
            .navigationDestination(for: Destination.self) { destination in
                destinationView(for: destination)
            }
        }
    }
    
    // MARK: - Private Views
    
    private var scheduleTab: some View {
        ScheduleView(
            fromCity: $fromCity,
            fromStation: $fromStation,
            toCity: $toCity,
            toStation: $toStation,
            navigationPath: $navigationPath,
            carrierViewModel: carrierViewModel
        )
        .tabItem {
            Label("", image: selectedTab == 0 ? "ScheduleActive" : "ScheduleInactive")
        }
        .tag(0)
    }
    
    private var settingsTab: some View {
        SettingsView()
            .tabItem {
                Label("", image: selectedTab == 1 ? "SettingsActive" : "SettingsInactive")
            }
            .tag(1)
    }
    
    private var tabBarSeparator: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(.gray.opacity(0.3))
            .offset(y: -49)
    }
    
    // MARK: - Navigation Helper
    
    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .carrierDetail(let route):
            CarrierDetailView(route: route, navigationPath: $navigationPath)
                .toolbar(.hidden, for: .tabBar)
            
        case .cities(let isSelectingFrom):
            CitiesView(
                selectedCity: isSelectingFrom ? $fromCity : $toCity,
                selectedStation: isSelectingFrom ? $fromStation : $toStation,
                isSelectingFrom: isSelectingFrom,
                navigationPath: $navigationPath
            )
            .toolbar(.hidden, for: .tabBar)
            
        case .stations(let city, let isSelectingFrom):
            RailwayStationsView(
                selectedCity: city,
                selectedStation: isSelectingFrom ? $fromStation : $toStation,
                navigationPath: $navigationPath
            )
            .toolbar(.hidden, for: .tabBar)
            
        case .carriers(let fromCity, let fromStation, let toCity, let toStation):
            CarriersListView(
                viewModel: carrierViewModel,
                fromCity: fromCity,
                fromStation: fromStation,
                toCity: toCity,
                toStation: toStation,
                navigationPath: $navigationPath
            )
            .toolbar(.hidden, for: .tabBar)
            
        case .filters(let fromCity, let fromStation, let toCity, let toStation):
            FiltersView(
                viewModel: carrierViewModel,
                fromCity: fromCity,
                fromStation: fromStation,
                toCity: toCity,
                toStation: toStation,
                navigationPath: $navigationPath
            )
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    ContentView()
}
