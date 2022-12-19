<p align="center"><img src="assets/images/icon.png" width="150"></a></p> 
<h2 align="center"><b>Box, Box!</b></h2>
<h4 align="center">A new way to follow Formula 1</h4>

[![GitHub releases](https://img.shields.io/github/release/BrightDV/BoxBox?style=for-the-badge)](https://github.com/BrightDV/BoxBox/releases/latest)
[![GitHub issues](https://img.shields.io/github/issues/BrightDV/BoxBox?style=for-the-badge)](https://github.com/BrightDV/BoxBox/issues)
[![GitHub forks](https://img.shields.io/github/forks/BrightDV/BoxBox?style=for-the-badge)](https://github.com/BrightDV/BoxBox/network)
[![GitHub stars](https://img.shields.io/github/stars/BrightDV/BoxBox?style=for-the-badge)](https://github.com/BrightDV/BoxBox/stargazers)
[![GitHub license](https://img.shields.io/github/license/BrightDV/BoxBox?style=for-the-badge)](https://github.com/BrightDV/BoxBox/blob/main/LICENSE)
![Github all releases](https://img.shields.io/github/downloads/BrightDV/BoxBox/total.svg?style=for-the-badge) \
![https://hosted.weblate.org/engage/box-box/](https://hosted.weblate.org/widgets/box-box/-/translations/svg-badge.svg)

## Download

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="80">](https://f-droid.org/packages/org.brightdv.boxbox/)
[<img src="https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white"
     alt="Download from GitHub"
     height="60">](https://github.com/BrightDV/BoxBox/releases/latest)

## Screenshots

[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/0.png" width="235">](fastlane/metadata/android/en-US/images/phoneScreenshots/0.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/1.png" width="235">](fastlane/metadata/android/en-US/images/phoneScreenshots/1.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/2.png" width="235">](fastlane/metadata/android/en-US/images/phoneScreenshots/2.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/3.png" width="235">](fastlane/metadata/android/en-US/images/phoneScreenshots/3.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/4.png" width="235">](fastlane/metadata/android/en-US/images/phoneScreenshots/4.png)
[<img src="fastlane/metadata/android/en-US/images/phoneScreenshots/5.png" width="235">](fastlane/metadata/android/en-US/images/phoneScreenshots/5.png)

## Features

- Box, Box! is copylefted libre software, licensed GPLv3+.
- No ads, no trackers or anything else.
- Get the latest stories of your favorite driver and his ranking, even without any Internet connection*. \
If you want, you can know where he is born and other personal info (not very useful though)…
- In-app reader for all the editorial articles, with markdown!
- Enjoy the app even at night with dark mode.
- Link to the highlights on YouTube of the qualifications and the race. (or even the sprint…)
- Wait till the next race with a countdown.
- Follow all the action on track with integrated WebView (live leaderboard).
- View the results of all the sessions (free practices, qualifying, sprints and races).
- Enjoy the race hub during a GP!

*You need to have Internet connection in order to refresh the data…

See the live demo [here (outdated). It is broken because of the CORS.](https://brightdv.github.io)

## Services used
| Screen  | Service          | URL |
| :---------------: |:---------------:| :---------------:|
| Home News  | Formula 1 API |  https://api.formula1.com |
| Articles search  | SearXNG |  [5 instances](lib/api/searx.dart#L26) |
| Standings (Q, S and R)  | Ergast API |  https://ergast.com/mrd |
| Standings (FP, Q, S and R)  | Formula 1 Archives |  https://formula1.com |
| Schedule  |  Ergast API |  https://ergast.com/mrd |
| Live Timing |  Formula 1 |  https://formula1.com |

## Translation

Help translate _Box, Box!_ on [Hosted Weblate](https://hosted.weblate.org/projects/box-box/)

<a href="https://hosted.weblate.org/engage/box-box/">
<img src="https://hosted.weblate.org/widgets/box-box/-/translations/multi-auto.svg" alt="Translation status" />
</a>

Or, manually:
- Create a file named **[your language ISO code, like en, fr, etc].arb**
Theses files are used by Flutter to provide you the translation.
- Translate [this file](lib/l10n/app_en.arb) to your language (only the text between the quotes).
- Finally, make a pull request or an issue and attach the code to it.

The app is currently available in:
- 🇬🇧 English
- 🇫🇷 French
- 🇳🇴 Norwegian, thanks to @comradekingu
- 🇵🇹 Portuguese, thanks to @Alexthegib
- 🇮🇳 Punjabi & Hindi, thanks to @ShareASmile
- 🇪🇸 Spanish, thanks to @inigochoa
- 🇹🇷 Turkish, thanks to @metezd

... and many others!

## License
[![GNU GPLv3 Image](https://www.gnu.org/graphics/gplv3-127x51.png)](https://www.gnu.org/licenses/gpl-3.0.en.html)  

```
Box, Box! is Free Software: You can use, study, share, and improve it at
will. Specifically you can redistribute and/or modify it under the terms of the
[GNU General Public License](https://www.gnu.org/licenses/gpl.html) as
published by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
```

## Notes
I'm developing this app in my free time, so I appreciate feedback and welcome PRs!

(_Box, Box!_ is unofficial software and in no way associated with the Formula 1 group of companies.)
