import Foundation
import SwiftUI

struct CarrierRoute: Identifiable, Hashable, Sendable {
    var id = UUID()
    var carrierName: String
    var carrierCode: String
    var date: String
    var departureTime: String
    var arrivalTime: String
    var duration: String
    var withTransfer: Bool
    var carrierImage: String
    var note: String?
    var email: String
    var phone: String
    var threadUid: String?
}

@MainActor
final class CarrierRouteViewModel: ObservableObject {
    @Published var routes: [CarrierRoute] = []
    @Published var selectedPeriods: Set<PeriodofTime> = []
    @Published var showWithTransfer: Bool? = nil
    @Published var isLoading = false
    @Published var error: String?
    
    private let networkActor = NetworkActor.shared
    private var carrierInfoCache: [String: CarrierInfo] = [:]
    
    func loadRoutes(from fromStation: RailwayStations, to toStation: RailwayStations) async {
        isLoading = true
        error = nil
        routes = []
        
        do {
            print("DEBUG: Загружаем маршруты")
            print("DEBUG: От станции: \(fromStation.RailwayStationName) (код: \(fromStation.stationCode))")
            print("DEBUG: До станции: \(toStation.RailwayStationName) (код: \(toStation.stationCode))")
            
            // Проверяем, что коды станций не пустые
            guard !fromStation.stationCode.isEmpty, !toStation.stationCode.isEmpty else {
                print("ERROR: Пустые коды станций")
                throw NetworkError.invalidStationCodes
            }
            
            // Используем коды как есть, так как они уже должны быть в правильном формате
            let fromCode = fromStation.stationCode
            let toCode = toStation.stationCode
            
            print("DEBUG: Используем коды: от \(fromCode) до \(toCode)")
            
            // Получаем расписание
            let schedule = try await networkActor.getSchedule(from: fromCode, to: toCode)
            print("DEBUG: Получен ответ от API")
            
            var loadedRoutes: [CarrierRoute] = []
            
            if let segments = schedule.segments, !segments.isEmpty {
                print("DEBUG: Найдено сегментов: \(segments.count)")
                
                // Собираем уникальные коды перевозчиков
                let carrierCodes = Set(segments.compactMap { segment in
                    if let code = segment.thread?.carrier?.code {
                        return String(code)
                    }
                    return nil
                })
                
                print("DEBUG: Уникальных перевозчиков: \(carrierCodes.count)")
                
                // Загружаем информацию о перевозчиках параллельно
                await withTaskGroup(of: (String, CarrierInfo?).self) { group in
                    for code in carrierCodes {
                        if carrierInfoCache[code] == nil {
                            group.addTask { [weak self] in
                                guard let self = self else { return (code, nil) }
                                do {
                                    let info = try await self.networkActor.getCarrierInfo(code: code)
                                    print("DEBUG: Загружена информация о перевозчике \(code)")
                                    return (code, info)
                                } catch {
                                    print("WARNING: Не удалось загрузить информацию о перевозчике \(code): \(error)")
                                    return (code, nil)
                                }
                            }
                        }
                    }
                    
                    for await (code, info) in group {
                        if let info = info {
                            carrierInfoCache[code] = info
                        }
                    }
                }
                
                // Создаем маршруты из сегментов
                for (index, segment) in segments.enumerated() {
                    print("DEBUG: Обработка сегмента \(index + 1)")
                    
                    let carrierCode = String(segment.thread?.carrier?.code ?? 0)
                    let carrierInfo = carrierInfoCache[carrierCode]
                    
                    // Получаем даты и время
                    let departure = segment.departure ?? Date()
                    let arrival = segment.arrival ?? Date()
                    let duration = formatDuration(seconds: segment.duration ?? 0)
                    
                    // Определяем наличие пересадок
                    let hasTransfer = segment.thread?.title?.lowercased().contains("пересад") ?? false
                    
                    let route = CarrierRoute(
                        carrierName: segment.thread?.carrier?.title ?? "РЖД",
                        carrierCode: carrierCode,
                        date: formatDate(departure),
                        departureTime: formatTime(departure),
                        arrivalTime: formatTime(arrival),
                        duration: duration,
                        withTransfer: hasTransfer,
                        carrierImage: getCarrierImageName(carrierCode),
                        note: hasTransfer ? "С пересадкой" : nil,
                        email: carrierInfo?.carriers?.first?.email ?? "info@rzd.ru",
                        phone: carrierInfo?.carriers?.first?.phone ?? "+7 (800) 775-00-00",
                        threadUid: segment.thread?.uid
                    )
                    
                    loadedRoutes.append(route)
                }
                
                self.routes = loadedRoutes
                print("SUCCESS: Загружено \(loadedRoutes.count) маршрутов")
                
            } else {
                print("WARNING: API вернул пустой список сегментов")
                print("INFO: Используем тестовые данные")
                loadMockRoutes()
            }
            
        } catch {
            print("ERROR: Ошибка загрузки маршрутов: \(error)")
            handleError(error)
            loadMockRoutes()
        }
        
        isLoading = false
    }
    
