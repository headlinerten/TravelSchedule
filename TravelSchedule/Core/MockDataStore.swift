import Foundation

// MARK: - Mock Data Store

final class MockDataStore {
    
    static let shared = MockDataStore()
    
    private init() {}
    
    func getCities() -> [City] {
        return [
            City(name: "Москва", stations: [
                Station(name: "Ленинградский вокзал"),
                Station(name: "Казанский вокзал"),
                Station(name: "Ярославский вокзал"),
                Station(name: "Курский вокзал"),
                Station(name: "Киевский вокзал")
            ]),
            City(name: "Санкт-Петербург", stations: [
                Station(name: "Московский вокзал"),
                Station(name: "Финляндский вокзал"),
                Station(name: "Витебский вокзал"),
                Station(name: "Ладожский вокзал")
            ]),
            City(name: "Новосибирск", stations: [
                Station(name: "Новосибирск-Главный"),
                Station(name: "Новосибирск-Южный"),
                Station(name: "Новосибирск-Западный")
            ]),
            City(name: "Екатеринбург", stations: [
                Station(name: "Екатеринбург-Пассажирский"),
                Station(name: "Екатеринбург-Сортировочный")
            ]),
            City(name: "Казань", stations: [
                Station(name: "Казань-Пассажирская"),
                Station(name: "Восстание-Пассажирская")
            ])
        ]
    }
}
