Learning Journey
Learning Journey: is an iOS app that helps you build a daily learning habit. Set a learning goal, log each day you learn, and keep your streak alive with a limited number of freezes.

( Main Features )
- Set a learning goal: choose what you want to learn and a duration (Week, Month, or Year).
- Log a day as Learned: tap once per day to grow your streak.
- Freeze a day: protect your streak on days you can't learn, with a confirmation alert.
- 2 freezes per week
- 8 freezes per month
- 96 freezes per year
  
Smart buttons:
- Only one action per day (Learned or Freeze).
- The Freeze button is disabled when all freezes are used.
- Buttons are enabled again at 12 AM, even if you logged at 11 PM.
- Streak rules: the streak resets after more than 32 hours without logging, or when the learning goal is updated.
- Weekly view: see the current week at a glance (🟠 learned, 🔵 freezed, today highlighted).
  
Goal results:
- Will done! when the goal is completed.
- You didn't reach your goal this time. when the streak is broken.
- Change your learning goal at any time, with an alert that warns the streak will start over.
- Set a new goal after finishing, starting fresh from today.
- Activities calendar: scroll through the full year to see every learned and freezed day (view only).

Project Structure:

LearningApp
 Model          → Data types, storage, demo data
 ViewModel      → App logic (streak, freezes, goal state)
 View           → Screens
 Components     → Reusable UI (buttons, cards, alerts, day circles)
 Helpers        → Colors and date tools
