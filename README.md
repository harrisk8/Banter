# Banter

Banter is a geo-centric social media platform for psuedo-anonymous communication for college campuses. I spent about 1.5 years putting this project together, starting out with nothing more than a very ambiguous idea of what I wanted to create.

**I want to emphasize I built this project before I studied data structures/algorithms and higher-level CS topics in depth. Looking back, there's so much in this codebase I would do differently, knowing what I know now.**

The platform was built via Swift, Storyboard/SwiftUI, and Firebase. There was a little JavaScript (Firebase Functions) and Ruby (CocoaPods).

**Banter had made it to final beta testing when, due to competitve pressures and lack of capital, the project was scrapped.**

## A few lessons learned
1. Data schema design can make life easier or a LOT harder later on as more features are added. Take time to make it right and future-proof.
2. Don't jump into writing code too quickly without taking enough time to plan what you are going to code.
3. Writing clean code takes effort but is critical as a codebase grows and new people join the project. Don't neglect this or you WILL pay the price for it later.
4. Writing documentation isn't super exciting but neither is the frusutration of not having good documentation when you need it.
5. It's a good idea to containerize one's build and test on various machines early on, not just one or two devices. We had some irreproducible bugs related to this.
6. If certain logic doesn't absolutely need to be on the client-side, then put it in the backend or else you uncessarily decrease performance.
7. If you find yourself writing highly inefficient algorithms to process data, then there's probably an issue with the data architecture itself. No need for a cubic time algorithm!
8. Running meetings is hard- it's an art. Go in with a highly specific plan and objective or you will waste time.
9. Fail fast and fail often. Ship features and don't dwell on perfecting them too much. No point to an amazing feeature if it doesn't get in people's hands.
10. Building the **notification system** was one of the hardest parts because the original data schema design decisions backfired big time. NoSQL was an easy initial choice but documents alone did not confer an easy data-collection mechanism for populating the notification screen. 
11. **Do not over-optimize and, as I heard Elon Musk once say, do not optimize things that shouldn't exist in the first place. Firebase charged $0.18/100K writes and $0.06/100K reads. I took this constaint too seriously and it skewed many of my engineering decisions and slowed down progress.**



<p float="left">
  <img src="/Banter/Banter_Signup.gif" width="250">
  <img src="/Banter/Banter_Screenshot.PNG" width="250" > 
  <img src="/Banter/New Post Screen.png" width="250" > 

</p>


## Systems Design

<img src="/Banter/Banter Systems Design.png" width="900" >

## Database Schema 

<img src="/Banter/Banter Database Schema.png" width="900">

## Startup Logic (old version)

<img src="/Banter/Banter Startup Logic.png" width="900">


