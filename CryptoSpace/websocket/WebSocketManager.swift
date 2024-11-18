import Foundation

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    private var webSocketTask: URLSessionWebSocketTask?
    private let crypto: Crypto

    private func connectToWebSocket(for symbol: String) {
        let urlString = "wss://api.gemini.com/v1/marketdata/\(symbol)USD"
        guard let url = URL(string: urlString) else {
            print("Invalid WebSocket URL")
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main) // Ensure delegate is used
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        print("WebSocket task resumed for \(symbol)")
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    //print("WebSocket message for \(self?.crypto.symbol ?? ""): \(text)")
                    self?.handleMessage(text)
                case .data(let data):
                    print("WebSocket binary data received for \(self?.crypto.symbol ?? ""): \(data)")
                @unknown default:
                    print("Unknown WebSocket message type")
                }
                self?.receiveMessage() // Continue listening
            case .failure(let error):
                print("WebSocket error for \(self?.crypto.symbol ?? ""): \(error)")
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        do {
            // Parse the JSON
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let events = json?["events"] as? [[String: Any]],
               let priceString = events.first?["price"] as? String,
               let newPrice = Double(priceString) {
                
                // Update the price on the main thread
                DispatchQueue.main.async {
                    self.crypto.price = newPrice
                    print("Updated \(self.crypto.symbol) price to \(newPrice)")
                }
            } else {
                print("Unexpected WebSocket data format: \(json ?? [:])")
            }
        } catch {
            print("Failed to parse WebSocket message: \(error)")
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("WebSocket disconnected for \(crypto.symbol)")
    }

    private var pingTimer: Timer?

    init(crypto: Crypto) {
        self.crypto = crypto
        super.init()
        connectToWebSocket(for: crypto.symbol)
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    deinit {
        pingTimer?.invalidate()
        disconnect()
    }

    // MARK: - URLSessionWebSocketDelegate Methods
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected for \(crypto.symbol)")
        receiveMessage() // Start listening for messages
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket closed for \(crypto.symbol) with code: \(closeCode)")
        reconnect()
    }

    private func reconnect() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            print("Attempting to reconnect for \(self.crypto.symbol)...")
            self.connectToWebSocket(for: self.crypto.symbol)
        }
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { error in
            if let error = error {
                print("Ping failed for \(self.crypto.symbol): \(error)")
            } else {
                print("Ping sent for \(self.crypto.symbol)")
            }
        }
    }
    
}
