//
//  LorcanaView.swift
//  BlocProject18
//
//  Created by Cursor on 19/01/2026.
//

import Bloc
import SwiftUI

struct LorcanaView: View {
    
    let lorcanaBloc = BlocRegistry.resolve(LorcanaBloc.self)
    
    @State private var searchText: String = ""
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Magical gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.06, blue: 0.14),
                        Color(red: 0.12, green: 0.08, blue: 0.20),
                        Color(red: 0.06, green: 0.04, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Starfield effect
                GeometryReader { geometry in
                    ForEach(0..<30, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                            .frame(width: CGFloat.random(in: 1...3))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar and fetch all button
                    searchBarSection
                    
                    // Content
                    contentView
                }
            }
            .navigationTitle("Lorcana Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.08, green: 0.06, blue: 0.14), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(.white)
    }
    
    // MARK: - Search Bar
    
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                TextField("Search cards...", text: $searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: searchText) { _, newValue in
                        handleSearchChange(newValue)
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchTask?.cancel()
                        lorcanaBloc.send(.clear)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
            
            // Fetch All button
            Button {
                searchText = ""
                searchTask?.cancel()
                lorcanaBloc.send(.fetchAllCards)
            } label: {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.6, green: 0.3, blue: 0.9),
                                Color(red: 0.4, green: 0.2, blue: 0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
            }
        }
        .frame(maxWidth: 600)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        let state = lorcanaBloc.state
        
        if state.isLoading && state.cards.isEmpty {
            loadingView
        } else if let error = state.error, state.cards.isEmpty {
            errorView(error: error)
        } else if state.cards.isEmpty && !state.isSearching {
            initialStateView
        } else if state.cards.isEmpty && state.isSearching {
            noResultsView
        } else {
            cardsListView
        }
    }
    
    // MARK: - Initial State
    
    private var initialStateView: some View {
        VStack(spacing: 28) {
            // Magic portal icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.6, green: 0.3, blue: 0.9),
                                Color(red: 0.4, green: 0.2, blue: 0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .purple.opacity(0.5), radius: 20, y: 8)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("DISNEY")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(6)
                    .foregroundColor(.gray)
                
                Text("Lorcana")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(red: 0.8, green: 0.7, blue: 1.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Card Collection")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 8) {
                Text("Search for cards or tap the sparkle")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("button to browse all cards")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
            }
            
            Text("Summoning cards...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Cards List
    
    private var cardsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(lorcanaBloc.state.cards) { card in
                    NavigationLink(destination: LorcanaCardDetailView(card: card)) {
                        cardRow(card: card)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        // Trigger load more when near the end
                        if card == lorcanaBloc.state.cards.last {
                            lorcanaBloc.send(.loadNextPage)
                        }
                    }
                }
                
                // Loading more indicator
                if lorcanaBloc.state.isLoadingMore {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(.purple)
                        Text("Loading more...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 20)
                }
                
                // End of list indicator
                if !lorcanaBloc.state.hasMorePages && !lorcanaBloc.state.cards.isEmpty {
                    Text("You've seen all \(lorcanaBloc.state.cards.count) cards!")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Card Row
    
    private func cardRow(card: LorcanaCard) -> some View {
        HStack(spacing: 14) {
            // Card image thumbnail
            AsyncImage(url: URL(string: card.image ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    inkColorPlaceholder(card: card)
                case .empty:
                    inkColorPlaceholder(card: card)
                        .overlay(ProgressView().tint(.white))
                @unknown default:
                    inkColorPlaceholder(card: card)
                }
            }
            .frame(width: 60, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Card info
            VStack(alignment: .leading, spacing: 6) {
                Text(card.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // Cost badge
                    if let cost = card.cost {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 10))
                            Text("\(cost)")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(inkColorForCard(card))
                    }
                    
                    // Type
                    if let type = card.type {
                        Text(type)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    // Rarity
                    if let rarity = card.rarity {
                        Text("• \(rarity)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                // Set name
                if let setName = card.setName {
                    Text(setName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.8))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Stats column
            VStack(alignment: .trailing, spacing: 4) {
                if let strength = card.strength {
                    statBadge(icon: "bolt.fill", value: strength, color: .orange)
                }
                if let willpower = card.willpower {
                    statBadge(icon: "shield.fill", value: willpower, color: .blue)
                }
                if let lore = card.lore {
                    statBadge(icon: "star.fill", value: lore, color: .yellow)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [inkColorForCard(card).opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func inkColorPlaceholder(card: LorcanaCard) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [inkColorForCard(card), inkColorForCard(card).opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private func statBadge(icon: String, value: Int, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text("\(value)")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(color)
    }
    
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
    
    // MARK: - Error View
    
    private func errorView(error: LorcanaError) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(error.message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                lorcanaBloc.send(.fetchAllCards)
            } label: {
                Text("Try Again")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - No Results View
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No cards found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Try a different search term")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Search Logic
    
    private func handleSearchChange(_ newValue: String) {
        // Cancel any pending search
        searchTask?.cancel()
        
        // Only search when we have 3+ characters
        guard newValue.count >= 3 else {
            if newValue.isEmpty {
                lorcanaBloc.send(.clear)
            }
            return
        }
        
        // Debounce the search
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            guard !Task.isCancelled else { return }
            
            lorcanaBloc.send(.search(query: newValue))
        }
    }
}

#Preview {
    NavigationStack {
        LorcanaView()
    }
}
