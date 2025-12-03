import SwiftUI
import AVKit
import AVFoundation

struct PlayerVideo: View {
    let player: AVPlayer
    @State private var isFavorite = false
    @State private var isPlaying = false
    @State private var videoDuration: Double = 0
    @State private var currentTime: Double = 0
    @State private var timeObserver: Any?
    var body: some View {
        VStack(spacing: 24) {
            
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 60, height: 5)
                .padding(.top, 8)
            
            // --- VIDEO WITH NO SYSTEM CONTROLS ---
            VideoPlayer(player: player)
                .frame(width: 366, height: 304)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .allowsHitTesting(false)   // this prevents showing controls but keeps video working
            
            HStack {
                Button(action: { isFavorite.toggle() }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(isFavorite ? .red : .gray)
                }
                
                Spacer()
                
                Text("ألم في الاذن")
                    .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                    .foregroundColor(.primary)
            }
            

            Slider(value: Binding(
                get: { currentTime },
                set: { newValue in
                    currentTime = newValue
                    let seek = CMTime(seconds: newValue, preferredTimescale: 600)
                    player.seek(to: seek)
                }
            ), in: 0...videoDuration
            ).accentColor(.blue4)
            
            // ---- TIME LABELS ----
            HStack {
               // Spacer()
                Text(formatTime(currentTime)).font(.caption2)
                Spacer()
                Text(formatTime(videoDuration)).font(.caption2)
            }
                
                // --- CUSTOM PLAYBACK CONTROLS ---
            HStack(spacing: 40) {
                // --- Backward 10s ---
                Button {
                    let newTime = max(currentTime - 10, 0) // prevent negative time
                    let seekTime = CMTime(seconds: newTime, preferredTimescale: 600)
                    player.seek(to: seekTime)
                    currentTime = newTime
                } label: {
                    Image(systemName: "backward.fill")
                        .foregroundColor(Color.blue4)
                        .font(.title2)
                        .frame(width: 40, height: 40)
//                        .background(
//                            Circle()
//                                .fill(Color.blue4.opacity(0.2))
//                        )
                }

                // --- Play / Pause ---
                Button {
                    if isPlaying {
                        player.pause()
                    } else {
                        player.play()
                    }
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(Color.blue4)
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color.blue4.opacity(0.3))
                        )
                        .shadow(radius: 3)
                }

                // --- Forward 10s ---
                Button {
                    let newTime = min(currentTime + 10, videoDuration) // prevent overflow
                    let seekTime = CMTime(seconds: newTime, preferredTimescale: 600)
                    player.seek(to: seekTime)
                    currentTime = newTime
                } label: {
                    Image(systemName: "forward.fill")
                        .foregroundColor(Color.blue4)
                        .font(.title2)

                      
                }
            }

                .font(.title2)
                
                VStack(alignment: .center, spacing: 8) {
                    Text("وصف المقطع")
                        .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                    
                    Text("أحس بألم في أذني من يومين، الألم مزعج، مرات قوي ومرات يخف، وإذا لمستها يزيد أكثر...")
                        .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            
            .onAppear {
                        // get duration
                        if let duration = player.currentItem?.asset.duration {
                            videoDuration = CMTimeGetSeconds(duration)
                        }
                        
                        // update current time periodically
                        timeObserver = player.addPeriodicTimeObserver(
                            forInterval: CMTime(seconds: 0.3, preferredTimescale: 600),
                            queue: .main
                        ) { time in
                            currentTime = CMTimeGetSeconds(time)
                        }
                    }
        }.padding()
    }
    func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
    #Preview {
        PlayerVideo(player: AVPlayer(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!))
    }

