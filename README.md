# TimesSquare

TimesSquare is a library to display a calendar in a view in your iPhone or iPad app. We wrote it after searching high and low for a better way and finding none.

## Usage
![Gregorian Calendar](https://github.com/square/objc-TimesSquare/raw/master/Documentation/gregorian.png)

Easy: create an instance of `TSQCalendarView`. Set its `firstDate` and `lastDate` properties to give yourself a range of dates.

## Calendars
![Hebrew Calendar](https://github.com/square/objc-TimesSquare/raw/master/Documentation/hebrew.png)

While we fully expect you'll use it to display a Gregorian calendar most of the time, TimesSquare is just as happy displaying any of the calendars `NSCalendar` supports. The included test app shows you how to do this.

## Customization

The main reason none of the other calendar libraries out there worked for us was that they couldn't be customized to get the look we wanted.

The way `TSQCalendarView` works is similar to the way `UITableView` works. (In fact, it's implemented internally using a `UITableView`, though that doesn't particularly matter.) It uses two cell classes, one for the month headers and one for the week rows.

You can (and should) subclass `TSQCalendarRowCell` to provide your own background images; additionally, you can set the cell's text color and shadow offsets.

Since you'll likely want to lay out views of whatever type you create in seven columns, `TSQCalendarCell` has a `-layoutViewsForColumnAtIndex:inRect:` method that your subclass should implement. It properly takes in to account things like right-to-left layout and dividing 320 by 7 and rounding to the right integer.

## Contributing

We're glad you're interested in TimesSquare, and we'd love to see where you take it.

Any contributors to the master TimesSquare repository must sign the [Individual Contributor License Agreement (CLA)](https://spreadsheets.google.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1). It's a short form that covers our bases and makes sure you're eligible to contribute.

When you have a change you'd like to see in the master repository, [send a pull request](https://github.com/square/objc-TimesSquare/pulls). Before we merge your request, we'll make sure you're in the list of people who have signed a CLA.

Thanks, and happy testing!