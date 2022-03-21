//
//  DateExtension.swift
//  stockTracker
//
//  Created by 蕭鈺蒖 on 2022/3/21.
//

import Foundation
import QuartzCore


extension Date{

  func dateAt(hours: Int, minutes: Int) -> Date{
      
      let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
      calendar.timeZone = TimeZone(identifier: "America/New_York")!
      
      var dateComponents = calendar.components([NSCalendar.Unit.year,
                                                NSCalendar.Unit.month,
                                                NSCalendar.Unit.day], from: self)
      dateComponents.hour = hours
      dateComponents.minute = minutes
      
      let newDate = calendar.date(from:dateComponents)!
      return newDate
  }
}



