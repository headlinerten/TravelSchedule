import SwiftUI
import Foundation

struct Cities: Identifiable, Hashable {
    let id = UUID()
    let cityName: String
}

final class CitiesViewModel: ObservableObject {
    @Published var city: [Cities] = []
    
    init() {
        loadCities()
    }
    
    private func loadCities() {
        city = [
            Cities(cityName: "Москва"),
            Cities(cityName: "Санкт-Петербург"),
            Cities(cityName: "Сочи"),
            Cities(cityName: "Горный воздух"),
            Cities(cityName: "Краснодар"),
            Cities(cityName: "Казань"),
            Cities(cityName: "Омск")
        ]
        print("Cities loaded: \(city.count)")
    }
}
