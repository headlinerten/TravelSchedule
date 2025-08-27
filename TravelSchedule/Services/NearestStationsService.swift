import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias NearestStations = Components.Schemas.Stations

protocol NearestStationsServiceProtocol {
    /// Асинхронная функция для получения списка ближайших станций.
    /// - Parameters:
    ///   - lat: Широта
    ///   - lng: Долгота
    ///   - distance: Радиус поиска
    /// - Returns: Объект `NearestStations`, содержащий информацию о станциях.
    /// - Throws: Ошибку, если запрос не удался.
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations
}

final class NearestStationsService: NearestStationsServiceProtocol {
    
    private let client: Client
    
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {
        let response = try await client.getNearestStations(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance
        ))
        
        return try response.ok.body.json
    }
}
