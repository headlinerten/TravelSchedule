import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias ScheduleBetweenStations = Components.Schemas.Segments

protocol ScheduleServiceProtocol {
    func getSchedule(from: String, to: String) async throws -> ScheduleBetweenStations
}

final class ScheduleService: ScheduleServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getSchedule(from: String, to: String) async throws -> ScheduleBetweenStations {
        print("ScheduleService: запрос расписания от \(from) до \(to)")
        
        do {
            let response = try await client.getSchedualBetweenStations(query: .init(
                apikey: apikey,
                from: from,
                to: to,
                format: "json",
                lang: "ru_RU",
                transport_types: "train"
            ))
            
            switch response {
            case .ok(let okResponse):
                let result = try okResponse.body.json
                print("ScheduleService: получен успешный ответ")
                return result
            case .undocumented(let statusCode, _):
                print("ScheduleService: ошибка HTTP \(statusCode)")
                throw ServiceError.invalidResponse(statusCode: statusCode)
            }
        } catch {
            print("ScheduleService ERROR: \(error)")
            throw error
        }
    }
}
