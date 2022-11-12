
<!-- <button class="btn-toggle">Toggle Dark Mode</button> -->
<!-- # **Your first Hotline Miami mod** -->
# **Getting Started**
<!-- This tutorial teaches the core concepts of Hotline Miami modding and how to setup the Editor. -->

<!-- ---


## *Get your tools!*
If you're new to this install the wad [Explorer](https://github.com/muster128/HLMWadExplorer/releases/tag/1.2) and later the [Editor](#the-editor). They are the core utilites that let you mod Hotline Miami.


--- -->

---

## Core Concepts
Before we jump in to Editor and start breaking shit there are some key concepts and some important files we'll at least need to know exist.

### Game Resources
Hotline Miami modding begins with the games base .WAD Archive named `hlm2_data_desktop.wad`. It is located next to the .exe in the games installed directory (or in the Resources folder in the applications package contents on macos). It holds every texture, shader, sound, font, sprite, tile, level, object, and dialogue line in the game.

The only way we can see whats in this .WAD Archive is with the Explorer or Editor. Mods are just another .WAD Archive that only contain modified game files retrieved from the base wad.

Within this base wad you have a bunch of folders a few key ones are:

* The `Atlases/` folder has all of the games sprite graphics. In here are `.png` texture pages with a `.meta` sprite atlas file of the same name. A `.meta` file is like the cookie cutter for every sprite on the texture page.

* The `Fonts/` folder has the fonts used throughout the game. Just like the Atlases/ folder you have a `.png` character page followed by an `.fnt` (xml formatted) character atlas.

* The `Sounds/` folder has every sound in the game. Sounds must be preserve their original format.

!!! note "Wheres the music?"
    For music, switch to the `hlm2_music_desktop.wad` file located next to the base wad.



<!-- Hotline Miami modding begins with the base `hlm2_data_desktop.wad`. This `.wad` file is an uncompressed file archive storing all of Hotline Miami's resources. It holds every texture, shader, sound, font, sprite, tile, level, object, and dialogue line in the game! This is the file that the [Explorer](https://github.com/muster128/HLMWadExplorer/releases/tag/1.2) and Editor should reference when making modifications. -->


### Mods
All Hotline Miami mods are saved as `.patchwad` files. Fun fact, Patchwads are literally just a WAD Archives with the word "patch" thrown in the file extension. The key difference is, instead of storing all of the games resources it only contains the modified duplicates of the originals, a patch wad. There are also two categories which all mods fall under

*   #### *Global mods*
    Global mods let you change pretty much anything about the game. They are applied on the initial loading screen before the game boots to the logo screens and the game actually starts.

    > Global mods will be placed and located in your users `Documents/My Games/HotlineMiami2/Mods` folder.

<!-- breaker to fix the broken -->

*   #### *Level mods*
    Level mods are a bit more restricted in their scope but the most stable kind of mod. Level mods only let you do one thing: change texture pages. Its incredibly bare bones especially when you consider the fact that for some reason you can't change the weapons in a level mod. This degree of restriction is probably placed because mods can be packaged with custom levels and put on the workshop.

    > Level mods will be in a `mods/` folder in your levels directory. If its not there create one!
    >
    > Local levels are in your users `Documents/My Games/HotlineMiami2/Levels` folder.

    <!-- > If you've downloaded a level from the Steam Workshop you might be able to find a patchwad in a special little folder called `mods` in said levels workshop content folder. -->



---


## Setting up


To make mods, we'll first need our tools. This wiki uses the [Editor](https://github.com/DohKnot/HLMWadEditor/releases) as its main utility for modding. It is also recommended to download the [Explorer](https://github.com/muster128/HLMWadExplorer/releases/tag/1.2) as it is extremely lightweight, good for quickly checking mods when needed, and light mode.

> For [Editor Downloads](https://github.com/DohKnot/HLMWadEditor/releases) the Github's releases page has up to date versions.

> For [Explorer Downloads](https://github.com/muster128/HLMWadExplorer/releases/tag/1.2) muster128 has made a patched version with a handful of QoL improvements.


<!-- !!! note "Mod Compatability"
    Mods made with the HLMWadEditor will not be compatable with any other mod and will cause many unintended side effects -->


### First Time Configuration
After you've downloaded and launched the Editor for the first time you'll be welcomed with a pretty blank winwdow with no resources popping up. Like the Explorer, the Editor needs a base wad to reference. Just like the Explorer, its under `File/Switch base wad` and locate your base wad. We only have to do this once.


<img max-width="600px" src="/Tutorials/0/editor_switch_wad.png" alt="switch base wad with file->switch base wad" title="how to swich the base wad">

Your looking for the `hlm2_data_desktop.wad` file in the games installed directory. Common places are:

On Windows `C:/Program Files(x86)/Steam/steamapps/common/HotlineMiami2/`

On macOS `Applications/Hotline Miami 2 Wrong Number.app/Contents/Resources/` in your apps package contents. You will need to copy and paste the base wad file to a directory outside the app contents.

<img max-width="600px" src="/Tutorials/0/editor_find_base_wad_better.png" alt="find hlm2_data_desktop" title="the base wad">

---

## Next Step

Alright after you've downloaded and configured the Editor your ready for formal [Introduction to the Editor](/Tutorials/1/) which will step you through the main components of the Editor.

If you're hungry to jump into modding and don't need to familiarize yourself, [Your first Mod](/Tutorials/2/) will step you through the process of making a mod.

---
