import Foundation
import SwiftUI

struct CarrierRoute: Identifiable, Hashable {
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
    
    private let apiManager = APIManager.shared
    private var carrierInfoCache: [String: CarrierInfo] = [:]
    
    func loadRoutes(from fromStation: RailwayStations, to toStation: RailwayStations) async {
        isLoading = true
        error = nil
        routes = []
        
        do {
            let schedule = try await apiManager.scheduleService.getSchedule(
                from: fromStation.stationCode,
                to: toStation.stationCode
            )
            
            var loadedRoutes: [CarrierRoute] = []
            
            if let segments = schedule.segments {
                for segment in segments {
                    // Получаем информацию о перевозчике
                    let carrierCode = String(segment.thread?.carrier?.code ?? 0)
                    let carrierInfo = await loadCarrierInfo(code: carrierCode)
                    
                    // Форматируем даты и время
                    let departure = segment.departure ?? Date()
                    let arrival = segment.arrival ?? Date()
                    let duration = formatDuration(seconds: segment.duration ?? 0)
                    
                    let route = CarrierRoute(
                        carrierName: segment.thread?.carrier?.title ?? "Неизвестный перевозчик",
                        carrierCode: carrierCode,
                        date: formatDate(departure),
                        departureTime: formatTime(departure),
                        arrivalTime: formatTime(arrival),
                        duration: duration,
                        withTransfer: segment.thread?.title?.contains("пересадка") ?? false,
                        carrierImage: getCarrierImageName(carrierCode),
                        note: segment.thread?.title,
                        email: carrierInfo?.carriers?.first?.email ?? "info@rzd.ru",
                        phone: carrierInfo?.carriers?.first?.phone ?? "+7 800 775-00-00",
                        threadUid: segment.thread?.uid
                    )
                    
                    loadedRoutes.append(route)
                }
            }
            
            self.routes = loadedRoutes
            
        } catch {
            self.error = "Ошибка загрузки маршрутов: \(error.localizedDescription)"
            // Используем моковые данные как fallback
            loadMockRoutes()
        }
        
        isLoading = false
    }
    
