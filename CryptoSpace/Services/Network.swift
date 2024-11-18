import SwiftUI

class APIService: ObservableObject {
@Published var cryptos: [Crypto] = []

let baseURL = "https://288b-2a02-2f0a-7612-4400-b5cf-e4f0-3c73-1091.ngrok-free.app"

func getUsers() {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { fatalError("Missing URL") }

    let urlRequest = URLRequest(url: url)

    let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        if let error = error {
            print("Request error: ", error)
            return
        }

        guard let response = response as? HTTPURLResponse else { return }

        if response.statusCode == 200 {
            guard let data = data else { return }
            DispatchQueue.main.async {
                do {
                    let decodedUsers = try JSONDecoder().decode([User].self, from: data)
                    self.users = decodedUsers
                } catch let error {
                    print("Error decoding: ", error)
                }
            }
        }
    }

    dataTask.resume()
}
}
