# Welcome to the HLMWadEditor
*The complete guide to the HLMWadEditor*



## Quick Links

* [`Tutorials`](TutorialsList.md) - A list of tutorials that show how to achieve some basic effects.
* [`User Interface`](UserInterface.md) - An index defining the programs UI elements.
* `mkdocs build` - Build the documentation site.
* `mkdocs -h` - Print help message and exit.


### About

In 2016, shortly after the level editor was released, the Hotline Miami modding community was given the [HLMWadExplorer](https://github.com/muster128/HLMWadExplorer/releases/tag/1.2).

A tool that lets the user replace the games textures and sounds with their own. This opened the door for custom level creators and modders to make whatever they wanted. We could finally put John Wick in Hotline Miami. The HLMWadExplorer used in combination with custom campaigns, and some creative problem avoiding, you could create your own game.

Though there was one small catch. We couldn't resize textures or sprites. If you wanted to reskin the magnum revolver sprite, with a measily sprite size of 10 by 15 pixels, to be a huge ass-railing railgun that would definitely be bigger that 10x15, you couldn't. The HLMWadExplorer could only let you replace assets, but not deeply modify them. And for a long time, modding was essentially just replacing texture pages.

We knew the gatekeepers were a couple of binary files that contained sprite metadata. But said files were encoded in a custom format made by the developers and only readable by the game. We tried to reach out, but to no response. And so we were left with nothing but a hex editor to crack the files format. In mid 2021 the file format was finally cracked by yours truly and now the floodgates were unlocked. And with the release of the HLMWadEditor, the floodgates are open.

## Introduction
The HLMWadEditor tries to mimmick the layout of the [HLMWadExplorer](https://github.com/muster128/HLMWadExplorer/releases/tag/1.2) but with an awesome user interface that will make your laptop fans cream.
Go to the section on the [User Interface](UserInterface.md) to get a breakdown of what each button, window, and panel does.