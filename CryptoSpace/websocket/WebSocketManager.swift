import SwiftUI

class WebSocketManager: NSObject, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?

    init(url: URL) {
        super.init()
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession.webSocketTask(with: url)
        connect()
    }

    private func connect() {
        webSocketTask?.resume()
        receiveMessage() // Start listening for messages
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received message: \(text)")
                    // Optionally: Handle message update in the UI
                    DispatchQueue.main.async {
                        self?.messageReceived(text)
                    }
                case .data(let data):
                    print("Received binary data: \(data)")
                @unknown default:
                    print("Received an unknown message type")
                }
                // Continue to listen for more messages
                self?.receiveMessage()
            case .failure(let error):
                print("Failed to receive message: \(error)")
            }
        }
    }

    private func messageReceived(_ text: String) {
        // Handle the received message as needed
        print("Message received and handled: \(text)")
    }

    deinit {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
