//
//  LorcanaCardDetailView.swift
//  BlocProject18
//
//  Created by Cursor on 19/01/2026.
//

import SwiftUI

struct LorcanaCardDetailView: View {
    
    let card: LorcanaCard
    @State private var imageLoaded = false
    
    var body: some View {
        ZStack {
            // Background gradient matching ink color
            LinearGradient(
                colors: [
                    inkColorForCard(card).opacity(0.15),
                    Color(red: 0.06, green: 0.04, blue: 0.12),
                    Color(red: 0.08, green: 0.06, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Card image
                    cardImageSection
                    
                    // Card name and type
                    headerSection
                    
                    // Stats row
                    if hasStats {
                        statsSection
                    }
                    
                    // Card details
                    detailsSection
                    
                    // Set info (tappable)
                    if let setName = card.setName {
                        setSection(setName: setName)
                    }
                    
                    // Flavor text
                    if let flavorText = card.flavorText, !flavorText.isEmpty {
                        flavorTextSection(flavorText: flavorText)
                    }
                    
                    // Body text / abilities
                    if let bodyText = card.bodyText, !bodyText.isEmpty {
                        bodyTextSection(bodyText: bodyText)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(inkColorForCard(card).opacity(0.3), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }
    
    // MARK: - Card Image
    
    private var cardImageSection: some View {
        AsyncImage(url: URL(string: card.image ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: inkColorForCard(card).opacity(0.5), radius: 20, y: 10)
            case .failure:
                cardPlaceholder
            case .empty:
                cardPlaceholder
                    .overlay(ProgressView().tint(.white))
            @unknown default:
                cardPlaceholder
            }
        }
        .frame(maxWidth: 280)
        .frame(maxWidth: .infinity)
    }
    
    private var cardPlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [inkColorForCard(card), inkColorForCard(card).opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(0.714, contentMode: .fit)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
            )
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(card.name)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                if let type = card.type {
                    Text(type.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .tracking(2)
                        .foregroundColor(inkColorForCard(card))
                }
                
                if let classifications = card.classifications, !classifications.isEmpty {
                    Text("•")
                        .foregroundColor(.gray)
                    Text(classifications)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            if let rarity = card.rarity {
                rarityBadge(rarity: rarity)
            }
        }
    }
    
    private func rarityBadge(rarity: String) -> some View {
        Text(rarity)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(rarityColor(rarity))
            )
    }
    
    private func rarityColor(_ rarity: String) -> Color {
        switch rarity.lowercased() {
        case "common": return .gray
        case "uncommon": return .green
        case "rare": return .blue
        case "super rare": return .purple
        case "legendary": return .orange
        case "enchanted": return Color(red: 1.0, green: 0.8, blue: 0.3)
        default: return .gray
        }
    }
    
    // MARK: - Stats
    
    private var hasStats: Bool {
        card.cost != nil || card.strength != nil || card.willpower != nil || card.lore != nil
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            if let cost = card.cost {
                statCard(title: "INK COST", value: "\(cost)", icon: "drop.fill", color: inkColorForCard(card))
            }
            if let strength = card.strength {
                statCard(title: "STRENGTH", value: "\(strength)", icon: "bolt.fill", color: .orange)
            }
            if let willpower = card.willpower {
                statCard(title: "WILLPOWER", value: "\(willpower)", icon: "shield.fill", color: .blue)
            }
            if let lore = card.lore {
                statCard(title: "LORE", value: "\(lore)", icon: "star.fill", color: .yellow)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Details
    
    private var detailsSection: some View {
        VStack(spacing: 12) {
            if let color = card.color {
                detailRow(label: "Ink Color", value: color, icon: "paintpalette.fill")
            }
            
            if card.inkable == true {
                detailRow(label: "Inkable", value: "Yes", icon: "checkmark.circle.fill")
            } else if card.inkable == false {
                detailRow(label: "Inkable", value: "No", icon: "xmark.circle.fill")
            }
            
            if let artist = card.artist {
                detailRow(label: "Artist", value: artist, icon: "paintbrush.fill")
            }
            
            if let franchises = card.franchises, !franchises.isEmpty {
                detailRow(label: "Franchise", value: franchises, icon: "film.fill")
            }
            
            if let cardNum = card.cardNum, let setNum = card.setNum {
                detailRow(label: "Card Number", value: "\(cardNum) / \(setNum)", icon: "number")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func detailRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(inkColorForCard(card))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Set Section
    
    private func setSection(setName: String) -> some View {
        NavigationLink(destination: LorcanaSetDetailView(setName: setName)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SET")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.gray)
                    
                    Text(setName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(inkColorForCard(card))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [inkColorForCard(card).opacity(0.15), Color.white.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(inkColorForCard(card).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Flavor Text
    
    private func flavorTextSection(flavorText: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FLAVOR TEXT")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.gray)
            
            Text(flavorText)
                .font(.system(size: 14, design: .serif))
                .italic()
                .foregroundColor(Color(red: 0.8, green: 0.75, blue: 0.9))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
        )
    }
    
    // MARK: - Body Text
    
    private func bodyTextSection(bodyText: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ABILITIES")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.gray)
            
            Text(bodyText)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
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
        LorcanaCardDetailView(card: LorcanaCard(
            name: "Mickey Mouse - True Friend",
            artist: "Disney Artist",
            setName: "The First Chapter",
            setNum: 204,
            color: "Amber",
            image: nil,
            cost: 3,
            inkable: true,
            type: "Character",
            classifications: "Storyborn, Hero",
            abilities: "Rush",
            flavorText: "A true friend is always there when you need them.",
            franchises: "Mickey & Friends",
            rarity: "Legendary",
            strength: 3,
            willpower: 4,
            lore: 2,
            cardNum: 1,
            bodyText: "When this character enters play, draw a card.",
            setId: "TFC"
        ))
    }
}
