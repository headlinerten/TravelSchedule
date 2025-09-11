import SwiftUI
import Foundation

struct RailwayStations: Identifiable, Hashable {
    var id = UUID()
    var RailwayStationName: String
}

class RailwayStationViewModel: ObservableObject {
    @Published var railwayStation: [RailwayStations]
    
    init() {
        self.railwayStation = [
            RailwayStations(RailwayStationName: "Киевский вокзал"),
            RailwayStations(RailwayStationName: "Курский вокзал"),
            RailwayStations(RailwayStationName: "Ярославский вокзал"),
            RailwayStations(RailwayStationName: "Белорусский вокзал"),
            RailwayStations(RailwayStationName: "Савеловский вокзал"),
            RailwayStations(RailwayStationName: "Ленинградский вокзал")
        ]
    }
}
