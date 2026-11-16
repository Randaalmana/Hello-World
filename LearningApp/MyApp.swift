import SwiftUI

@main
struct LearningAppApp: App {
    @State private var learning = LearningViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(learning)
                .preferredColorScheme(.dark)
                .tint(.appOrange)
        }
    }
}
