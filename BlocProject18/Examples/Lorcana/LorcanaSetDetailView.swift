//
//  LorcanaSetDetailView.swift
//  BlocProject18
//
//  Created by Cursor on 19/01/2026.
//

import Bloc
import SwiftUI

struct LorcanaSetDetailView: View {
    
    let setName: String
    let lorcanaBloc = BlocRegistry.resolve(LorcanaBloc.self)
    
    @State private var setCards: [LorcanaCard] = []
    @State private var isLoading = true
    @State private var error: LorcanaError?
    @State private var hasLoaded = false
    
    private let networkService = LorcanaNetworkService()
    
    var body: some View {
        ZStack {
            // Dark magical background
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.08, blue: 0.14),
                    Color(red: 0.10, green: 0.06, blue: 0.16),
                    Color(red: 0.04, green: 0.04, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle pattern
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(Color.purple.opacity(Double.random(in: 0.02...0.06)))
                        .frame(width: CGFloat.random(in: 100...300))
                        .position(
                            x: CGFloat.random(in: -50...geometry.size.width + 50),
                            y: CGFloat.random(in: -50...geometry.size.height + 50)
                        )
                        .blur(radius: 40)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Set header
                setHeader
                
                // Content
                if isLoading {
                    loadingView
                } else if let error = error {
                    errorView(error: error)
                } else if setCards.isEmpty {
                    emptyView
                } else {
                    cardsGrid
                }
            }
        }
        .navigationTitle(setName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.06, green: 0.08, blue: 0.14), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .task {
            // Only load once when view first appears
            guard !hasLoaded else { return }
            await loadSetCards()
        }
    }
    
    // MARK: - Set Header
    
    private var setHeader: some View {
        VStack(spacing: 12) {
            // Set icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 6) {
                Text("SET COLLECTION")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(3)
                    .foregroundColor(.gray)
                
                Text(setName)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if !setCards.isEmpty {
                    Text("\(setCards.count) cards")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.purple.opacity(0.8))
                }
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Cards Grid
    
    private var cardsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(setCards) { card in
                    NavigationLink(destination: LorcanaCardDetailView(card: card)) {
                        cardGridItem(card: card)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    private func cardGridItem(card: LorcanaCard) -> some View {
        VStack(spacing: 8) {
            // Card image
            AsyncImage(url: URL(string: card.image ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    cardPlaceholder(card: card)
                case .empty:
                    cardPlaceholder(card: card)
                        .overlay(
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.7)
                        )
                @unknown default:
                    cardPlaceholder(card: card)
                }
            }
            .aspectRatio(0.714, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: inkColorForCard(card).opacity(0.3), radius: 6, y: 3)
            
            // Card name
            Text(card.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 30)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
        )
    }
    
    private func cardPlaceholder(card: LorcanaCard) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [inkColorForCard(card), inkColorForCard(card).opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.4))
            )
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.purple)
                .scaleEffect(1.2)
            
            Text("Loading set cards...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(error: LorcanaError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Failed to load cards")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(error.message)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                Task { await loadSetCards() }
            } label: {
                Text("Retry")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.minus")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No cards found")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text("This set doesn't have any cards yet")
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Load Data
    
    private func loadSetCards() async {
        isLoading = true
        error = nil
        
        do {
            setCards = try await networkService.fetchCardsFromSet(setName: setName, page: 1, pageSize: 100)
            isLoading = false
            hasLoaded = true
        } catch {
            self.error = LorcanaError(message: error.localizedDescription)
            isLoading = false
            hasLoaded = true
        }
    }
    
    // MARK: - Helpers
    
    private func inkColorForCard(_ card: LorcanaCard) -> Color {
        switch card.inkColor {
        case .amber: return Color(red: 1.0, green: 0.75, blue: 0.2)
        case .amethyst: return Color(red: 0.6, green: 0.3, blue: 0.9)
        case .emerald: return Color(red: 0.2, green: 0.75, blue: 0.4)
        case .ruby: return Color(red: 0.9, green: 0.2, blue: 0.3)
        case .sapphire: return Color(red: 0.2, green: 0.5, blue: 0.9)
        case .steel: return Color(red: 0.6, green: 0.6, blue: 0.65)
        case .unknown: return Color.gray
        }
    }
}

#Preview {
    NavigationStack {
        LorcanaSetDetailView(setName: "The First Chapter")
    }
}
