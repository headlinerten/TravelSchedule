import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

final class APIManager {
    static let shared = APIManager()
    
    private let client: Client
    private let apiKey = "b739d6df-8e6f-46fd-a90f-5248721f7332"
    
    let allStationsService: AllStationsService
    let scheduleService: ScheduleService
    let carrierInfoService: CarrierInfoService
    
    private init() {
        self.client = Client(
            serverURL: try! Servers.server1(),
            configuration: .init(dateTranscoder: CustomDateTranscoder()),
            transport: URLSessionTransport()
        )
        
        self.allStationsService = AllStationsService(client: client, apikey: apiKey)
        self.scheduleService = ScheduleService(client: client, apikey: apiKey)
        self.carrierInfoService = CarrierInfoService(client: client, apikey: apiKey)
    }
}
