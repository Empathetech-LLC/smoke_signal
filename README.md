Smoke Signal is a user first, zero social algorithms, zero forceed advertisements social media app.

Smoke Signal intends to be a familiar community building tool, without all the non-sense. The price for non-sense removal is whatever your personal server cost to run Smoke Signal is. More on that later.

## Table of Contents

* [Ingredients](#Ingredients)
* [Contributing](#Contributing)
* [Contact](#Contact)
* [License](#License)
* [Credits](#Credits)

# Ingredients

The front end is built with [Flutter](https://flutter.dev/), which allows for instant (ish) cross platform development. The back end is built with [Firebase](https://firebase.google.com/), which has all the pros/cons of a [BaaS](https://www.cloudflare.com/learning/serverless/glossary/backend-as-a-service-baas/). For Smoke Signal, we're happy to use Firebase for the great Flutter libraries (both are Google products) and the solid [free tier](https://firebase.google.com/pricing).

# Contributing

## Time

You can open an issue, start a discussion, or [reach out](mailto:support@empathetech.net) about becomming a contributor.

Smoke Signal is released under the [GNU GPLv3 License](LICENSE)

If you're comfortable please send/post some custom themes and activity boards! I'd love to see what people create!

## Money

Much thanks for any and all donations. Hopefully Empathetech has earned it making your life a little easier.

### Paypal

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=NGEL6AB5A6KNL)

### Venmo

[@empathetech-llc](https://venmo.com/empathetech-llc)

### Cash App

[$empathetech](https://cash.app/$empathetech)

# Contact

[Us](mailto:support@empathetech.net)

# License

[GNU GPLv3](LICENSE)

# Credits

## Freelance support

None, yet.

## Community support/free assets

[pimen](https://pimen.itch.io/) for making the art for the default active image (Smoke Signal)

[edermunizz](https://edermunizz.itch.io/) for making the art for the "Dark Forest" background

[brullov](https://brullov.itch.io/) for making the art for the "Oak Forest" background

[trixelized](https://trixelized.itch.io/) for making the art for the "Stary Forest" background

[freepik]("https://www.freepik.com/") for making the loading .gif and no image icon

## Flutter libraries

- [Flutter colorpicker](https://pub.dev/packages/flutter_colorpicker)
- [Email validator](https://pub.dev/packages/email_validator)
- [Local notifications](https://pub.dev/packages/flutter_local_notifications)
- [Launcher icons](https://pub.dev/packages/flutter_launcher_icons)

## ...and last, but certainly not least...

YouTube tutorial makers, Medium article writers, Stack Overflow folx, and friends. You're the bridge between an idea and action.

# Using the app

If you're the skim-reading type, you can stop now! Just open the app and mess around! Hopefully it's intuitive. [If not...](#Contributing)

## Login/Sign up

Email/password combinations given in the sign up screen will be automatically stored in the [Firebase Firestore](https://firebase.google.com/docs/firestore).

Once added, users will be able to use the login screen.

<img src="/docs/assets/signup.png" alt="Smoke Signal Sign up screen" width="250"/> <img src="/docs/assets/login.png" alt="Smoke Signal Login screen" width="250"/>

*NOTE:* Currently, the only way to update an existing user's password is manually in the [Firebase Console](https://console.firebase.google.com) (under Authentication).

## Signals/Activities 

Once signed in, users will be greeted by the activity board where they can join, edit, and/or create activities.

<img src="/docs/assets/home-1.png" alt="Smoke Signal activity board" width="250"/> <img src="/docs/assets/home-edit.png" alt="Smoke Signal editing activity" width="250"/> <img src="/docs/assets/pit.png" alt="Smoke Signal new activity screen" width="250"/>

Tapping an activity will add/remove you from the list of participants and send out a signal to the rest of your group. Long pressing an activity will open the options dialog. 

In it's default state, Smoke Signal is intentionally opaque: you cannot see who is doing the activity, only the number of participants. The idea behind it is to take all the competition out of the social media aspect of the app and only keep the sense of community.

If that doesn't suit your needs, then by all means: [make it work for you](#Contributing)

Whenever visible, the setings hamburger will open links to the theme editing pages (colors, images, and fonts).

<img src="/docs/assets/hamburger.png" alt="Smoke Signal hamburger menu" width="250"/>

Oh, and don't worry, you won't accidentally logout a bunch (there's a prompt for that)...

<img src="/docs/assets/logout.png" alt="Smoke Signal logout prompt" width="250"/>

## Customization

Everything is customizable in Smoke Signal...

...the activities,

<img src="/docs/assets/home-1.png" alt="Smoke Signal activity board" width="250"/> <img src="/docs/assets/home-edit.png" alt="Smoke Signal editing activity" width="250"/> <img src="/docs/assets/pics.png" alt="Smoke Signal activity board with custom icons" width="250"/>

the colors,

<img src="/docs/assets/colors-1.png" alt="Smoke Signal editing colors" width="250"/> <img src="/docs/assets/colors-2.png" alt="Smoke Signal editing colors" width="250"/>

the images,

<img src="/docs/assets/images-1.png" alt="Smoke Signal editing images" width="250"/> <img src="/docs/assets/images-2.png" alt="Smoke Signal editing images" width="250"/>

and the fonts

<img src="/docs/assets/fonts.png" alt="Smoke Signal editing fonts" width="250"/>