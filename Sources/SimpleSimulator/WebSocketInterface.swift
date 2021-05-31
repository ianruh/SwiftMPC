import Vapor

public class WebSocket {
    var app: Application
    var ws: WebSocketKit.WebSocket? = nil

    public init?() {
        do {
            let app = try Application(.detect())
            self.app = app
        } catch {
            print("Can't start app: \(error)")
            return nil
        }

        app.webSocket("stream") { req, ws in
            self.ws = ws
        }
        
        do {
            try self.app.run()
        } catch {
            print("Couldn't run app: \(error)")
            return nil
        }
    }

    public func writeString(_ str: String) throws {
        if let ws = self.ws {
            ws.send(str)
        } else {
            throw SimpleSimulatorError.misc("The websocket has no client yet.")
        }
    }

    deinit {
        self.app.shutdown()
    }
}