import SwiftUI
import AVKit

struct VideoCardView: View {
    let video: VideoItem
    var onFavoriteTapped: (() -> Void)? = nil
    
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false // متغير عشان نعرف حالة الفيديو
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // 1. طبقة الفيديو
            ZStack {
                Color.black
                
                if let player = player {
                    VideoPlayer(player: player)
                        .disabled(true) // نمنع لمس الفيديو عشان السكرول
                } else {
                    Color(.systemGray)
                    Image(systemName: "video.slash")
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 300, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 17))
            
             
        }
        .frame(width: 300, height: 180)
        
        // 👇 1. هذا الكود السحري: قارئ الموقع في الخلفية
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.frame(in: .global).midY) { oldVal, newVal in
                        // نحسب موقع الكرت بالنسبة للشاشة
                        checkVisibility(midY: newVal)
                    }
                    // للأجهزة القديمة (iOS 16 وتحت) أو أول مرة يشتغل
                    .onAppear {
                        checkVisibility(midY: proxy.frame(in: .global).midY)
                    }
            }
        )
        
        // 2. تجهيز الفيديو أول مرة (بدون تشغيل)
        .onAppear {
            if player == nil {
                if let url = Bundle.main.url(forResource: video.imageName, withExtension: "mov") {
                    let newPlayer = AVPlayer(url: url)
                    newPlayer.isMuted = true // كتم الصوت
                    
                    // التكرار (Loop)
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: newPlayer.currentItem, queue: .main) { _ in
                        newPlayer.seek(to: .zero)
                        newPlayer.play()
                    }
                    self.player = newPlayer
                }
            }
        }
        // 3. توقف نهائي عند الخروج من الصفحة
        .onDisappear {
            player?.pause()
            isPlaying = false
        }
    }
    
    // 👇 دالة الذكاء: تقرر هل نشغل الفيديو ولا لا
    func checkVisibility(midY: CGFloat) {
//        let screenHeight = UIScreen.main.bounds.height
//        let screenCenter = screenHeight / 2
        
        // المسافة المسموحة (منطقة الوسط) - مثلاً 150 نقطة فوق وتحت النص
//        let threshold: CGFloat = 150
        
        // هل الكرت قريب من نص الشاشة؟
//        let isCentered = abs(screenCenter - midY) < threshold
        
//        if isCentered {
            if !isPlaying {
                player?.play()
                isPlaying = true
            }
//        } else {
            if isPlaying {
                player?.pause()
                isPlaying = false
            }
        }
    }
//}

#Preview {
    VideoCardView(video: VideoItem(description: "تجرية", imageName: "demo1", isFavorite: false))
}

