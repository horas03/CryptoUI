import SwiftUI

class Network: ObservableObject {
    @Published var cryptos: [Crypto] = []
    private var webSocketManagers: [WebSocketManager] = []
    
    let baseURL = "https://288b-2a02-2f0a-7612-4400-b5cf-e4f0-3c73-1091.ngrok-free.app"
    
    func getCryptos() {
        guard let url = URL(string: "https://3f3b-2a02-2f0a-7904-7600-415c-73d3-4df1-40a5.ngrok-free.app/api/crypto/symbols") else {
            fatalError("Missing URL")
        }

        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("Failed to get HTTPURLResponse")
                return
            }

            print("HTTP Status Code:", response.statusCode)

            if response.statusCode == 200 {
                guard let data = data else {
                    print("No data")
                    return
                }

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                } else {
                    print("Failed to convert data to JSON string.")
                }

                do {
                    let decodedCryptos = try JSONDecoder().decode([Crypto].self, from: data)
                    DispatchQueue.main.async {
                        self.cryptos = decodedCryptos
                        self.startWebSocketConnections() // Call WebSocket connections here
                    }
                } catch let error {
                    print("Error decoding: ", error)
                }
            } else {
                print("Invalid response with status code:", response.statusCode)
            }
        }

        dataTask.resume()
    }
    
    private func startWebSocketConnections() {
        // Cancel previous connections
        webSocketManagers.forEach { $0.disconnect() }
        webSocketManagers = cryptos.map { WebSocketManager(crypto: $0) }
    }
    
}
