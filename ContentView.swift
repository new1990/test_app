import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var userId = UUID().uuidString
    @State private var matchedUserId: String?
    @State private var isMatching = false
    private let db = Firestore.firestore()

    var body: some View {
        VStack {
            if let matchedUserId = matchedUserId {
                // ✅ マッチング後に `CallView` を表示し通話開始
                CallView(matchedUserId: matchedUserId)
            } else {
                Button(action: startMatching) {
                    Text("通話を開始")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isMatching)
            }
        }
        .padding()
    }

    func startMatching() {
        isMatching = true
        let waitingRef = db.collection("waiting_users")

        waitingRef.getDocuments { snapshot, error in
            if let error = error {
                print("エラー: \(error)")
                isMatching = false
                return
            }

            if let documents = snapshot?.documents, !documents.isEmpty {
                let matchedUser = documents.first!
                let matchedUserId = matchedUser.documentID

                let callSession = db.collection("calls").document()
                callSession.setData([
                    "user1": userId,
                    "user2": matchedUserId,
                    "status": "matched",
                    "createdAt": FieldValue.serverTimestamp()
                ])

                waitingRef.document(matchedUserId).delete()

                self.matchedUserId = matchedUserId
                self.isMatching = false
                print("✅ マッチング成功！相手のID: \(matchedUserId)")

            } else {
                waitingRef.document(userId).setData([
                    "userId": userId,
                    "createdAt": FieldValue.serverTimestamp()
                ])

                print("🔵 待機リストに追加: \(userId)")
                isMatching = false
            }
        }
    }
}
