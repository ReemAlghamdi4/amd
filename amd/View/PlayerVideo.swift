import SwiftUI
import AVKit

struct PlayerVideo: View {
    // نستقبل الفيديو والفيو مودل
    let video: VideoItem
    @ObservedObject var viewModel: PlaceViewModel
    
    // مشغل الفيديو
    @State private var player: AVPlayer?
    
    // متغيرات التحكم بالوقت
    @State private var isPlaying = false
    @State private var videoDuration: Double = 0
    @State private var currentTime: Double = 0
    @State private var timeObserver: Any?
    
    // للتحقق من المفضلة بشكل مباشر
    var isFavorite: Bool {
        // نبحث في الفيو مودل هل هذا الفيديو مفضل أم لا
        return viewModel.favoriteVideos.contains(where: { $0.id == video.id })
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
 Spacer()
            
            // --- مشغل الفيديو ---
            ZStack {
                Color.black
                if let player = player {
                    VideoPlayer(player: player)
                        .allowsHitTesting(false) // يخفي تحكم النظام الافتراضي
                }
            }
            .frame(height: 304) // العرض يأخذ الشاشة تلقائياً
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
            
            // --- العنوان والمفضلة ---
            HStack {
                // زر المفضلة
                Button(action: {
                    withAnimation {
                        viewModel.toggleFavorite(for: video.id)
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(isFavorite ? .red : .gray)
                }
                
                Spacer()
                
                // عنوان الفيديو (من البيانات)
                Text(video.description)
                    .font(.custom("IBMPlexSansArabic-Bold", size: 20))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            
            // --- شريط التمرير (Slider) ---
            VStack(spacing: 5) {
                Slider(value: Binding(
                    get: { currentTime },
                    set: { newValue in
                        currentTime = newValue
                        let seek = CMTime(seconds: newValue, preferredTimescale: 600)
                        player?.seek(to: seek)
                    }
                ), in: 0...videoDuration)
                .accentColor(Color("blue4")) // تأكد أن اللون مضاف في Assets
                
                // توقيت الفيديو
                HStack {
                    Text(formatTime(currentTime)).font(.caption2)
                    Spacer()
                    Text(formatTime(videoDuration)).font(.caption2)
                }
                .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // --- أزرار التحكم (Custom Controls) ---
            HStack(spacing: 40) {
                // إرجاع 10 ثواني
                Button {
                    let newTime = max(currentTime - 10, 0)
                    let seekTime = CMTime(seconds: newTime, preferredTimescale: 600)
                    player?.seek(to: seekTime)
                    currentTime = newTime
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundColor(Color("blue4"))
                        .frame(width: 40, height: 40)
                }

                // تشغيل / إيقاف مؤقت
                Button {
                    if isPlaying {
                        player?.pause()
                    } else {
                        player?.play()
                    }
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(Color("blue4"))
                        .frame(width: 60, height: 60)
                        .background(
                            Circle().fill(Color("blue4").opacity(0.2))
                        )
                }

                // تقديم 10 ثواني
                Button {
                    let newTime = min(currentTime + 10, videoDuration)
                    let seekTime = CMTime(seconds: newTime, preferredTimescale: 600)
                    player?.seek(to: seekTime)
                    currentTime = newTime
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(Color("blue4"))
                        .frame(width: 40, height: 40)
                }
            }
            
            Divider().padding(.vertical)
            
            // --- الوصف والشرح ---
            VStack(alignment: .trailing, spacing: 8) {
                Text("وصف المقطع")
                    .font(.custom("IBMPlexSansArabic-Bold", size: 18))
                
                // هنا الوصف الطويل (حالياً ثابت، ممكن تضيف خاصية longDescription للمودل لاحقاً)
                Text((video.description) )
                    .font(.custom("IBMPlexSansArabic-Regular", size: 16))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
                    .lineSpacing(5)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)
            
            Spacer()
        }
        .environment(\.layoutDirection, .leftToRight) // السلايدر يحتاج اتجاه انجليزي عشان يضبط، لكن النصوص بنضبطها يدوياً
        .background(Color(.systemBackground))
        // تجهيز المشغل عند فتح الصفحة
        .onAppear {
            setupPlayer()
        }
        // تنظيف الذاكرة عند الإغلاق
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    // دالة تنسيق الوقت (0:00)
    func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    // دالة تجهيز الفيديو
    func setupPlayer() {
        if let url = Bundle.main.url(forResource: video.imageName, withExtension: "mov") {
            let newPlayer = AVPlayer(url: url)
            self.player = newPlayer
            
            // جلب مدة الفيديو
            Task {
                if let duration = try? await newPlayer.currentItem?.asset.load(.duration) {
                    self.videoDuration = CMTimeGetSeconds(duration)
                }
            }
            
            // مراقبة وقت التشغيل للسلايدر
            timeObserver = newPlayer.addPeriodicTimeObserver(
                forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
                queue: .main
            ) { time in
                self.currentTime = CMTimeGetSeconds(time)
            }
            
            newPlayer.play()
            isPlaying = true
        }
    }
}


#Preview {
    PlayerVideo(
        video: VideoItem(description: "تجربة", imageName: "demo1", isFavorite: true),
        viewModel: PlaceViewModel()
    )
}
