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
                    Color(.systemGray4)
                    Image(systemName: "video.slash")
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 300, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 17))
            
            // (اختياري) إذا كنت تريدين إضافة طبقة العنوان والقلب هنا كما كانت سابقاً
            // يمكنك إضافتها في هذا المكان
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
        
        // 2. تجهيز الفيديو أول مرة
        .onAppear {
            if player == nil {
                // 👇 التعديل هنا: نستخدم الرابط المباشر من المودل (CloudKit)
                if let url = video.videoURL {
                    let newPlayer = AVPlayer(url: url)
                    newPlayer.isMuted = true // كتم الصوت (للعرض التلقائي)
                    
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
        let screenHeight = UIScreen.main.bounds.height
        let screenCenter = screenHeight / 2
        
        // المسافة المسموحة (منطقة الوسط) - مثلاً 150 نقطة فوق وتحت المنتصف
        let threshold: CGFloat = 150
        
        // هل الكرت قريب من منتصف الشاشة؟
        let isCentered = abs(screenCenter - midY) < threshold
        
        if isCentered {
            // إذا كان في الوسط وهو طافي -> شغله
            if !isPlaying {
                player?.play()
                isPlaying = true
            }
        } else {
            // إذا بعد عن الوسط وهو يشتغل -> وقفه
            if isPlaying {
                player?.pause()
                isPlaying = false
            }
        }
    }
}

#Preview {
    // تحديث البيانات لتناسب المودل الجديد
    VideoCardView(video: VideoItem(
        title: "تجربة",
        details: "وصف طويل",
        videoURL: nil,
        isFavorite: false,
        categoryName: "عام"
    ))
}
