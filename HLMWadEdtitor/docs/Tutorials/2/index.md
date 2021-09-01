# Your First Mod

---

Ok so you've downloaded the Editor, set it up, and you *still* want to make a mod.
Fantastic, this is what we'll be making as your first mod:

<div class="fartbox">
<span>
<img src="/Tutorials/2/showoff0.png" alt="we will enlarge the base games magnum sprite">
</span>
<span>
<img src="/Tutorials/2/showoff1.png" alt="we will enlarge the base games magnum sprite">
You can pick it up :O
</span>
<span>
<img src="/Tutorials/2/showoff2.png" alt="we will enlarge the base games magnum sprite">
And you can shoot it :o
</span>
</div>

For our first mod we will be making a revolver with a comically large barrel. To boil our mod into the resources we'll actually be modifying: the dropped magnum sprite, the Son's magnum walking sprite, and the Son's magnum attack sprite. Although we're only changing three sprites, this tutorial will teach you the fundamentals and the correct process to make a hotline miami 2 mod.

Each sprite will have its own article. This article will change the magnum weapon itself. The next two articles will cover changing the [walking animation](/Tutorials/3/), and the [attack animation](/Tutorials/4/).

To summarize, this tutorial will answer how to use the editor and how to work with sprite strips. The core two pillars of indie gamedev.

---

<!-- ## Step #1 -->

## Changing a Weapon

Our first step in making our bigger magnum mod is to make the magnum bigger... Okay our first step in crafting our marvelous modification is to resprite our existing dropped magnum sprite, called `sprMagnum` in the `Atlases/Weapons.meta` file, to have a longer barrel and therefore be bigger than the original sprite requiring additional space.


<div class="fartbox">
<span>
<img src="/Tutorials/2/magnum_preview_normal.png" alt="a normal sized magnum sprite">
</span>
<span>
<img src="/Tutorials/2/magnum_preview_long.png" alt="a magnum with a longer barrel">
</span>
</div>

Editing this sprite will be pretty straight forward since this sprite is only one frame.

## Exporting a sprite

To edit our Magnum we will want to use our sprite editor of choice. Whether thats Photoshop, Gimp, or Aseprite is up to you (I recommend Aseprite since it has a bunch of features tailored for sprite animation). We need to get this preview image onto our hard drive so we can start respriting. To do so we are going to Export our sprite by going to our menu bar at the top of the window, under `Meta`, and clicking the `Export Sprite to Strip` option (`Shift + E` is its keyboard shortcut).

<img src="/Tutorials/2/magnum_export_start.png" alt="go to Meta -> Export Sprite to Strip">

A pop up window will appear prompting us to save our sprite to a location on our computer. Make sure you remember where you save your sprite as we will be opening this file in an your image editor of choice to do the actual respriting. 

<img src="/Tutorials/2/magnum_export_window.png" alt="Choose a location and save your sprite strip">


## Editing a sprite

Heres where the Editors use falls off. Open the exported magnum sprite with your program of choice, for these tutorials I will use Aseprite although GIMP or any other image editor also works.

<img src="/Tutorials/2/open_spritestrip.png" alt="open your sprite">

Since this isn't a tutorial on how to use Aseprite nor how to be creative nor how use your brain, I'll simply show the before and after of respriting our magnum.

<img src="/Tutorials/2/aseprite_0.png" alt="Before">
<img src="/Tutorials/2/aseprite_1.png" alt="After">

Now that we've made our changes to the magnum sprite and saved it to our computer we need hop back to the Editor and add our resprited magnum to our mod.


## Importing a sprite

Back in the editor with `sprMagnum` selected, just as we exported our sprite, in the menu bar at the top of the window under `Meta` click `Import Sprite from Strip` to import our newly modified sprite (`Shift + I` is its keyboard shortcut).


<img src="/Tutorials/2/magnum_import_start.png" alt="go to Meta -> Export Sprite to Strip">

From this file dialog we will traverse to where we saved our modified magnum sprite and open it.

<img src="/Tutorials/2/magnum_import_end.png" alt="Choose a location and save your sprite strip">

Since the Editor can import sprites strips containing multiple frames of an animation we can change how many frames to split the sprite strip into. For this case we are only modifying a single sprite so we'll leave it at one. To apply our import click `Import` at the bottom of the popup window.

<img src="/Tutorials/2/magnum_import_dialog.png" alt="Choose a location and save your sprite strip">

> #### Compiling Texture pages

> This is the more boring part of the modding process. Since every sprite is packed tightly together into a single texture page image changing the size of a sprite without moving the rest of the sprites would have sprites overlapping each other, not good. Therefore, every time we increase the size of a sprite the texture page needs to be repacked. Unfortunately, most computers need way more than 16ms (duration of a frame, 1/60th of a second) in order to recalculate and pack all the sprites back into the texture page. To solve this, and quickly, the Editor compiles texture pages in the background. We can see what textures the Editor is working on the top right of the window as a little popup.

> <img src="/Tutorials/2/magnum_import_compile.png" alt="Choose a location and save your sprite strip">

---

## Next Step

After importing our new magnum weapon sprite we still need to mod our players walking and attacking animations to match the new weapon. The [next article](/Tutorials/3/) will go over changing the players walking animation to fit our bigger weapon.

---
