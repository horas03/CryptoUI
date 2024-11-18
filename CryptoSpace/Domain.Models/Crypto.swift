import Foundation

class Crypto: Identifiable, ObservableObject, Decodable {
    var id: String { symbol }
    let symbol: String
    @Published var price: Double
    let timestamp: Date

    private enum CodingKeys: String, CodingKey {
        case symbol, price, timestamp
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.price = try container.decode(Double.self, forKey: .price)
        
        // Decode timestamp as a String and parse it into a Date
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Match JSON format
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = dateFormatter.date(from: timestampString) else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Invalid date format")
        }
        self.timestamp = date
    }
}
