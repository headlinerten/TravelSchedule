import SwiftUI
import OpenAPIURLSession
import OpenAPIRuntime

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "tram.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Расписание Путешествий")
        }
        .padding()
        .onAppear {
            runAllNetworkTests()
        }
    }
    
    private func runAllNetworkTests() {
        let apiKey = "b739d6df-8e6f-46fd-a90f-5248721f7332"
        
        Task {
            do {
                let configuration = OpenAPIRuntime.Configuration(
                    dateTranscoder: CustomDateTranscoder()
                )
                
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    configuration: configuration,
                    transport: URLSessionTransport()
                )
                
                // --- Тест 1: Список всех станций ---
                print(">>> 1. Тестируем AllStationsService...")
                let allStationsService = AllStationsService(client: client, apikey: apiKey)
                let stations = try await allStationsService.getAllStations()
                print("✅ Успех! Получено стран: \(stations.countries?.count ?? 0)")
                
                // --- Тест 2: Копирайт ---
                print("\n>>> 2. Тестируем CopyrightService...")
                let copyrightService = CopyrightService(client: client, apikey: apiKey)
                let copyright = try await copyrightService.getCopyright()
                print("✅ Успех! Копирайт: \(copyright.copyright?.text ?? "N/A")")
                
                // --- Тест 3: Список ближайших станций ---
                print("\n>>> 3. Тестируем NearestStationsService...")
                let nearestStationsService = NearestStationsService(client: client, apikey: apiKey)
                let nearestStations = try await nearestStationsService.getNearestStations(
                    lat: 55.7558,  // Москва
                    lng: 37.6173,
                    distance: 10
                )
                print("✅ Успех! Найдено ближайших станций: \(nearestStations.stations?.count ?? 0)")
                
                // --- Тест 4: Расписание между станциями ---
                print("\n>>> 4. Тестируем ScheduleService...")
                let scheduleService = ScheduleService(client: client, apikey: apiKey)
                // Используем коды крупных станций Москвы и Санкт-Петербурга
                let schedule = try await scheduleService.getSchedule(
                    from: "s2000002",  // Ленинградский вокзал (Москва)
                    to: "s9602497"     // Московский вокзал (Санкт-Петербург)
                )
                print("✅ Успех! Найдено рейсов между станциями: \(schedule.segments?.count ?? 0)")
                
                // --- Тест 5: Расписание по станции ---
                print("\n>>> 5. Тестируем StationScheduleService...")
                let stationScheduleService = StationScheduleService(client: client, apikey: apiKey)
                // Используем код крупной станции
                let stationSchedule = try await stationScheduleService.getSchedule(
                    stationCode: "s9600721"  // Московский вокзал (СПб)
                )
                print("✅ Успех! Найдено рейсов по станции: \(stationSchedule.schedule?.count ?? 0)")
                
                // --- Тест 6: Список станций на маршруте ---
                print("\n>>> 6. Тестируем RouteStationsService...")
                let routeStationsService = RouteStationsService(client: client, apikey: apiKey)
                let routeStations = try await routeStationsService.getRouteStations(
                    uid: "001G_1_2"  // Сапсан Москва-СПб
                )
                print("✅ Успех! Найдено остановок на маршруте: \(routeStations.stops?.count ?? 0)")
                
                // --- Тест 7: Ближайший город ---
                print("\n>>> 7. Тестируем NearestCityService...")
                let nearestCityService = NearestCityService(client: client, apikey: apiKey)
                let city = try await nearestCityService.getNearestCity(
                    lat: 55.7558,
                    lng: 37.6173
                )
                print("✅ Успех! Ближайший город: \(city.title ?? "N/A")")
                
                // --- Тест 8: Информация о перевозчике ---
                print("\n>>> 8. Тестируем CarrierInfoService...")
                let carrierInfoService = CarrierInfoService(client: client, apikey: apiKey)
                let carrier = try await carrierInfoService.getCarrierInfo(
                    code: "680"  // РЖД
                )
                print("✅ Успех! Информация о перевозчике: \(carrier.carriers?.first?.title ?? "N/A")")
                
            } catch {
                print("❌ Ошибка в одном из тестов: \(error)")
            }
        }
    }
}