    private func formatStationCode(_ code: String) -> String {
        // Если код уже содержит префикс, возвращаем как есть
        if code.hasPrefix("s") || code.hasPrefix("c") || code.hasPrefix("l") {
            return code
        }
        // Для числовых кодов добавляем префикс 's' (станция)
        if Int(code) != nil {
            return "s\(code)"
        }
        // Иначе возвращаем как есть
        return code
    }
    
    private func handleError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                self.error = "Нет подключения к интернету"
            case .timedOut:
                self.error = "Превышено время ожидания"
            case .cannotFindHost:
                self.error = "Не удается подключиться к серверу"
            default:
                self.error = "Ошибка сети"
            }
        } else if let networkError = error as? NetworkError {
            self.error = networkError.localizedDescription
        } else {
            self.error = "Не удалось загрузить маршруты. Показываем тестовые данные."
        }
    }
    
    enum NetworkError: LocalizedError {
        case invalidStationCodes
        case noData
        case apiError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidStationCodes:
                return "Неверные коды станций"
            case .noData:
                return "Данные не найдены"
            case .apiError(let message):
                return "Ошибка API: \(message)"
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDuration(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours) ч \(minutes) мин"
        } else if hours > 0 {
            return "\(hours) ч"
        } else {
            return "\(minutes) мин"
        }
    }
    
    private func getCarrierImageName(_ code: String) -> String {
        switch code {
        case "112", "153":
            return "RJDmock"
        case "680":
            return "FGKmock"
        default:
            return "RJDmock"
        }
    }
    
    private func loadMockRoutes() {
        self.routes = [
            CarrierRoute(
                carrierName: "РЖД",
                carrierCode: "112",
                date: "14 января",
                departureTime: "22:30",
                arrivalTime: "08:15",
                duration: "9 ч 45 мин",
                withTransfer: false,
                carrierImage: "RJDmock",
                note: nil,
                email: "info@rzd.ru",
                phone: "+7 (800) 775-00-00"
            ),
            CarrierRoute(
                carrierName: "ФПК",
                carrierCode: "680",
                date: "15 января",
                departureTime: "01:15",
                arrivalTime: "09:00",
                duration: "7 ч 45 мин",
                withTransfer: false,
                carrierImage: "FGKmock",
                note: nil,
                email: "info@fpc.ru",
                phone: "+7 (800) 100-00-00"
            ),
            CarrierRoute(
                carrierName: "РЖД",
                carrierCode: "112",
                date: "14 января",
                departureTime: "14:30",
                arrivalTime: "22:20",
                duration: "7 ч 50 мин",
                withTransfer: true,
                carrierImage: "RJDmock",
                note: "С пересадкой",
                email: "info@rzd.ru",
                phone: "+7 (800) 775-00-00"
            )
        ]
    }
    
    var filteredRoutes: [CarrierRoute] {
        routes.filter { route in
            // Фильтр по времени
            let isPeriodMatch: Bool
            if selectedPeriods.isEmpty {
                isPeriodMatch = true
            } else {
                let components = route.departureTime.split(separator: ":").compactMap { Int($0) }
                guard let hour = components.first else {
                    return false
                }
                isPeriodMatch = selectedPeriods.contains { period in
                    switch period {
                    case .morning:
                        return hour >= 6 && hour < 12
                    case .day:
                        return hour >= 12 && hour < 18
                    case .evening:
                        return hour >= 18 && hour < 24
                    case .night:
                        return hour >= 0 && hour < 6
                    }
                }
            }
            
            // Фильтр по пересадкам
            let isTransferMatch: Bool
            if let showWithTransfer = showWithTransfer {
                isTransferMatch = route.withTransfer == showWithTransfer
            } else {
                isTransferMatch = true
            }
            
            return isPeriodMatch && isTransferMatch
        }
    }
}
