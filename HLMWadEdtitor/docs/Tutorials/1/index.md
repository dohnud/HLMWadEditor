# Introduction to the Editor

---

The Editor is an all in one modding tool. It lets you change any sprite, tile, or font in the game to be any size or shape you want. For advanced users, you can even inspect and change lower level resources like game objects, and game levels.


<img max-width="600px" src="/Tutorials/1/editor_empty.png" alt="find hlm2_data_desktop">


---

## Interface breakdown

### Asset List

On the left side of the window you have an Asset List, neatly listing all viewable game resources. Selecting an asset will change the editors viewing panel to display the files contents.

<img max-width="600px" src="/Tutorials/1/spotlight_assetlist.png" alt="find hlm2_data_desktop">


### Menu bar

At the top of the window is the menu bar. Almost everything is done through the menu bar. The menu bar holds every operation and other options organized into distinct categories. Some operations from the menu bar also have keyboard shortcuts so you don't have to waste time clicking everything.

<img max-width="600px" src="/Tutorials/1/spotlight_menubar.png" alt="find hlm2_data_desktop">

#### Menu bar Categories
By default the Editors menu bar has 3 categories. File, Resource, and View, are always there but depending on what file you're viewing you might see more which we will cover in the next paragraph.

<div class="fartbox">
<div><img style="max-width: 400px;" src="/Tutorials/1/menubar_file.png"></div><div>
<table>
<tr><td><code>Open Patch</code> </td><td>Open a mod.</td></tr>
<tr><td><code>Save Patch</code> </td><td>Save the current opened mod to your computer</td></tr>
<tr><td><code>Save Patch as</code> </td><td>Save the current opened mod to your computer</td></tr>
<tr><td><code>Recent Patches</code></td><td>Lists recently opened patches to be opened.</td></tr>
<tr><td><code>Import from Patch</code></td><td>Not implemented yet.</td></tr>
<tr><td><code>Switch Base WAD</code></td><td>Switch the applications base reference wad.</td></tr>
<tr><td><code>Quit</code></td><td>quits the application, does not save or prompt to save... I should probably fix that.</td></tr>
</table>
</div>
</div>


<div class="fartbox">
<div><img style="max-width: 400px;" src="/Tutorials/1/menubar_resource.png"></div><div>
<table>
<tr><td><code>Extract</code> </td><td>Save the current selected asset to your computer.</td></tr>
<tr><td><code>Revert</code> </td><td>Revert the current selected asset to its original version. AKA Delete modifications from the current asset</td></tr>
</table>
</div>
</div>


<div class="fartbox">
<div><img style="max-width: 400px;" src="/Tutorials/1/menubar_view.png"></div><div>
<table>
<tr><td><code>Expand Asset List</code> </td><td>Expands every folder in the Asset List, displaying every single file.</td></tr>
<tr><td><code>Show Only Modifed Files</code> </td><td>Limits the Asset List to only show modified assets</td></tr>
<tr><td><code>Advanced</code> </td><td>Toggles the Asset List to also display other types of game metadata.</td></tr>
<tr><td><code>Toggle Asset List</code> </td><td>Hides and shows the asset list from the interface.</td></tr>
</table>
</div>
</div>



### Viewing Panel

Taking up the body of the window is the viewing panel. The viewing panel visually displays assets and previews your changes.

<img max-width="600px" src="/Tutorials/1/spotlight_viewingpanel.png" alt="find hlm2_data_desktop">


On the simplest level, the Editor is just a fancy file viewer. And viewing each file will switch the Editor's viewing mode to view each files contents. There are 4 modes of viewing available:


## Meta View
Where most of the sprite trickery happens. In this view we are modifying 2 files primarily, the current .meta file and its texture page file. They are two seperate files but require each other 

Meta view previews all the sprites the current .meta file contains along with a timeline and playback controls. Toggle play/pause with `Spacebar`.

<img max-width="600px" src="/Tutorials/1/meta_view.png" alt="find hlm2_data_desktop" title="the base wad">

### Meta View Submenus
In meta view, the menu bar at the top of the window is given two addition sub menus:

<h4>Texture page operations.</h4>

<div class="fartbox">
<div><img style="max-width: 400px;" src="/Tutorials/1/texture_menu_button.png"></div><div>
<table>
<tr><td><code>Import Texture Page</code> </td><td>Replace the current .meta's texture page with a .png image</td></tr>
<tr><td><code>Export Texture Page</code> </td><td>Save the current .meta's texture page to a .png image</td></tr>
<tr><td><code>Recompile Texture Page</code> </td><td>Recompile your .meta's texture page to reflect your newest changes and update the collision for each sprite.</td></tr>
</table>
</div>
</div>

<h4>Sprite operations</h4>

<div class="fartbox">
<div><img style="max-width: 400px;" src="/Tutorials/1/meta_menu_button.png"></div><div>
<!-- The more popular of the two. -->
<table>
<tr><td><code>Import Sprite from Strip</code> </td><td>Replace the current sprite from a .png sprite strip file</td></tr>
<tr><td><code>Export Sprite to Strip</code> </td><td>Save the current sprite to a .png sprite strip file</td></tr>
<tr><td><code>Export Sprite to GIF</code> </td><td>Save the current sprite to a animated .gif</td></tr>
<tr><td><code>Export All Sprites</code> </td><td> Save every sprite in the current .meta file to automatically named .png sprite strip files</td></tr>
<tr><td><code>Transform Sprite</code> </td><td> Modify the current sprites frame dimensions and frame count</td></tr>
<tr><td><code>Toggle Gizmos</code> </td><td> Toggles displaying frame info on the sprite preview</td></tr>
</table>
</div>
</div>

---

## Font View
Font view lets you preview fonts, pretty simple. Theres a text box at the top so you can demo how it'd look in game. At the time of writing it is not as feature full as the Meta view but that is planned to change.
<img max-width="600px" src="/Tutorials/1/font_view.png" alt="find hlm2_data_desktop" title="the base wad">

### Font View Submenus

<h4>Font texture page operations.</h4>
<div class="fartbox">
<div><img style="max-width: 400px;" src="/Tutorials/1/texture_menu_button.png"></div><div>
<table>
<tr><td><code>Import Texture Page</code></td><td>Replace the current font's associated texture page with a .png image</td></tr>
<tr><td><code>Export Texture Page</code></td><td>Save the current font's associated texture page to a .png image</td></tr>
<tr><td><code>Recompile Texture Page</code></td><td>Recompile your fonts texture page to reflect your newest changes.</td></tr>
</table>
</div>
</div>

---

## Sound View
Sound view lets you preview sounds. At the moment of writing you can only preview .wav files and you cannot actually change them. For sound mods check out to the [Music Mods](/Other/music-mods.md) section which will use the Explorer as that is all that is needed to make music mods.

<img max-width="600px" src="/Tutorials/1/sound_view.png" alt="find hlm2_data_desktop" title="the base wad">

---

## Tree View
This is mostly involved with having Advanced files enabled. When you select an asset that doesn't have an associated viewer Tree view is used displaying the assets raw structure

<img max-width="600px" src="/Tutorials/1/tree_view.png" alt="find hlm2_data_desktop" title="the base wad">

> The demo screenshot is showcasing a game objects data displaying its sprite, parent game object, and its collision sprite amongst other variables.

---


## Next Step

Feeling comfortable? No? Now is probably time for [Your first Mod](/Tutorials/2/).

---
