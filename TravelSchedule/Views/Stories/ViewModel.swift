import Foundation
import SwiftUI

// MARK: - Stories View Model
final class StoriesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var stories: [Stories]
    @Published var showStoryView: Bool = false
    
    // MARK: - Initialization
    init() {
        self.stories = [
            Stories(previewImage: "TwoPassengersPreview", BigImage: "TwoPassengersBig"),
            Stories(previewImage: "TrainMountainPreview", BigImage: "TrainMountainBig"),
            Stories(previewImage: "TrainFloversPreview", BigImage: "TrainFloversBig"),
            Stories(previewImage: "PassengersPreview", BigImage: "PassengersBig"),
            Stories(previewImage: "ManWithAccordionPreview", BigImage: "ManWithAccordionBig"),
            Stories(previewImage: "MachineWorkerPreview", BigImage: "MachineWorkerBig"),
            Stories(previewImage: "GrannyWithVegetablesPreview", BigImage: "GrannyWithVegetablesBig"),
            Stories(previewImage: "FreeSpacePreview", BigImage: "FreeSpaceBig"),
            Stories(previewImage: "ConductorGirlPreview", BigImage: "ConductorGirlBig")
        ]
    }
}
