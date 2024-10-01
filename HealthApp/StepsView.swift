//
//  StepsView.swift
//  HealthApp
//
//  Created by Irina Chitu on 30.09.2024.
//

import SwiftUI

struct StepsView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack {
            Text("Current number of steps: \(healthKitManager.stepsCount)")
        }
    }
}

#Preview {
    StepsView(healthKitManager: HealthKitManager())
}
