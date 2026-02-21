//
//  ContentView.swift
//  fude-frontend
//
//  Created by John Johnston on 2/21/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AuthGateView()
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}
