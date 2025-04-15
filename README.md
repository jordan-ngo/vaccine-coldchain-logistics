# logistics

CSE 472 Logistics Project

This codebase contains the code for our app.

It is cut into three parts

- Frontend: Uses Flutter, so the files are mostly written in Dart. The backend is used to populate a local database that updates on District Manager edits to refrigerators. Updates create log instances, which are also stored locally until the DM pushes thier updates. Then all the logs are sent to the central database, and the local logs are erased, in order to keep data usage low. System admins can modify the database instantly and directly, reassigning users does not create a log.
- Backend: Uses Django, so the files are mostly python. This represents the central database. All API calls are defined here. There are three main files to care about: models.py (determines the structure of the database's tables and python objects), urls.py (determines which urls will start which api calls), and views.py (defines the api methods, the powerhouse of the backend)
- Online: This is just a copy of the Heroku repo. Because of the way Heroku works, we had to create another git repo on Heroku when deploying the app online. This folder is pretty much just a skimmed down verson of the backend. Just the functions needed for the app as it is currently, no debugging methods and such.
