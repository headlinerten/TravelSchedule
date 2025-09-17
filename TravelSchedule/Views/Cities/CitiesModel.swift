import SwiftUI
import Foundation

struct Cities: Identifiable, Hashable {
    let id = UUID()
    let cityName: String
    let cityCode: String
    var stations: [RailwayStations] = []
}

@MainActor
final class CitiesViewModel: ObservableObject {
    @Published var city: [Cities] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiManager = APIManager.shared
    private var allStationsData: AllStationsResponse?
    
    init() {
        Task {
            await loadCities()
        }
    }
    
    func loadCities() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await apiManager.allStationsService.getAllStations()
            self.allStationsData = response
            
            var cities: [Cities] = []
            
            if let countries = response.countries {
                for country in countries {
                    if country.title == "Россия", let regions = country.regions {
                        for region in regions {
                            if let settlements = region.settlements {
                                for settlement in settlements {
                                    var city = Cities(
                                        cityName: settlement.title ?? "",
                                        cityCode: settlement.codes?.yandex_code ?? ""
                                    )
                                    
                                    if let stations = settlement.stations {
                                        city.stations = stations.compactMap { station in
                                            RailwayStations(
                                                RailwayStationName: station.title ?? "",
                                                stationCode: station.code ?? ""
                                            )
                                        }
                                    }
                                    
                                    if !city.cityName.isEmpty {
                                        cities.append(city)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            self.city = cities.sorted { $0.cityName < $1.cityName }
            
        } catch {
            self.error = "Ошибка загрузки городов: \(error.localizedDescription)"
            loadMockData()
        }
        
        isLoading = false
    }
    
    private func loadMockData() {
        city = [
            Cities(cityName: "Москва", cityCode: "c213"),
            Cities(cityName: "Санкт-Петербург", cityCode: "c2"),
            Cities(cityName: "Сочи", cityCode: "c239"),
            Cities(cityName: "Краснодар", cityCode: "c35"),
            Cities(cityName: "Казань", cityCode: "c43"),
            Cities(cityName: "Омск", cityCode: "c66")
        ]
    }
    
    func getStationsForCity(_ city: Cities) -> [RailwayStations] {
        return city.stations
    }
}
