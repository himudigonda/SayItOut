import Foundation

class NetworkService {
    static let shared = NetworkService()

    func generateSpeech(text: String) async throws -> URL {
        guard let url = URL(string: "http://127.0.0.1:8000/tts/") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["text": text]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let audioPath = json["audio_url"],
                  let downloadURL = URL(string: audioPath) else {
                throw NetworkError.invalidData
            }

            return downloadURL
        } catch {
            throw error
        }
    }

    enum NetworkError: Error {
        case invalidURL
        case invalidResponse(statusCode: Int)
        case invalidData
        case unknown(Error)
    }
}
