import SwiftUI
import WebRTC

struct CallView: View {
    var matchedUserId: String  // マッチング相手のID
    private var callManager = CallManager()  // CallManagerをインスタンス化

    var body: some View {
        VStack {
            Text("通話中: \(matchedUserId)")
                .font(.title)
                .padding()

            Button(action: endCall) {
                Text("通話終了")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            startCall()
        }
    }

    func startCall() {
        // CallManagerを使用して通話開始処理を呼び出し
        callManager.startCall(matchedUserId: matchedUserId)
    }

    func endCall() {
        // CallManagerを使用して通話終了処理を呼び出し
        callManager.endCall()
    }
}
