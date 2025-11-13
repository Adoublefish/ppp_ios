//
//  MagicEffects.swift
//  ppp
//
//  魔法特效动画系统
//

import SwiftUI

// MARK: - 魔法粒子
struct MagicParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var color: Color
    var rotation: Double
}

// MARK: - 魔法圆阵效果
struct MagicCircleEffect: View {
    @State private var isAnimating = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            outerCircle
            innerCircle
            centerStar
            decorativeStars
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        .onDisappear {
            withAnimation(.easeIn(duration: 0.3)) {
                scale = 0.5
                opacity = 0
            }
        }
    }
    
    private var outerCircle: some View {
        Circle()
            .strokeBorder(
                LinearGradient(
                    colors: [.clowCardPink, .clowCardGold, .clowCardPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .frame(width: 150, height: 150)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
    }
    
    private var innerCircle: some View {
        Circle()
            .strokeBorder(
                LinearGradient(
                    colors: [.clowCardGold, .clowCardPurple, .clowCardPink],
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                ),
                lineWidth: 2
            )
            .frame(width: 100, height: 100)
            .rotationEffect(.degrees(-rotation * 1.5))
            .scaleEffect(scale)
            .opacity(opacity)
    }
    
    private var centerStar: some View {
        Image(systemName: "star.fill")
            .font(.system(size: 30))
            .foregroundStyle(
                LinearGradient(
                    colors: [.clowCardGold, .clowCardPink],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .scaleEffect(scale * 1.2)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation * 0.5))
    }
    
    private var decorativeStars: some View {
        ForEach(0..<6) { index in
            Image(systemName: "sparkles")
                .font(.system(size: 12))
                .foregroundColor(.clowCardGold)
                .offset(
                    x: cos(Double(index) * .pi / 3 + rotation * .pi / 180) * 70,
                    y: sin(Double(index) * .pi / 3 + rotation * .pi / 180) * 70
                )
                .opacity(opacity)
        }
    }
}

// MARK: - 魔法粒子爆发效果
struct MagicParticlesBurst: View {
    @State private var particles: [MagicParticle] = []
    @State private var isAnimating = false
    
    let particleCount = 20
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(particle.color)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
                    .rotationEffect(.degrees(particle.rotation))
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        let colors: [Color] = [.clowCardPink, .clowCardGold, .clowCardPurple, .clowCardBlue, .clowCardGreen]
        
        for i in 0..<particleCount {
            let angle = Double(i) * (360.0 / Double(particleCount)) * .pi / 180
            let distance: CGFloat = 0
            
            let particle = MagicParticle(
                x: 100 + cos(angle) * distance,
                y: 100 + sin(angle) * distance,
                scale: 1.0,
                opacity: 1.0,
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360)
            )
            
            particles.append(particle)
        }
    }
    
    private func animateParticles() {
        for i in 0..<particles.count {
            let angle = Double(i) * (360.0 / Double(particleCount)) * .pi / 180
            let finalDistance: CGFloat = CGFloat.random(in: 80...120)
            
            withAnimation(.easeOut(duration: 0.8).delay(Double(i) * 0.02)) {
                particles[i].x = 100 + cos(angle) * finalDistance
                particles[i].y = 100 + sin(angle) * finalDistance
                particles[i].scale = 0.3
                particles[i].opacity = 0
            }
        }
    }
}

// MARK: - 魔法闪光效果
struct MagicSparkle: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 40))
            .foregroundStyle(
                LinearGradient(
                    colors: [.clowCardGold, .clowCardPink, .clowCardPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) {
                    scale = 1.2
                    opacity = 1.0
                }
                
                withAnimation(.linear(duration: 0.6)) {
                    rotation = 180
                }
                
                withAnimation(.easeIn(duration: 0.3).delay(0.4)) {
                    scale = 0.5
                    opacity = 0
                }
            }
    }
}

// MARK: - 魔法波纹效果
struct MagicRipple: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0.8
    
    var body: some View {
        Circle()
            .strokeBorder(
                LinearGradient(
                    colors: [.clowCardPink, .clowCardGold],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .frame(width: 50, height: 50)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    scale = 4.0
                    opacity = 0
                }
            }
    }
}

// MARK: - 魔法棒挥动效果
struct MagicWandSwipe: View {
    @State private var offset: CGFloat = -200
    @State private var opacity: Double = 0
    @State private var trail: [CGPoint] = []
    
