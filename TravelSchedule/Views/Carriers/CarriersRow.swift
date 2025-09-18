
import SwiftUI

// MARK: - CarriersRowView

struct CarriersRowView: View {
    
    // MARK: - Properties
    
    var route: CarrierRoute
    
    // MARK: - Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
                .padding(.bottom, 5)
            timelineView
        }
        .padding()
        .background(Color.appLightGray)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Views
    
    private var headerView: some View {
        HStack(alignment: .top) {
            Image(route.carrierImage)
                .resizable()
                .frame(width: 38, height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(route.carrierName)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blackUniversal)
                
                if let note = route.note {
                    Text(note)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.redUniversal)
                }
            }
            
            Spacer()
            
            Text(route.date)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.redUniversal)
        }
    }
    
    private var timelineView: some View {
        HStack {
            Text(route.departureTime)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.blackUniversal)
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.appGray)
            
            Text(route.duration)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.blackUniversal)
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.appGray)
            
            Text(route.arrivalTime)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.blackUniversal)
        }
    }
}
