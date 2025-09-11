import Foundation
import OpenAPIRuntime
import HTTPTypes

final class CustomDateTranscoder: DateTranscoder {
    private let formatter = ISO8601DateFormatter()
    private let alternativeFormatters: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "HH:mm"
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
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        for formatter in alternativeFormatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return Date()
    }
}
