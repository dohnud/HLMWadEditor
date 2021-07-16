# **Your first Hotline Miami mod**

This tutorial teaches the core concepts of Hotline Miami modding and how to setup the Editor.

---


## *Get your tools!*
If you're new to this install the wad [Explorer](https://github.com/muster128/HLMWadExplorer/releases/tag/1.2) and later the [Editor](#the-editor). They are the core utilites that let you mod Hotline Miami.

Shoutouts to muster128 for the patched version that kickstarted the Editor project.

> <img  width="70%" height="70%" src="/Tutorials/switchbasess.png" alt="switch base wad with file->switch base wad" title="how to swich the base wad">

> If nothing comes up when you launch, switch the base wad to the `hlm2_data_desktop.wad` file in the games installed directory


---

## **Core Concepts**
This section goes over the types of game files we are free to manipulate.

### Game Resources
When you view the base wad file archive's (the `hlm2_data_desktop.wad` file located in the games installed directory) contents you will see a few different kinds of data a few key ones are:

* The **Atlases/** folder has all of the games sprite graphics. In here are `.png` texture pages with a `.meta` sprite atlas file of the same name. The `.meta` files are just a big cookie cutter for the sprites on the texture page.

* The **Fonts/** folder has the fonts used throughout the game. Just like the Atlases/ folder you have a `.png` character page followed by an `.fnt` (xml formatted) atlas.

* The **Sounds/** folder has every sound in the game. Sounds must be in a `.wav` format.

!!! Music
    For level music, switch to the `hlm2_music_desktop.wad` file located  next to the base wad.

Hotline Miami modding begins with the base `hlm2_data_desktop.wad`. This `.wad` file is an uncompressed file archive storing all of Hotline Miami's resources. It holds every texture, shader, sound, font, sprite, tile, level, object, and dialogue line in the game! This is the file that the [Explorer](https://github.com/muster128/HLMWadExplorer/releases/tag/1.2) and Editor should reference when making modifications.


### Mods
All Hotline Miami mods are saved as `.patchwad` files. Fun fact, Patchwads are literally just a WAD Archives with the word "patch" thrown in the file extension. The key difference is that instead of storing all of the games assets it only contains the modified duplicates of the originals, a patch. 


Most mods need to be loaded at game launch and will need to be placed and located in your users `Documents/My Games/HotlineMiami2/Mods` folder.


If you've downloaded a level from the Steam Workshop you might be able to find a patchwad in a special little folder called `mods` in said levels workshop content folder.


---


## The Editor

> For [Downloads](https://github.com/DohKnot/HLMWadEditor/releases) the Github's releases page has up to date versions.

The Editor is like if the Explorer did cocaine and got dark mode. It borrows a lot of concepts and design from the Exlporer, so modders of old can take advantage of the familiarity, but does so much more. It allows you achieve what was previously thought impossible.

!!! note "Mod Compatability"
    Mods made with the HLMWadEditor will not be compatable with any other mod and will cause many unintended side effects


### Initial Setup
Like the Explorer, the Editor nees a base wad to reference. To do so is the same as the Editor, `File/Switch base wad` and locate your base wad.

###