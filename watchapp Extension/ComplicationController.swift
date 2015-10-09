//
//  ComplicationController.swift
//  EveryStep
//
//  Created by Stuart Buchbinder on 10/7/15.
//  Copyright © 2015 nakkotech. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let currentUser = ESUserController.defaultController.currentUser()
    

    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.None])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        handler(timelineEntryForStepCount())
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    /** Run once per initialization */
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerTextProvider = CLKSimpleTextProvider(text: "steps: 0", shortText: "step")
        template.body1TextProvider = CLKSimpleTextProvider(text: "calories: 0", shortText: "cal")
        template.body2TextProvider = CLKSimpleTextProvider(text: "miles: 0", shortText: "mi")
        
        handler(template)
    }
    
    
    func timelineEntryForStepCount() -> CLKComplicationTimelineEntry? {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        
        template.headerTextProvider = CLKSimpleTextProvider(text: "steps: 0", shortText: "step")
        template.body1TextProvider = CLKSimpleTextProvider(text: "calories: 0", shortText: "cal")
        template.body2TextProvider = CLKSimpleTextProvider(text: "miles: 0", shortText: "mi")
        
        let date = NSDate().dateByAddingTimeInterval(-60)
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        
    }
}
