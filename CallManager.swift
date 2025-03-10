import WebRTC

// SignalingDelegateをCallManager内に定義
protocol SignalingDelegate {
    func sendOffer(_ offer: RTCSessionDescription)
    func sendAnswer(_ answer: RTCSessionDescription)
    func sendICECandidate(_ candidate: RTCIceCandidate)
}

class CallManager: NSObject, SignalingDelegate {
    var peerConnectionFactory: RTCPeerConnectionFactory!
    var peerConnection: RTCPeerConnection!
    var localVideoTrack: RTCVideoTrack?
    var localAudioTrack: RTCAudioTrack?

    override init() {
        super.init()
        RTCInitializeSSL()
        peerConnectionFactory = RTCPeerConnectionFactory()
    }

    func startCall(matchedUserId: String) {
        // 通話開始のためのPeerConnection作成
        let config = RTCConfiguration()
        let iceServers = [RTCICEServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        config.iceServers = iceServers
        
        peerConnection = peerConnectionFactory.peerConnection(with: config, constraints: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil), delegate: self)

        // ローカルメディアの設定
        addLocalMedia()

        // オファーを作成してシグナリングサーバーに送信
        createOffer()
    }

    func addLocalMedia() {
        let videoSource = peerConnectionFactory.videoSource()
        localVideoTrack = peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")

        let audioConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        localAudioTrack = peerConnectionFactory.audioTrack(with: audioConstraints, trackId: "audio0")

        peerConnection.add(localVideoTrack!)
        peerConnection.add(localAudioTrack!)
    }

    func createOffer() {
        // オファーを作成して、シグナリングサーバーに送信する（仮想的な例）
        let offerConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peerConnection.offer(for: offerConstraints) { (sdp, error) in
            if let sdp = sdp {
                self.peerConnection.setLocalDescription(sdp) { error in
                    // オファーSDPをシグナリングサーバーに送信
                    self.sendOffer(sdp)
                }
            }
        }
    }

    func createAnswer(offer: RTCSessionDescription) {
        // アンサーを作成して送信
        let answerConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peerConnection.answer(for: answerConstraints) { (sdp, error) in
            if let sdp = sdp {
                self.peerConnection.setLocalDescription(sdp) { error in
                    // アンサーSDPをシグナリングサーバーに送信
                    self.sendAnswer(sdp)
                }
            }
        }
    }

    func endCall() {
        // 通話終了の処理
        peerConnection.close()
        print("📴 通話終了")
    }

    // SignalingDelegateの実装
    func sendOffer(_ offer: RTCSessionDescription) {
        // ここでシグナリングサーバーにオファーを送信する処理を実装
        print("オファーを送信: \(offer.sdp)")
    }

    func sendAnswer(_ answer: RTCSessionDescription) {
        // ここでシグナリングサーバーにアンサーを送信する処理を実装
        print("アンサーを送信: \(answer.sdp)")
    }

    func sendICECandidate(_ candidate: RTCIceCandidate) {
        // ここでICE候補をシグナリングサーバーに送信する処理を実装
        print("ICE候補を送信: \(candidate.sdp)")
    }
}
