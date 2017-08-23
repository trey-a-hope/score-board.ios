import Foundation
import UIKit

class ConversionService  {
    private static let dateFormatter: DateFormatter = DateFormatter()
    private static let format: String = "yyyy-MM-dd'T'HH:mm:ss"
    
    static func convertStringToDate(_ string: String) -> Date {
        dateFormatter.dateFormat = format
        let date: Date = dateFormatter.date(from: string)!
        return date
    }
    
    static func convertDateToString(_ date: Date, _ style: DateFormatter.Style) -> String {
        dateFormatter.dateStyle = style
        let string: String = dateFormatter.string(from: date)
        return string
    }
    
    static func convertDateToFirebaseString(_ date: Date) -> String {
        dateFormatter.dateFormat = format
        let string: String = dateFormatter.string(from: date)
        return string
    }
    
    static func getDateInTimeZone(_ date: Date, _ timeZoneOffset: Int) -> Date {
        //Get timezone offset of this device.
        let myTimeZoneOffset: Int = Date().getTimeZoneOffset()
        //Subtract the offset of the comparing device.
        let difference: Int = timeZoneOffset - myTimeZoneOffset
        //Multiply the minutes(difference) by 60 to get seconds.
        let newDate: Date = date.addingTimeInterval(TimeInterval(difference * 60))
        return newDate
    }
    
    static func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) yr ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 yr ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hr ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hr ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) min ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 min ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) secs ago"
        } else {
            return "Just now"
        }
    }
}
