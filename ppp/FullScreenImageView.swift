//
//  FullScreenImageView.swift
//  ppp
//
//  Created by Kiro on 2025-01-22.
//

import SwiftUI

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Navigation bar
                HStack {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Image with zoom and pan
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            // Magnification gesture for zooming
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(1.0, min(value, 5.0))
                                }
                                .onEnded { _ in
                                    if scale < 1.0 {
                                        withAnimation(.spring()) {
                                            scale = 1.0
                                            offset = .zero
                                        }
                                    }
                                },
                            
                            // Drag gesture for panning
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        // Double tap to zoom
                        withAnimation(.spring()) {
                            if scale > 1.0 {
                                scale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2.0
                            }
                        }
                    }
                
                Spacer()
            }
        }
        .statusBarHidden()
    }
}

// MARK: - Preview
struct FullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenImageView(image: UIImage(systemName: "photo") ?? UIImage())
    }
}