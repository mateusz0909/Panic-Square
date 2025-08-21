//
//  AboutSheetView.swift
//  Breathe Easy
//
//  Created by Mateusz Byrtus on 05/08/2025.
//


//
//  AboutSheetView.swift
//  BreatheEasy
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct AboutSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            AboutView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    }
                }
        }
        .presentationBackground(Color("BackgroundColor"))
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
