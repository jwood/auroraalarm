The Aurora application (http://auroraalarm.net) monitors space and local weather,
and will alert users when conditions are optimal for viewing the Aurora Borealis
in their area.


# How the app works
## Signup
* User can sign up via the site or via SMS by texting 'AURORA' and their zip code to 839863 (AURORA 90210).
* User can update their zip code at any time by texting 'AURORA' and their zip code to 839863.
* User can cancel the service at any time by texting 'STOP' to 839863.

## The space event notification
* Once a day the app checks to see if any space weather watches have been issued due to solar activity.
  * If a watch has been issued, the app asks users if they would like to be notified if conditions are optimal for viewing an aurora.
    * If the user replies Y, we will monitor their local conditions, and notifiy them if the aurora should be visible.
    * If the user replies N (or doesn't reply at all), we won't send them any aurora alerts.

## The aurora alert
* Every few minutes, we will check to see if conditions are optimal for viewing the aurora.  Optimal conditions are:
  * Kp index at or above storm level (> 4)
  * Kp index is strong enough to push the aurora down to the user's geomagnetic latitude.
  * It is nighttime
  * The moon is dark
  * The skies are clear
* If all conditions are met, an alert will be sent to the user.
* Alerts will be sent every few minutes until the user confirms the alert (to make sure they wake up).
* The user will have the option to discontinue alerts for the night, or to be reminded later on that night.


# Sections
The app is broken up into a few main sections.

## The website
The site is where users can find out more about the service, and sign up.

## Incoming SMS message handlers
The incoming sms handler and its various handler classes contain the processing
logic for all incoming SMS messages.

## The cron controller
A controller that is used to kick off periodic tasks via web requests, since
heroku's free cron option isn't very robust.

## Service classes
Classes that interact with external services to check weather conditions, send SMS messages, etc.

## Database classes
Classes that fetch and persist data in the database.

