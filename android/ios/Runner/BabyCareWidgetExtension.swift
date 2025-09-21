import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Configuration
@available(iOS 16.1, *)
struct BabyCareLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FeedingActivityAttributes.self) { context in
            // Lock Screen/Banner UI
            BabyCareActivityView(context: context)
                .activityBackgroundTint(Color.pink.opacity(0.1))
                .activitySystemActionForegroundColor(Color.pink)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "figure.and.child.holdinghands")
                            .foregroundColor(.pink)
                        Text("Feeding")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.elapsedTime)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.pink)
                        .fontWeight(.semibold)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text("Baby Feeding in Progress")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button(intent: StopFeedingIntent()) {
                                Label("Stop", systemImage: "stop.circle")
                                    .font(.caption2)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.pink)
                            
                            Button(intent: LogUrineIntent()) {
                                Label("Urine", systemImage: "drop")
                                    .font(.caption2)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            } compactLeading: {
                // Compact leading (left pill)
                Image(systemName: "figure.and.child.holdinghands")
                    .foregroundColor(.pink)
            } compactTrailing: {
                // Compact trailing (right pill)
                Text(context.state.elapsedTime)
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.pink)
                    .fontWeight(.semibold)
            } minimal: {
                // Minimal presentation
                Image(systemName: "figure.and.child.holdinghands")
                    .foregroundColor(.pink)
            }
        }
    }
}

// MARK: - Activity Attributes & State
struct FeedingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startTime: Date
        var elapsedTime: String
        var isActive: Bool
    }
    
    var feedingType: String = "Regular"
}

// MARK: - Main Activity View
@available(iOS 16.1, *)
struct BabyCareActivityView: View {
    let context: ActivityViewContext<FeedingActivityAttributes>
    
    var body: some View {
        HStack(spacing: 16) {
            // App icon and status
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "figure.and.child.holdinghands")
                        .foregroundColor(.pink)
                        .font(.title2)
                    Text("BabyCare")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text("Feeding in Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Timer and actions
            VStack(alignment: .trailing, spacing: 8) {
                // Elapsed time
                Text(context.state.elapsedTime)
                    .font(.title.monospacedDigit())
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(intent: StopFeedingIntent()) {
                        HStack(spacing: 4) {
                            Image(systemName: "stop.circle.fill")
                            Text("Stop")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    
                    Button(intent: LogUrineIntent()) {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                            Text("Urine")
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                    }
                    
                    Button(intent: LogStoolIntent()) {
                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                            Text("Stool")
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.brown.opacity(0.2))
                        .foregroundColor(.brown)
                        .cornerRadius(16)
                    }
                }
            }
        }
        .padding(16)
    }
}

// MARK: - App Intents for Interactive Actions
@available(iOS 16.0, *)
struct StopFeedingIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Feeding"
    static var description = IntentDescription("Stops the current feeding session")
    
    func perform() async throws -> some IntentResult {
        // This will be called when user taps "Stop" in Live Activity
        // Communicate with the main app to stop feeding
        await BabyCareActivityManager.shared.stopFeeding()
        return .result()
    }
}

@available(iOS 16.0, *)
struct LogUrineIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Urine"
    static var description = IntentDescription("Logs a urination event")
    
    func perform() async throws -> some IntentResult {
        // Log urine event
        await BabyCareActivityManager.shared.logUrine()
        return .result()
    }
}

@available(iOS 16.0, *)
struct LogStoolIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Stool"
    static var description = IntentDescription("Logs a stool event")
    
    func perform() async throws -> some IntentResult {
        // Log stool event
        await BabyCareActivityManager.shared.logStool()
        return .result()
    }
}

// MARK: - Activity Manager
@available(iOS 16.1, *)
class BabyCareActivityManager: ObservableObject {
    static let shared = BabyCareActivityManager()
    private var currentActivity: Activity<FeedingActivityAttributes>?
    
    private init() {}
    
    func startFeedingActivity() async {
        let attributes = FeedingActivityAttributes()
        let state = FeedingActivityAttributes.ContentState(
            startTime: Date(),
            elapsedTime: "00:00",
            isActive: true
        )
        
        do {
            let activity = try Activity<FeedingActivityAttributes>.request(
                attributes: attributes,
                contentState: state,
                pushType: .token
            )
            currentActivity = activity
            
            // Start timer to update elapsed time
            startTimer()
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }
    
    func stopFeeding() async {
        currentActivity = nil
        // Communicate with Flutter app
        await notifyFlutterApp(action: "stop_feeding")
    }
    
    func logUrine() async {
        // Communicate with Flutter app
        await notifyFlutterApp(action: "log_urine")
    }
    
    func logStool() async {
        // Communicate with Flutter app  
        await notifyFlutterApp(action: "log_stool")
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, let activity = self.currentActivity else {
                timer.invalidate()
                return
            }
            
            let elapsed = Date().timeIntervalSince(activity.contentState.startTime)
            let minutes = Int(elapsed) / 60
            let seconds = Int(elapsed) % 60
            let timeString = String(format: "%02d:%02d", minutes, seconds)
            
            let updatedState = FeedingActivityAttributes.ContentState(
                startTime: activity.contentState.startTime,
                elapsedTime: timeString,
                isActive: true
            )
            
            Task {
                await activity.update(using: updatedState)
            }
        }
    }
    
    private func notifyFlutterApp(action: String) async {
        // This would communicate with the Flutter app through method channels
        // Implementation depends on how Flutter <-> Native communication is set up
        print("Notifying Flutter app: \(action)")
    }
}