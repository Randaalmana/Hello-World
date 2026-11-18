import Foundation

/// أي شي يقدر يحفظ ويقرأ بيانات التطبيق
/// (protocol عشان في الاختبارات نستخدم نسخة وهمية بدل الجهاز)
protocol DataStore {
    func load() -> AppData
    func save(_ data: AppData)
}

/// الحفظ الحقيقي في الجهاز (UserDefaults)
struct Storage: DataStore {
    private let key = "learningData"

    func load() -> AppData {
        guard let saved = UserDefaults.standard.data(forKey: key),
              let data = try? JSONDecoder().decode(AppData.self, from: saved)
        else { return AppData() }
        return data
    }

    func save(_ data: AppData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
