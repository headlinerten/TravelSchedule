import Foundation

enum Destination: Hashable {
    case carrierDetail(route: CarrierRoute)
    case cities(isSelectingFrom: Bool)
    case stations(city: Cities, isSelectingFrom: Bool)
    case carriers(fromCity: Cities, fromStation: RailwayStations, toCity: Cities, toStation: RailwayStations)
    case filters(fromCity: Cities, fromStation: RailwayStations, toCity: Cities, toStation: RailwayStations)
}
