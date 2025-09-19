import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor NetworkActor {
    static let shared = NetworkActor()
    
    private let client: Client
    private let apiKey = "b739d6df-8e6f-46fd-a90f-5248721f7332"
    
    private init() {
        self.client = Client(
            serverURL: try! Servers.server1(),
            configuration: .init(dateTranscoder: CustomDateTranscoder()),
            transport: URLSessionTransport()
        )
    }
    
    func getAllStations() async throws -> AllStationsResponse {
        let service = AllStationsService(client: client, apikey: apiKey)
        return try await service.getAllStations()
    }
    
    func getSchedule(from: String, to: String) async throws -> ScheduleBetweenStations {
        let service = ScheduleService(client: client, apikey: apiKey)
        return try await service.getSchedule(from: from, to: to)
    }
    
    func getCarrierInfo(code: String) async throws -> CarrierInfo {
        let service = CarrierInfoService(client: client, apikey: apiKey)
        return try await service.getCarrierInfo(code: code)
    }
    
    func getStationSchedule(stationCode: String) async throws -> StationSchedule {
        let service = StationScheduleService(client: client, apikey: apiKey)
        return try await service.getSchedule(stationCode: stationCode)
    }
    
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {
        let service = NearestStationsService(client: client, apikey: apiKey)
        return try await service.getNearestStations(lat: lat, lng: lng, distance: distance)
    }
    
    func getNearestCity(lat: Double, lng: Double) async throws -> NearestCity {
        let service = NearestCityService(client: client, apikey: apiKey)
        return try await service.getNearestCity(lat: lat, lng: lng)
    }
    
    func getRouteStations(uid: String) async throws -> ThreadStations {
        let service = RouteStationsService(client: client, apikey: apiKey)
        return try await service.getRouteStations(uid: uid)
    }
    
    func getCopyright() async throws -> CopyrightResponse {
        let service = CopyrightService(client: client, apikey: apiKey)
        return try await service.getCopyright()
    }
}
