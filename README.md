<p align="center">
  <img src="https://github.com/lrorpilla/jidoujisho/blob/main/assets/icon/icon.png" alt="jidoujisho logo by aaron marbella" width="120" height="120">
</p>


<h3 align="center">jidoujisho</h3>
<p align="center">A mobile video player tailored for Japanese language learners.</p>

<p align="center" style="margin:0"><b>Latest GitHub Release:<br>
<a href="https://github.com/lrorpilla/jidoujisho/releases/tag/0.6.0-beta">0.6.0-beta 🇯🇵 → 🇬🇧</a><br>
<a href="https://github.com/lrorpilla/jidoujisho/releases/tag/0.5.3-enjp-beta">0.5.3-beta 🇬🇧 → 🇯🇵</a></b><br></p>

# 📚 Uninterrupted language immersion at your fingertips

**jidoujisho** is an Android video player with features specifically helpful for language learners. 

- [x] Text selection of subtitles allows for **quick dictionary lookups within the application**
- [x] **Search current clipboard and open browser** to Jisho.org, DeepL or Google Translate
- [x] **Export cards to AnkiDroid**, complete with a snapshot and audio of the current context
- [x] Selecting a word allows export to AnkiDroid with the **sentence, answer, meaning and reading**
- [x] **Repeat the current subtitle from the beginning** by flicking horizontally
- [x] Swipe vertically to open the **transcript to jump to time and review subtitles**
- [x] **YouTube support** for videos with **Japanese user-generated subtitles**
- [x] **(Experimental)** Custom Japanese-Japanese dictionary support **(tested for Shinmeikai)**
- [x] **(Experimental)** Weblio.jp **English to Japanese support** and full Japanese localization


# ⚕️ Current state of the project

**jidoujisho is still in active development.** The full app is available to download here on GitHub and is ready for use. <b><a href="https://play.google.com/store/apps/details?id=com.lrorpilla.jidoujisho">A lite version of the application without YouTube features is now available on the Google Play Store</b></a>. Current features planned on the roadmap are listed below, but as of now there is no estimate on any updates.

Please note that the development of the app switches between changes being implemented and being left alone for daily use. Update frequency may depend on the gravity of any issues that arise. **Hiatuses provide practical insight on usage and where development should go next.**

### 🚅 Next Up
- [ ] User preferences and Anki output customisation, with **broader custom dictionary and language support**
- [ ] Fixes for **slow video loading due to scoped storage** are planned at some point

### 🛣️ Coming Soon
- [ ] **Morphological analysis of subtitles** for better text selection and **offline dictionary use**
- [ ] **Use of the AnkiDroid API** instead of share intent to streamline card export
- [ ] Multiple subtitle tracks at a given time, and **immersion difficulty levels** for oral practice
- [ ] Tinker around with releasing the app on **other platforms if possible**

# 🎞️ A glimpse of jidoujisho in action

<p align="center">
  <img src="https://i.postimg.cc/QxB6z8BD/Screenshot-20210201-071958.jpg" width="223"/>
  <img src="https://i.postimg.cc/zX1sTHtM/Screenshot-20210204-065320.jpg" width="223"/>
  <img src="https://i.postimg.cc/kMTZZYfQ/Screenshot-20210201-072859.jpg" width="223"/>
</p>
<p align="center">
  <img src="https://i.postimg.cc/T2Swx0Pb/Screenshot-20210204-081519.jpg" height="350"/>
  <img src="https://i.postimg.cc/PqtfyFSg/Screenshot-20210204-081552.jpg" height="350"/>
  <img src="https://i.postimg.cc/DZy6PnVt/Screenshot-20210204-065707.jpg" height="350"/>
  <img src="https://i.postimg.cc/d09nCDf2/Screenshot-20210204-065728.jpg" height="350"/>
</p>
<p align="center">
  <img src="https://i.postimg.cc/Y0vxTRCR/Screenshot-20210204-070159.jpg" width="223"/>
  <img src="https://i.postimg.cc/Y0Tx7F4H/Screenshot-20210204-070337.jpg" width="223"/>
  <img src="https://i.postimg.cc/8PqyQ2W6/Screenshot-20210201-232317.jpg" width="223"/>
</p>

# 📖 Using the application

### 🚨 Supported Formats

jidoujisho will take **video and audio formats as supported by VLC**. Subtitles may be embedded within the video being played and selected during playback. 

If you wish to use external subtitles, they may be in **SRT, ASS or SSA format** and you may import them during playback through the menu. You may switch between different audio and subtitle tracks. Image-based subtitles such as PGS are not currently supported.

YouTube subtitles are taken from TimedText XML, which is only publicly exposed to videos that have user-generated Japanese subtitles. <a href="https://www.youtube.com/watch?v=mZ0sJQC8qkE">Here are a fair sample of</a> <a href="https://www.youtube.com/watch?v=X9zw0QF12Kc">YouTube videos with such subtitles</a> <a href="https://www.youtube.com/watch?v=t1yXDcuwzpY">showcasing some very practical application use cases.</a>

### ☝️ Important Links

Below are some links that some users might find useful.

* <b><a href="https://github.com/lrorpilla/jidoujisho/releases/tag/0.3.2-beta">Using the app on Android 11</a></b>
* <b><a href="https://github.com/lrorpilla/jidoujisho/releases/tag/0.4-beta">Using a custom dictionary</a></b>
* <b><a href="https://reddit.com/r/LearnJapanese/comments/lcf9wi/jidoujisho_a_mobile_video_player_tailored_for/">Debut Reddit discussion thread</a></b>

### 🚀 Getting Started

A primer on the basics of the application is as follows.

* 📲 <a href="https://github.com/lrorpilla/jidoujisho/releases/"/>**Download and install the latest beta**</a> onto your Android device
* ⏯️ Play a video by selecting from your **local media library or entering a YouTube URL**
* 📋 Select text by simply holding on them, and **copy them to clipboard when prompted**
* 📔 When the **dictionary definition** for the text shows up, the text is the **current context**
* 🗑️ Closing the dictionary prompt will **clear the clipboard**
* 🌐 The current context may be used to **open browser links to third-party websites**
* ↕️ You may **swipe vertically to open the transcript**, and you can pick a time or read subtitles from there
* ↔️ **Swipe horizontally** to repeat the current subtitle audio

### 📲 Exporting to AnkiDroid

* 📤 You may also export the current context to an **AnkiDroid card, including the current frame and audio**
* 🔤 Having a word in the clipboard **will include the sentence, word, meaning and reading** in the export
* 📝 **You may edit the sentence, word, meaning and reading text fields** before sharing to AnkiDroid
* 🔗 To finalise the export, **share the exported text to AnkiDroid**
* 🃏 The **front of the card** will include the **audio, video and sentence**
* 🎴 The **back of the card** will include the **reading, word and meaning**
* 📑 You may apply **text formatting to the card with the AnkiDroid editor once shared**
* ⚛️ **Extensive customisation of the Anki export is planned**

# 👥 Contribution and attribution

jidoujisho is written in <b><a href="https://dart.dev/">Dart</a></b> and powered by <b><a href="https://flutter.dev/">Flutter</a></b>. The application queries dictionary definitions from <b><a href="https://jisho.org/">Jisho.org</a></b>.

If you like what I've done so far, you can help me out by testing the application on various so that I can gauge the compatibility of the application with different versions of Android, <b><a href="https://www.buymeacoffee.com/lrorpilla">making a donation</a></b> or collaborating with me on further improvements.

The logo of the application is by <b><a href="https://www.buymeacoffee.com/marblesaa">Aaron Marbella</a></b>, support his awesome work if you can!

