# TimesSquare

TimesSquare is a library to display a calendar in a view in your iPhone or iPad app. We wrote it after searching high and low for a better way and finding none.

## Installation

### Using CocoaPods

In your Podfile:

```pod 'TimeSquare', :tag => '<repo-tag>'```

or if you want to live straight of this repository:

``` pod 'TimeSquare', :git => 'https://github.com/square/objc-TimesSquare.git', :tag='<repo-tag>'```

where ```repo-tag``` is the tagged version of the project that you want your application to depend on. 

This will take care of adding both the code and the resource bundle for the default look into the pod for your application. 

### Using submodules

```git submodule add git://github.com/square/objc-TimesSquare.git TimesSquare```

Then drag the ```TimesSquare``` project into your workspace. 

Open up the ```Products``` folder in the TimesSquare project and drag the TimesSquare product into the ```Target Dependencies``` phase of your application target Build Phases. In order to get the default resource in your application, also drag the TimesSquareResources product into the ```Copy Bundle Resources``` Build Phase for your application target. 


## Usage
![Gregorian Calendar](https://github.com/square/objc-TimesSquare/raw/master/Documentation/gregorian.png)

Easy: create an instance of `TSQCalendarView`. Set its `firstDate` and `lastDate` properties to give yourself a range of dates.

## Calendars
![Hebrew Calendar](https://github.com/square/objc-TimesSquare/raw/master/Documentation/hebrew.png)

While we fully expect you'll use it to display a Gregorian calendar most of the time, TimesSquare is just as happy displaying any of the calendars `NSCalendar` supports. The included test app shows you how to do this.

## Further documentation

If you install [appledoc](http://gentlebytes.com/appledoc/) ("`brew install appledoc`") you can build the "TimesSquare Documentation" target in Xcode and see (and search!) the full API in your documentation window.

## Contributing

We're glad you're interested in TimesSquare, and we'd love to see where you take it.

Any contributors to the master TimesSquare repository must sign the [Individual Contributor License Agreement (CLA)](https://spreadsheets.google.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1). It's a short form that covers our bases and makes sure you're eligible to contribute.

When you have a change you'd like to see in the master repository, [send a pull request](https://github.com/square/objc-TimesSquare/pulls). Before we merge your request, we'll make sure you're in the list of people who have signed a CLA.

Thanks, and happy testing!