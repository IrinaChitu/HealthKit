//
//  ConsentView.swift
//  HealthApp
//
//  Created by Irina Chitu on 30.09.2024.
//

import SwiftUI

struct ConsentView: View {
    @ObservedObject var healthKitManager = HealthKitManager()
    
    var body: some View {
        if healthKitManager.permissionsTriggered {
            VStack {
                Spacer()
                
                Text("Consent already given")
                Text("You can edit permissions in Settings")
                
                Spacer()
                
                StepsView(healthKitManager: healthKitManager)
                
                Spacer()
            }
        } else {
            onboarding
        }
    }
    
    var onboarding: some View {
        VStack {
            Text("Do you consent access to HealthKit data?")
            
            HStack {
                Button {
                    healthKitManager.requestAuthorization()
                } label: {
                    Text("Yes")
                }
                .padding(.leading, 100)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("No")
                }
                .padding(.trailing, 100)
            }
        }
    }
}

#Preview {
    ConsentView()
}
