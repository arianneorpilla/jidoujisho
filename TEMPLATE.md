# jidoujisho Anki Template

This page documents the HTML and CSS used in the Anki templates for any users that might already have an existing template and wish to update. **There are three templates**, one used for video playback, one for using the card creator from inside the app, and one for reading when sharing to the app.\

* **jidoujisho Anki cards have six fields in order:** Image, Audio, Sentence, Word, Meaning, Reading
* You may edit the template on AnkiDroid by **editing any jidoujisho exported card**
* **Select the card type** `jidoujisho Default` or `jidoujisho (Creator) Default` or `jidoujisho (Reader) Default` at the bottom of the AnkiDroid editor
* This will take you to the template editor where you can **replace the text from the ones below**

<p align="center" style="margin:0">
<img src="https://i.postimg.cc/pT655HZW/1.jpg" height="400"/>
<img src="https://i.postimg.cc/5yQYwR7w/2.jpg" height="400"/>
<img src="https://i.postimg.cc/gr9w4HQ1/3.jpg" height="400"/>
</p>

# CSS Template
The CSS template is the same for the player, creator and reader templates, except that the Creator default maximum height is higher, as it is intended to be used out-of-the-box for cards with the image in the front, for manga readers or quick vocabulary cards.

* The **player and reader** template maximum image height is `250px` by default.
* The **creator template** maximum image height is `400px`  by default.

```css
p {
    margin: 0px
}

h2 {
    margin: 0px
}

small {
    margin: 0px
}

.card {
  font-family: arial;
  font-size: 20px;
  white-space: pre-line;
  text-align: center;
  color: black;
  background-color: white;
}

#sentence {
    font-size: 30px
}

.image img {
  position: static;
  height: auto;
  width: auto;
  max-height: 250px;
}
.pitch{
  border-top: solid red 1px;
  padding-top: 1px;
}

.pitch_end{
  border-color: red;
  border-right: solid red 1px;
  border-top: solid red 1px;  
  line-height: 1px;
  margin-right: 1px;
  padding-right: 1px;
  padding-top:1px;
}
```

# Video playback template
* `jidoujisho Default`, used when watching a video
* **Intended for video immersion sentence mining**: sentence and word in the front, audio, image, reading, word, meaning and sentence in the back.

### Front Template
```html
<p id="sentence">{{Sentence}}</p><div id="word">{{Word}}</div>
```

### Back Template
```html
<p id="sentence">{{Sentence}}</p><div id="word">{{Word}}</div><br>{{Audio}}<div class="image">{{Image}}</div><hr id=reading><p id="reading">{{Reading}}</p><h2 id="word">{{Word}}</h2><br><p><small id="meaning">{{Meaning}}</small></p>
```

<br>

# Creator template
* `jidoujisho (Creator) Default`, used for the card creator
* **Intended for manga readers and casual word encounters**: image and word in the front, audio, reading, word, meaning and sentence in the back.

### Front Template
```html
{{Audio}}<div class="image">{{Image}}</div><br><p id="sentence">{{Sentence}}</p>{{Word}}
```

### Back Template
```html
{{Audio}}<div class="image">{{Image}}</div><br><p id="sentence">{{Sentence}}</p>{{Word}}<hr id=reading><p id="reading">{{Reading}}</p><h2 id="word">{{Word}}</h2><br><p><small id="meaning">{{Meaning}}</small></p>
```

<br>

# Reader template
* `jidoujisho (Reader) Default`, used when sharing text to the app
* **Intended for novel readers and general reading, i.e. in a web browser or reader application**: sentence and word in the front, audio, image, reading, word, meaning and sentence in the back.
* Identical to the video playback template, but separate to allow flexibility for user customisation

### Front Template
```html
<p id="sentence">{{Sentence}}</p><div id="word">{{Word}}</div>
```

### Back Template
```html
<p id="sentence">{{Sentence}}</p><div id="word">{{Word}}</div><br>{{Audio}}<div class="image">{{Image}}</div><hr id=reading><p id="reading">{{Reading}}</p><h2 id="word">{{Word}}</h2><br><p><small id="meaning">{{Meaning}}</small></p>
```