    private func loadCarrierInfo(code: String) async -> CarrierInfo? {
        if let cached = carrierInfoCache[code] {
            return cached
        }
        
        do {
            let info = try await apiManager.carrierInfoService.getCarrierInfo(code: code)
            carrierInfoCache[code] = info
            return info
        } catch {
            print("Ошибка загрузки информации о перевозчике: \(error)")
            return nil
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
        
        if hours > 0 {
            return "\(hours) ч \(minutes) мин"
        } else {
            return "\(minutes) мин"
        }
    }
    
    private func getCarrierImageName(_ code: String) -> String {
        // Маппинг кодов перевозчиков на имена изображений
        switch code {
        case "112": return "RJDmock"
        case "680": return "FGKmock"
        default: return "DefaultCarrier"
        }
    }
    
    private func loadMockRoutes() {
        // Оставляем моковые данные как fallback
        self.routes = [
            CarrierRoute(carrierName: "РЖД", carrierCode: "112", date: "14 января", departureTime: "22:30", arrivalTime: "08:15", duration: "20 часов", withTransfer: true, carrierImage: "RJDmock", note: "С пересадкой в Костроме", email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71"),
            CarrierRoute(carrierName: "ФГК", carrierCode: "680", date: "15 января", departureTime: "01:15", arrivalTime: "09:00", duration: "9 часов", withTransfer: false, carrierImage: "FGKmock",email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71")]
    }
    
    var filteredRoutes: [CarrierRoute] {
        let filtered = routes.filter { route in
            let isPeriodMatch: Bool
            if selectedPeriods.isEmpty {
                isPeriodMatch = true
            } else {
                let departureTime = route.departureTime
                let components = departureTime.split(separator: ":").compactMap { Int($0) }
                guard let hour = components.first else {
                    return false
                }
                isPeriodMatch = selectedPeriods.contains { period in
                    switch period {
                    case .morning: return hour >= 6 && hour < 12
                    case .day: return hour >= 12 && hour < 18
                    case .evening: return hour >= 18 && hour < 24
                    case .night: return (hour >= 0 && hour < 6) || hour == 24
                    }
                }
            }
            
            let isTransferMatch: Bool
            if let showWithTransfer = showWithTransfer {
                isTransferMatch = route.withTransfer == showWithTransfer
            } else {
                isTransferMatch = true
            }
            
            return isPeriodMatch && isTransferMatch
        }
        return filtered
    }
}








//import Foundation
//import SwiftUI
//import Observation
//
//struct CarrierRoute: Identifiable, Hashable {
//    var id = UUID()
//    var carrierName: String
//    var date: String
//    var departureTime: String
//    var arrivalTime: String
//    var duration: String
//    var withTransfer: Bool
//    var carrierImage: String
//    var note: String?
//    var email: String
//    var phone: String
//}
//
//final class CarrierRouteViewModel: ObservableObject {
//    @Published var routes: [CarrierRoute]
//    @Published var selectedPeriods: Set<PeriodofTime> = []
//    @Published var showWithTransfer: Bool? = nil
//
//    init() {
//        self.routes = [
//            CarrierRoute(carrierName: "РЖД", date: "14 января", departureTime: "22:30", arrivalTime: "08:15", duration: "20 часов", withTransfer: true, carrierImage: "RJDmock", note: "С пересадкой в Костроме", email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71"),
//            CarrierRoute(carrierName: "ФГК", date: "15 января", departureTime: "01:15", arrivalTime: "09:00", duration: "9 часов", withTransfer: false, carrierImage: "FGKmock",email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71"),
//            CarrierRoute(carrierName: "Урал логистика", date: "16 января", departureTime: "12:30", arrivalTime: "21:00", duration: "9 часов", withTransfer: false, carrierImage: "URALmock",email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71"),
//            CarrierRoute(carrierName: "РЖД", date: "17 января", departureTime: "22:30", arrivalTime: "08:15", duration: "20 часов", withTransfer: true, carrierImage: "RJDmock", note: "С пересадкой в Костроме", email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71"),
//            CarrierRoute(carrierName: "РЖД", date: "17 января", departureTime: "22:30", arrivalTime: "08:15", duration: "20 часов", withTransfer: false, carrierImage: "RJDmock", email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71"),
//            CarrierRoute(carrierName: "РЖД", date: "17 января", departureTime: "22:30", arrivalTime: "08:15", duration: "20 часов", withTransfer: false, carrierImage: "RJDmock",email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71"),
//            CarrierRoute(carrierName: "РЖД", date: "17 января", departureTime: "22:30", arrivalTime: "08:15", duration: "20 часов", withTransfer: false, carrierImage: "RJDmock",email: "i.lozgkina@yandex.ru", phone: "+7 (904) 329-27-71")
//        ]
//    }
//
//
//    var filteredRoutes: [CarrierRoute] {
//        let filtered = routes.filter { route in
//            let isPeriodMatch: Bool
//            if selectedPeriods.isEmpty {
//                isPeriodMatch = true
//            } else {
//                let departureTime = route.departureTime
//                let components = departureTime.split(separator: ":").compactMap { Int($0) }
//                guard let hour = components.first else {
//                    print("Failed to parse departureTime: \(departureTime)")
//                    return false
//                }
//                isPeriodMatch = selectedPeriods.contains { period in
//                    switch period {
//                    case .morning: return hour >= 6 && hour < 12
//                    case .day: return hour >= 12 && hour < 18
//                    case .evening: return hour >= 18 && hour < 24
//                    case .night: return (hour >= 0 && hour < 6) || hour == 24
//                    }
//                }
//            }
//
//            let isTransferMatch: Bool
//            if let showWithTransfer = showWithTransfer {
//                isTransferMatch = route.withTransfer == showWithTransfer
//            } else {
//                isTransferMatch = true
//            }
//
//            print("Route: \(route.departureTime), isPeriodMatch: \(isPeriodMatch), isTransferMatch: \(isTransferMatch)")
//            return isPeriodMatch && isTransferMatch
//        }
//        print("Filtered routes count: \(filtered.count), selectedPeriods: \(selectedPeriods), showWithTransfer: \(String(describing: showWithTransfer))")
//        return filtered
//    }
//}
