# PonyDate

PonyDate is a library to display a calendar in a view in your iPhone or iPad app. We wrote it after searching high and low for a better way and finding none.

## Usage

Easy: create an instance of `PDCalendarView`. Set its `firstDate` and `lastDate` properties to give yourself a range of dates.

## Calendars

While we fully expect you'll use it to display a Gregorian calendar most of the time, PonyDate is just as happy displaying any of the calendars `NSCalendar` supports. The included test app shows you how to do this.

## Customization

The main reason none of the other calendar libraries out there worked for us was that they couldn't be customized to get the look we wanted.

The way `PDCalendarView` works is similar to the way `UITableView` works. (In fact, it's implemented internally using a `UITableView`, though that doesn't particularly matter.) It uses two cell classes, one for the month headers and one for the week rows.

You can (and should) subclass `PDCalendarRowCell` to provide your own background images; additionally, you can set the cell's text color and shadow offsets.

Since you'll likely want to lay out views of whatever type you create in seven columns, `PDCalendarCell` has a `-layoutViewsForColumnAtIndex:inRect:` method that your subclass should implement. It properly takes in to account things like right-to-left layout and dividing 320 by 7 and rounding to the right integer.