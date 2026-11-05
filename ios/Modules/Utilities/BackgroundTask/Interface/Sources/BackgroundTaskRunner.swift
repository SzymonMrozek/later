/// Keeps work running for a while when the app moves to the background in the middle of it.
public protocol BackgroundTaskRunner {
    /// Runs `work`, asking the system for time to finish it should the app leave the foreground
    /// meanwhile. `name` shows up in the debugger and in system logs.
    func run<Value>(named name: String, _ work: () async -> Value) async -> Value
}
