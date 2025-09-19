import SwiftUI
import Foundation

struct Cities: Identifiable, Hashable, Sendable {
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
    
    private let networkActor = NetworkActor.shared
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
            let response = try await networkActor.getAllStations()
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
                                            // ВАЖНО: проверяем что код станции существует
                                            guard let stationCode = station.codes?.yandex_code ?? station.code,
                                                  let stationName = station.title,
                                                  !stationCode.isEmpty,
                                                  !stationName.isEmpty else {
                                                return nil
                                            }
                                            
                                            return RailwayStations(
                                                RailwayStationName: stationName,
                                                stationCode: stationCode
                                            )
                                        }
                                    }
                                    
                                    if !city.cityName.isEmpty && !city.stations.isEmpty {
                                        cities.append(city)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            self.city = cities.sorted { $0.cityName < $1.cityName }
            
            // Если городов мало или нет, добавляем основные
            if self.city.count < 5 {
                addMajorCities()
            }
            
        } catch {
            self.error = "Ошибка загрузки городов: \(error.localizedDescription)"
            loadMockData()
        }
        
        isLoading = false
    }
    
    private func addMajorCities() {
        // Добавляем основные города с правильными кодами станций
        let majorCities = [
            Cities(
                cityName: "Москва",
                cityCode: "c213",
                stations: [
                    RailwayStations(RailwayStationName: "Курский вокзал", stationCode: "s2000006"),
                    RailwayStations(RailwayStationName: "Ленинградский вокзал", stationCode: "s2000001"),
                    RailwayStations(RailwayStationName: "Казанский вокзал", stationCode: "s2000003"),
                    RailwayStations(RailwayStationName: "Ярославский вокзал", stationCode: "s2000002"),
                    RailwayStations(RailwayStationName: "Киевский вокзал", stationCode: "s2000007")
                ]
            ),
            Cities(
                cityName: "Санкт-Петербург",
                cityCode: "c2",
                stations: [
                    RailwayStations(RailwayStationName: "Московский вокзал", stationCode: "s9602494"),
                    RailwayStations(RailwayStationName: "Финляндский вокзал", stationCode: "s9602497"),
                    RailwayStations(RailwayStationName: "Витебский вокзал", stationCode: "s9602498"),
                    RailwayStations(RailwayStationName: "Ладожский вокзал", stationCode: "s9602499")
                ]
            )
        ]
        
        // Добавляем только те города, которых еще нет
        for majorCity in majorCities {
            if !city.contains(where: { $0.cityName == majorCity.cityName }) {
                city.append(majorCity)
            }
        }
        
        city.sort { $0.cityName < $1.cityName }
    }
    
    private func loadMockData() {
        city = [
            Cities(
                cityName: "Москва",
                cityCode: "c213",
                stations: [
                    RailwayStations(RailwayStationName: "Курский вокзал", stationCode: "s2000006"),
                    RailwayStations(RailwayStationName: "Ленинградский вокзал", stationCode: "s2000001"),
                    RailwayStations(RailwayStationName: "Казанский вокзал", stationCode: "s2000003")
                ]
            ),
            Cities(
                cityName: "Санкт-Петербург",
                cityCode: "c2",
                stations: [
                    RailwayStations(RailwayStationName: "Московский вокзал", stationCode: "s9602494"),
                    RailwayStations(RailwayStationName: "Финляндский вокзал", stationCode: "s9602497")
                ]
            ),
            Cities(
                cityName: "Казань",
                cityCode: "c43",
                stations: [
                    RailwayStations(RailwayStationName: "Казань-Пассажирская", stationCode: "s9607404")
                ]
            ),
            Cities(
                cityName: "Екатеринбург",
                cityCode: "c54",
                stations: [
                    RailwayStations(RailwayStationName: "Екатеринбург-Пассажирский", stationCode: "s9607404")
                ]
            ),
            Cities(
                cityName: "Новосибирск",
                cityCode: "c65",
                stations: [
                    RailwayStations(RailwayStationName: "Новосибирск-Главный", stationCode: "s9612990")
                ]
            ),
            Cities(
                cityName: "Сочи",
                cityCode: "c239",
                stations: [
                    RailwayStations(RailwayStationName: "Сочи", stationCode: "s9613072")
                ]
            )
        ]
    }
    
    func getStationsForCity(_ city: Cities) -> [RailwayStations] {
        return city.stations
    }
}
