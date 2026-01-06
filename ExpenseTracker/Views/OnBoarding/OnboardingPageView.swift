//
//  OnboardingPageView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Image
            Image(systemName: page.imageName)
                .font(.system(size: 120))
                .foregroundStyle(page.imageColor.gradient)
                .symbolEffect(.bounce, value: appeared)
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 50)
                .animation(.spring(duration: 0.8, bounce: 0.4).delay(0.2), value: appeared)
            
            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.spring(duration: 0.8).delay(0.4), value: appeared)
                
                // Subtitle
                Text(page.subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(duration: 0.8).delay(0.5), value: appeared)
            }
            .padding(.horizontal, 40)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(duration: 0.8).delay(0.6), value: appeared)
            
            Spacer()
        }
        .onAppear {
            appeared = true
        }
    }
}

#Preview {
    OnboardingPageView(page: OnboardingPage.pages[0])
}
