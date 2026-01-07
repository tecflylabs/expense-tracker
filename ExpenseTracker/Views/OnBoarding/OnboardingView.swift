//
//  OnboardingView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPage = 0
    
    private let pages = OnboardingPage.pages
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    currentPage == 0 ? Color.blue.opacity(0.1) :
                        currentPage == 1 ? Color.orange.opacity(0.1) :
                        currentPage == 2 ? Color.green.opacity(0.1) :
                        Color.orange.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Skip")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        if page.isProPage {
                            ProOnboardingPageView()
                                .tag(index)
                        } else {
                            OnboardingPageView(page: page)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.brandOrange : Color.secondary.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Pro page - only "Maybe Later" button
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Maybe Later")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 20)
                        
                    } else if currentPage == pages.count - 2 {
                        // Last regular page (before Pro)
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                            HapticManager.shared.impact(style: .light)
                        } label: {
                            HStack {
                                Text("Next")
                                    .font(.headline)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandOrange.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                    } else {
                        // Next button (other pages)
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                            HapticManager.shared.impact(style: .light)
                        } label: {
                            HStack {
                                Text("Next")
                                    .font(.headline)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandOrange.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.spring(duration: 0.4), value: currentPage)
                .padding(.bottom, 40)
            }
        }
        .interactiveDismissDisabled()
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

#Preview {
    OnboardingView()
}
