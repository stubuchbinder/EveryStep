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
        handler(timelineEntryForStepCount(complication))
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
        
        let headerTextProvider = CLKSimpleTextProvider(text: "steps: 0", shortText: "0 s")
        let body1TextProvider = CLKSimpleTextProvider(text: "calories: 0", shortText: "0 cal")
        let body2TextProvider = CLKSimpleTextProvider(text: "distance: 0", shortText: "0 mi")
        
        switch complication.family {
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = headerTextProvider
            template.body1TextProvider = body1TextProvider
            template.body2TextProvider = body2TextProvider
            handler(template)
            
        case .ModularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = headerTextProvider
            handler(template)
            
        case .CircularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = headerTextProvider
            handler(template)
            
            
        default:
            handler(nil)
            
        }

    }
    
    
    func timelineEntryForStepCount(complication : CLKComplication) -> CLKComplicationTimelineEntry? {
        
        let date = NSDate().dateByAddingTimeInterval(-60)
        let steps = "\(self.currentUser.currentSteps)"
        
        let headerTextProvider = CLKRelativeDateTextProvider(date: NSDate(), style: .Natural, units: [.Month, .Day, .Hour, .Minute])
        
        switch complication.family {
            
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = headerTextProvider
            template.body1TextProvider = CLKSimpleTextProvider(text: "steps: \(steps)")
            return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        
        case .ModularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: steps)
            return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            
        case .CircularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: steps)
            return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        default:
            return nil
        }

        
    }
}
