import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct CreateGameResponse: Codable {
    let game_id: String
}

struct GuessRequest: Codable {
    let game_id: String
    let guess: String
}

struct GuessResponse: Codable {
    let black: Int
    let white: Int
}

struct ErrorResponse: Codable {
    let error: String
}

final class MastermindAPI {
    private let baseURL: String
    private let session: URLSession

    init(baseURL: String) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        self.session = URLSession(configuration: config)
    }

    func createGame() throws -> String {
        guard let url = URL(string: "\(baseURL)/game") else { throw NSError(domain: "URL", code: 0) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        let (data, resp) = try syncRequest(req)
        guard let http = resp as? HTTPURLResponse else { throw NSError(domain: "HTTP", code: -1) }
        if http.statusCode == 200 {
            let res = try JSONDecoder().decode(CreateGameResponse.self, from: data)
            return res.game_id
        } else {
            let err = decodeError(from: data) ?? "Error \(http.statusCode)"
            throw NSError(domain: "CreateGame", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: err])
        }
    }

    func guess(gameId: String, guess: String) throws -> GuessResponse {
        guard let url = URL(string: "\(baseURL)/guess") else { throw NSError(domain: "URL", code: 0) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = GuessRequest(game_id: gameId, guess: guess)
        req.httpBody = try JSONEncoder().encode(body)
        let (data, resp) = try syncRequest(req)
        guard let http = resp as? HTTPURLResponse else { throw NSError(domain: "HTTP", code: -1) }
        if http.statusCode == 200 {
            return try JSONDecoder().decode(GuessResponse.self, from: data)
        } else {
            let err = decodeError(from: data) ?? "Error \(http.statusCode)"
            throw NSError(domain: "Guess", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: err])
        }
    }

    func deleteGame(gameId: String) {
        guard let url = URL(string: "\(baseURL)/game/\(gameId)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        _ = try? syncRequest(req)
    }

    private func decodeError(from data: Data) -> String? {
        if let err = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return err.error
        }
        return nil
    }

    private func syncRequest(_ req: URLRequest) throws -> (Data, URLResponse) {
        final class Holder {
            var data: Data?
            var resp: URLResponse?
            var err: Error?
        }
        let holder = Holder()
        let done = DispatchSemaphore(value: 0)
        session.dataTask(with: req) { data, resp, err in
            holder.data = data
            holder.resp = resp
            holder.err = err
            done.signal()
        }.resume()
        _ = done.wait(timeout: .now() + 30)
        if let e = holder.err { throw e }
        guard let d = holder.data, let r = holder.resp else {
            throw NSError(domain: "Network", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No response from server"])
        }
        return (d, r)
    }
}

func prompt(_ message: String) -> String? {
    print(message, terminator: "")
    return readLine()
}

func isExit(_ s: String?) -> Bool {
    guard let s = s else { return false }
    return s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "exit"
}

func normalize(_ s: String?) -> String {
    return (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
}

func validateGuess(_ s: String) -> Bool {
    if s.count != 4 { return false }
    for ch in s {
        if ch < "1" || ch > "6" { return false }
    }
    return true
}

let defaultBase = ProcessInfo.processInfo.environment["MASTERMINDSERVER"] ?? "https://mastermind.darkube.app"
let api = MastermindAPI(baseURL: defaultBase)

print("""
===============================
🎯 Mastermind Game (Terminal)
Server: \(defaultBase)
Rules:
- Enter a 4-digit guess (digits 1–6).
- B = correct digit in correct place.
- W = correct digit in wrong place.
- Type 'exit' anytime to quit.
===============================

""")

var gameId: String? = nil

do {
    print("Creating new game...")
    let gid = try api.createGame()
    gameId = gid
    print("✅ Game created. ID: \(gid)\n")

    while true {
        let input = prompt("Enter your guess (e.g. 1234) or 'exit': ")
        if isExit(input) {
            print("👋 Exiting...")
            break
        }
        let guess = normalize(input)
        if !validateGuess(guess) {
            print("⚠️ Invalid guess. Must be 4 digits between 1–6.\n")
            continue
        }
        do {
            guard let gid = gameId else { throw NSError(domain: "State", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid game ID"]) }
            let res = try api.guess(gameId: gid, guess: guess)
            let b = String(repeating: "B", count: res.black)
            let w = String(repeating: "W", count: res.white)
            print("Result: \(b)\(w)\n")
            if res.black == 4 {
                print("🎉 You guessed the code!")
                break
            }
        } catch {
            print("❌ Guess failed: \(error.localizedDescription)\n")
        }
    }
} catch {
    print("❌ Game creation failed: \(error.localizedDescription)")
}

if let gid = gameId {
    api.deleteGame(gameId: gid)
}
print("Done.")
