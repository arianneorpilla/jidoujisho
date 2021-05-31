# jidoujisho Anki Template

This page documents the HTML and CSS used in the Anki templates for any users that might already have an existing template and wish to update.

There are two templates, one used for video playback and the other used for the card creator.

* You may edit the template on AnkiDroid by **editing any jidoujisho exported card**
* **Select the card type** `jidoujisho Default` or `jidoujisho (Creator) Default` at the bottom of the AnkiDroid editor
* This will take you to the template editor where you can **replace the text from the ones below**

**jidoujisho Anki cards have six fields in order:**
* Image
* Audio
* Sentence
* Word
* Meaning
* Reading

<br>

# Video playback template
* `jidoujisho Default`, used when watching a video
* **Intended for video immersion sentence mining**: audio, image and sentence in the front, back has reading, word and meaning
* Recommended change for pro users, removing video and audio context from front and putting them at the back

### Front Template
```html
<p id="sentence">{{Sentence}}</p>
```

### CSS Template
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

### Back Template
```html
<p id="sentence">{{Sentence}}</p><br>{{Audio}}<br>{{Image}}<br><br><hr id=reading><p id="reading">{{Reading}}</p><h2 id="word">{{Word}}</h2><br><p><small id="meaning">{{Meaning}}</small></p>
```

<br>

# Creator template
* `jidoujisho (Creator) Default`, used for the card creator
* **Intended for manga readers and casual word encounters**: image and word in the front, audio, reading, word, meaning and sentence in the back.

### Front Template
```html
{{Audio}}<div class=\"image\">{{Image}}</div><br><p id="sentence">{{Sentence}}</p>
```

### CSS Template
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
    max-height: 300px;
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

### Back Template
```html
{{Audio}}<div class=\"image\">{{Image}}</div><br><p id="sentence">{{Sentence}}</p><br><hr id=reading><p id="reading">{{Reading}}</p><h2 id="word">{{Word}}</h2><br><p><small id="meaning">{{Meaning}}</small></p>
```
