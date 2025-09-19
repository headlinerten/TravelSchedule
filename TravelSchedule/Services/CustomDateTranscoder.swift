import Foundation
import OpenAPIRuntime
import HTTPTypes

final class CustomDateTranscoder: DateTranscoder, @unchecked Sendable {
    private let formatter = ISO8601DateFormatter()
    private let alternativeFormatters: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
            "yyyy-MM-dd'T'HH:mm:ssXXX",
            "HH:mm:ss",  // Добавлено для времени
            "HH:mm"       // Добавлено для времени без секунд
        ]
        
        return formats.map { format in
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }
    }()
    
    func encode(_ date: Date) throws -> String {
        return formatter.string(from: date)
    }
    
    func decode(_ dateString: String) throws -> Date {
        // Сначала пробуем ISO8601
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Пробуем альтернативные форматы
        for formatter in alternativeFormatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        // Специальная обработка для времени в формате HH:mm:ss или HH:mm
        if dateString.contains(":") && !dateString.contains("-") {
            // Это только время, создаем дату на сегодня
            let components = dateString.split(separator: ":").compactMap { Int($0) }
            if components.count >= 2 {
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                dateComponents.hour = components[0]
                dateComponents.minute = components[1]
                dateComponents.second = components.count > 2 ? components[2] : 0
                
                if let date = calendar.date(from: dateComponents) {
                    return date
                }
            }
        }
        
        // Если ничего не подошло, возвращаем текущую дату как fallback
        print("WARNING: Unable to decode date from string: \(dateString), using current date")
        return Date()
    }
}