    var body: some View {
        ZStack {
            // 魔法棒轨迹
            Path { path in
                if !trail.isEmpty {
                    path.move(to: trail[0])
                    for point in trail.dropFirst() {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [.clowCardGold, .clowCardPink, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .opacity(opacity)
            
            // 魔法星星
            Image(systemName: "star.fill")
                .font(.system(size: 25))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.clowCardGold, .clowCardPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(x: offset, y: 0)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                offset = 200
                opacity = 1.0
            }
            
            // 生成轨迹点
            for i in 0...20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                    let x = -200 + (400 * CGFloat(i) / 20)
                    let y = sin(Double(i) * 0.3) * 20
                    trail.append(CGPoint(x: x, y: y))
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
            }
        }
    }
}

// MARK: - 组合魔法效果视图
struct MagicEffectOverlay: View {
    @Binding var isShowing: Bool
    let effectType: MagicEffectType
    
    enum MagicEffectType {
        case circle      // 魔法阵
        case burst       // 粒子爆发
        case sparkle     // 闪光
        case ripple      // 波纹
        case wand        // 魔法棒
        case complete    // 完整组合效果
    }
    
    var body: some View {
        ZStack {
            if isShowing {
                switch effectType {
                case .circle:
                    MagicCircleEffect()
                case .burst:
                    MagicParticlesBurst()
                case .sparkle:
                    MagicSparkle()
                case .ripple:
                    MagicRipple()
                case .wand:
                    MagicWandSwipe()
                case .complete:
                    ZStack {
                        MagicCircleEffect()
                        MagicParticlesBurst()
                        MagicSparkle()
                    }
                }
            }
        }
        .onChange(of: isShowing) { oldValue, newValue in
            if newValue {
                // 自动隐藏效果
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isShowing = false
                }
            }
        }
    }
}

// MARK: - 点击魔法效果
struct TapMagicEffect: View {
    let position: CGPoint
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 波纹1
            Circle()
                .strokeBorder(Color.clowCardPink, lineWidth: 2)
                .frame(width: 20, height: 20)
                .scaleEffect(isAnimating ? 3 : 0)
                .opacity(isAnimating ? 0 : 1)
            
            // 波纹2
            Circle()
                .strokeBorder(Color.clowCardGold, lineWidth: 2)
                .frame(width: 20, height: 20)
                .scaleEffect(isAnimating ? 2.5 : 0)
                .opacity(isAnimating ? 0 : 1)
            
            // 星星
            ForEach(0..<8) { i in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor([Color.clowCardPink, Color.clowCardGold, Color.clowCardPurple].randomElement()!)
                    .offset(
                        x: isAnimating ? cos(Double(i) * .pi / 4) * 40 : 0,
                        y: isAnimating ? sin(Double(i) * .pi / 4) * 40 : 0
                    )
                    .opacity(isAnimating ? 0 : 1)
            }
        }
        .position(position)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - 库洛牌翻转效果
struct ClowCardFlipEffect: View {
    let isCompleted: Bool
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    let onFlipComplete: () -> Void
    
    var body: some View {
        ZStack {
            // 魔法光芒
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clowCardGold, .clear],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 100, height: 3)
                    .offset(x: 50)
                    .rotationEffect(.degrees(Double(i) * 45 + rotation))
                    .opacity(isFlipped ? 0 : 1)
            }
            
            // 星星粒子
            ForEach(0..<12) { i in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor([.clowCardGold, .clowCardPink, .clowCardPurple].randomElement()!)
                    .scaleEffect(isFlipped ? 0 : 1)
                    .offset(
                        x: cos(Double(i) * .pi / 6) * (isFlipped ? 80 : 0),
                        y: sin(Double(i) * .pi / 6) * (isFlipped ? 80 : 0)
                    )
            }
        }
        .scaleEffect(scale)
        .onAppear {
            performFlipAnimation()
        }
    }
    
    private func performFlipAnimation() {
        // 第一阶段：缩放和旋转
        withAnimation(.easeIn(duration: 0.3)) {
            rotation = 360
            scale = 1.3
        }
        
        // 第二阶段：翻转
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.4)) {
                isFlipped = true
                scale = 1.0
            }
            onFlipComplete()
        }
    }
}

// MARK: - 魔法棒敲击特效
struct MagicWandTapEffect: View {
    @State private var showWand = false
    @State private var wandPosition: CGFloat = -100
    @State private var showSparkles = false
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 魔法棒
            Image(systemName: "wand.and.stars")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.clowCardGold, .clowCardPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(-45))
                .offset(x: 50, y: wandPosition)
                .opacity(showWand ? 1 : 0)
            
            // 敲击星星爆发
            if showSparkles {
                ForEach(0..<16) { i in
                    Image(systemName: "sparkles")
                        .font(.system(size: CGFloat.random(in: 10...20)))
                        .foregroundColor([.clowCardGold, .clowCardPink, .clowCardPurple, .clowCardBlue].randomElement()!)
                        .scaleEffect(scale)
                        .offset(
                            x: cos(Double(i) * .pi / 8) * 60 * scale,
                            y: sin(Double(i) * .pi / 8) * 60 * scale
                        )
                        .opacity(1 - Double(scale))
                }
            }
            
            // 冲击波
            if showSparkles {
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.clowCardPink, .clear],
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale * 2)
                    .opacity(1 - Double(scale))
            }
        }
        .onAppear {
            performTapAnimation()
        }
    }
    
    private func performTapAnimation() {
        // 魔法棒下落
        withAnimation(.easeOut(duration: 0.3)) {
            showWand = true
            wandPosition = 20
        }
        
        // 敲击效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showSparkles = true
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
            }
            
            // 魔法棒消失
            withAnimation(.easeIn(duration: 0.2)) {
                showWand = false
                wandPosition = 100
            }
        }
    }
}

// MARK: - 魔法效果管理器
class MagicEffectManager: ObservableObject {
    @Published var tapEffects: [(id: UUID, position: CGPoint)] = []
    
    func addTapEffect(at position: CGPoint) {
        let effect = (id: UUID(), position: position)
        tapEffects.append(effect)
        
        // 1秒后移除效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tapEffects.removeAll { $0.id == effect.id }
        }
    }
}

