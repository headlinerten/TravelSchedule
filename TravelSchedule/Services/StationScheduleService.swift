import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias StationSchedule = Components.Schemas.ScheduleResponse

protocol StationScheduleServiceProtocol {
    func getSchedule(stationCode: String) async throws -> StationSchedule
}

final class StationScheduleService: StationScheduleServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getSchedule(stationCode: String) async throws -> StationSchedule {
        let response = try await client.getStationSchedule(query: .init(
            apikey: apikey,
            station: stationCode
        ))
        
        // Правильная проверка и обработка ответа
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json
        case .undocumented(let statusCode, _):
            throw ServiceError.invalidResponse(statusCode: statusCode)
        }
    }
}

enum ServiceError: LocalizedError {
    case invalidResponse(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse(let statusCode):
            return "Получен некорректный ответ от сервера. Код ошибки: \(statusCode)"
        }
    }
}
