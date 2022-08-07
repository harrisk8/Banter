# Banter

Banter is a geo-centric social media platform for psuedo-anonymous communication for college campuses. I spent about 1.5 years putting this project together, starting out with nothing more than a very ambiguous idea of what I wanted to create.

**I want to emphasize I built this project before I studied data structures/algorithms and higher-level CS topics in depth. Looking back, there's so much in this codebase I would do differently, knowing what I know now.**

The platform was built via Swift, Storyboard/SwiftUI, and Firebase.

Banter had made it to final beta testing when, due to competitve pressures and lack of capital, the project was scrapped.

-Data schema design can make life easier or a LOT harder later on as more features are added. Take time to make it right and future-proof.
-Don't jump into writing code too quickly without taking enough time to plan what you are going to code.
-Writing clean code takes effort but is critical as a codebase grows and new people join the project. Don't neglect this or you WILL pay the price for it later.
-Writing documentation isn't super exciting but neither is the frusutration of not having good documentation when you need it.
-It's a good idea to containerize one's build and test on various machines early on, not just one or two devices. We had some irreproducible bugs related to this.
-If certain logic doesn't absolutely need to be on the client-side, then put it in the backend or else you uncessarily decrease performance.
-If you find yourself writing highly inefficient algorithms to process data, then there's probably an issue with the data architecture. No need for a cubic time algorithm.

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


