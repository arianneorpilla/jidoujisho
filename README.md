<p align="center">
  <img src="https://github.com/lrorpilla/jidoujisho/blob/main/assets/icon/icon.png" alt="jidoujisho logo by aaron marbella" width="120" height="120">
</p>


<h3 align="center">jidoujisho</h3>
<p align="center">A mobile video player tailored for Japanese language learners.</p>

<p align="center"><b>Latest Beta: <a href="https://github.com/lrorpilla/jidoujisho/releases/">0.4.2</a></p></b><br>

# 📚 Uninterrupted language immersion at your fingertips

**jidoujisho** is an Android video player with features specifically helpful for language learners. 

- [x] Text selection of subtitles allows for **quick dictionary lookups within the application**
- [x] **Search current clipboard and open browser** to Jisho.org, DeepL or Google Translate
- [x] **Export cards to AnkiDroid**, complete with a snapshot and audio of the current context
- [x] Selecting a word allows export to AnkiDroid with the **sentence, answer, meaning and reading**
- [x] **Repeat the current subtitle from the beginning** by flicking horizontally
- [x] Swipe vertically to open the **transcript to jump to time and review subtitles**
- [x] **(Experimental)** YouTube support for videos with Japanese user-generated subtitles
- [x] **(Experimental)** Custom Japanese-Japanese dictionary support **(tested for Shinmeikai)**

# 🛠️ More features are on the way

**jidoujisho is still in active development.** The app will be available publicly to download in GitHub at an early stage, and will be free to download on the Google Play Store. Current features planned on the roadmap listed below, but as of now there is no estimate on any updates.

- [ ] **Further web support** and fixes for experimental YouTube and auto-generated subtitles
- [ ] **Use of the AnkiDroid API** instead of share intent to streamline card export
- [ ] **User interface, layout, video playback preferences** and Anki output customisation
- [ ] Multiple subtitle tracks at a given time, and **immersion difficulty levels** for oral practice
- [ ] **Morphological analysis of subtitles** for better text selection and **offline dictionary use**
- [ ] **Support for more languages,** and more easier ways for contributors to extend language support
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

jidoujisho will take **video and audio formats as supported by ExoPlayer**. Subtitles may be embedded within the video being played and selected during playback. 

If you wish to use external subtitles, they may be in **.SRT format** and you may import them during playback through the menu. You may switch between different audio and subtitle tracks. Image-based subtitles such as PGS are not currently supported.

Web support for YouTube is **currently experimental**. YouTube subtitles are taken from TimedText XML, which is only publicly exposed to videos that have user-generated Japanese subtitles. Unfortunately, some particular videos cannot be streamed. Regardless, <a href="https://www.youtube.com/watch?v=mZ0sJQC8qkE">the app appears to be functional</a> <a href="https://www.youtube.com/watch?v=X9zw0QF12Kc">and has been tested with a fair sample</a> <a href="https://www.youtube.com/watch?v=t1yXDcuwzpY">of practical application use cases.</a>

### ☝️ Important Notes

Below are some guides that some users might find useful.

* <b><a href="https://github.com/lrorpilla/jidoujisho/releases/tag/0.3.2-beta">Using the app on Android 11</a></b>
* <b><a href="https://github.com/lrorpilla/jidoujisho/releases/tag/0.4-beta">Using a custom dictionary</a></b>

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

jidoujisho is written in <b><a href="https://dart.dev/">Dart</a></b> and powered by <b><a href="https://flutter.dev/">Flutter</a></b>. At present, the project may still need to be refactored and cleaned up as well as setting up of forks for the modified imports used in the project. Regardless, the app is ready for use and feedback in these early stages is much appreciated.

If you like what I've done so far, you can help me out by testing the application on various so that I can gauge the compatibility of the application with different versions of Android, <b><a href="https://www.buymeacoffee.com/lrorpilla">making a donation</a></b> or collaborating with me on further improvements.

The logo of the application is by <b><a href="https://www.buymeacoffee.com/marblesaa">Aaron Marbella</a></b>, support his awesome work if you can!

