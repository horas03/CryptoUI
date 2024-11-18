import SwiftUI

struct ContentView: View {
    @EnvironmentObject var network: Network

    var body: some View {
        VStack(alignment: .leading) {
            Text("All Cryptos")
                .font(.title)
                .bold()
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(network.cryptos) { crypto in
                        CryptoRow(crypto: crypto)
                    }
                }
            }
            .onAppear {
                network.getCryptos()
            }
        }
        .padding()
    }
}

struct CryptoRow: View {
    @ObservedObject var crypto: Crypto // Observe individual Crypto

    var body: some View {
        HStack {
            Text(crypto.symbol)
                .font(.headline)
                .padding(.trailing, 10)

            VStack(alignment: .leading) {
                Text("Price: \(crypto.price, specifier: "%.2f")")
                    .font(.subheadline)
                Text("Timestamp: \(crypto.timestamp, formatter: dateFormatter)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(10)
        .padding(.bottom, 5)
    }
}

// Date formatter for timestamps
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()



@main
struct CryptoSpaceApp: App {
    var network = Network()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(network)
        }
    }
}
