import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias CopyrightResponse = Components.Schemas.CopyrightResponse

protocol CopyrightServiceProtocol {
    func getCopyright() async throws -> CopyrightResponse
}

final class CopyrightService: CopyrightServiceProtocol {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func getCopyright() async throws -> CopyrightResponse {
        let response = try await client.getCopyright(.init())
        let responseBody = try response.ok.body.html
        let fullData = try await Data(collecting: responseBody, upTo: 10 * 1024 * 1024)
        let copyright = try JSONDecoder().decode(CopyrightResponse.self, from: fullData)
        
        return copyright
    }
}
