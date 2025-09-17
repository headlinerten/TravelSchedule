import SwiftUI
import Foundation

struct RailwayStations: Identifiable, Hashable {
    var id = UUID()
    var RailwayStationName: String
    var stationCode: String
}

@MainActor
final class RailwayStationViewModel: ObservableObject {
    @Published var railwayStation: [RailwayStations] = []
    @Published var isLoading = false
    
    func loadStationsForCity(_ city: Cities, from viewModel: CitiesViewModel) {
        self.railwayStation = viewModel.getStationsForCity(city)
    }
}
