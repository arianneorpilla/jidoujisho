# jidoujisho Anki Template

This page documents the HTML and CSS used in the Anki templates for any users that might already have an existing template and wish to update.

**The jidoujisho template has six fields in order:**
* Image
* Audio
* Sentence
* Word
* Meaning
* Reading

### Editing the template
* You may edit the template on AnkiDroid by **editing any jidoujisho exported card**
* **Select the card type `jidoujisho Default`** at the bottom of the AnkiDroid editor
* This will take you to the template editor where you can **replace the text with the ones below**

### Front Template
```html
{{Audio}}<br>{{Image}}<br><br><p id="sentence">{{Sentence}}</p>
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
```

### Back Template
```html
{{Audio}}<br>{{Image}}<br><br><p id="sentence">{{Sentence}}</p><br><hr id=reading><p id="reading">{{Reading}}</p><h2 id="word">{{Word}}</h2><br><p><small id="meaning">{{Meaning}}</small></p>
```
