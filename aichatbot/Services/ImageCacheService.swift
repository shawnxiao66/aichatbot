//
//  ImageCacheService.swift
//  aichatbot
//
//  Created for AI Chatbot App - Image Caching Optimization
//

import SwiftUI
import UIKit

// MARK: - Image Cache Service (Thread-Safe)
actor ImageCacheService {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, UIImage>()
    private let maxCacheSize = 50 * 1024 * 1024 // 50MB
    
    private init() {
        cache.totalCostLimit = maxCacheSize
        cache.countLimit = 100
    }
    
    // MARK: - Get Cached Image
    func getImage(from urlString: String) -> UIImage? {
        return cache.object(forKey: urlString as NSString)
    }
    
    // MARK: - Load and Cache Image
    func loadImage(from urlString: String) async -> UIImage? {
        // Check cache first
        if let cachedImage = getImage(from: urlString) {
            return cachedImage
        }
        
        // Load image
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            // Load image data
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            // Resize large images to improve performance
            let maxDimension: CGFloat = 800
            let resizedImage = resizeImageIfNeeded(image, maxDimension: maxDimension)
            
            // Cache the image
            let cost = Int(resizedImage.size.width * resizedImage.size.height * 4)
            cache.setObject(resizedImage, forKey: urlString as NSString, cost: cost)
            
            return resizedImage
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
    
    // Helper method to resize images if they're too large
    private func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSize = max(size.width, size.height)
        
        // If image is smaller than max dimension, return as is
        guard maxSize > maxDimension else {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let ratio = maxDimension / maxSize
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - Cached AsyncImage View (Simple Wrapper)
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let urlString: String?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    
    init(
        urlString: String?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.urlString = urlString
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task(id: urlString) {
            guard let urlString = urlString, !urlString.isEmpty else {
                return
            }
            
            // Check cache first
            let cachedImage = await ImageCacheService.shared.getImage(from: urlString)
            if let cachedImage = cachedImage {
                self.image = cachedImage
                return
            }
            
            // Load from network
            let loadedImage = await ImageCacheService.shared.loadImage(from: urlString)
            self.image = loadedImage
        }
    }
}
