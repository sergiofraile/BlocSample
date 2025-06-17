//
//  ContentView.swift
//  BlocProject
//
//  Created by Sergio Fraile on 28/04/2025.
//

import SwiftUI

struct ContentView: View {
//    @State private var count = 0
    let count = 9
    var body: some View {
        VStack {
            Text("Counter: \(count)")
                .font(.largeTitle)
                .bold()
                
//            
//            HStack {
//                Button(action: {
//                    count -= 1
//                }) {
//                    Image(systemName: "minus.circle")
//                        .font(.largeTitle)
//                }
//                
//                Button(action: {
//                    count += 1
//                }) {
//                    Image(systemName: "plus.circle")
//                        .font(.largeTitle)
//                }
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

}

#Preview {
    ContentView()
}
