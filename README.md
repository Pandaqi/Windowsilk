# Windowsilk
A local multiplayer game for 1-6 players about running across a spider web, eating tasty bugs for points and powerups, while avoiding the many predators and other dangers.

Project for the Game Off 2021 Jam, hosted by GitHub.

## Which engine does it use?
The game is made using the Godot game engine. I've used it for years now, even wrote chapters for a huge book on Godot when v3 was just released, and will probably stick with it for a long time. It's small, it's fast, it's fun to use, give it a try.

Other assets were made using Affinity Designer (might also open in Adobe Illustrator), Studio one, and some open source software here and there (such as Audacity)

## How is the project structured?
Each project, I try new programming paradigms in hope of refining my project structure. This time, I went all-in on the concept of "modules".

Everything in the game consists of a root node (with a simple "module register" script) and all children being modules (with their own script and perhaps child nodes).

Each module does _one thing_ and _one thing only_. (At least, that's the idea.)

To communicate between modules, they are either directly referenced (``body.m.modulename.do_something()``) or I use a signal that I connected in the editor.

To be honest, I should've picked one approach and stuck to it, but that's a lesson for future projects.

The most important scenes are:
* Main => the actual game, with a few (big) modules to run it all
* Entity => I simplified the game by making _everything_ an entity (both players and bugs; bugs also function as powerups)
* Point/Edge => these are used for creating the spider web

Because I decided to implement lots of weird stuff (such as changing the web on the fly, timebomb edges, etcetera) those Point/Edge scenes have way more functionality and complexity than you'd expect. (And probably some unsolved bugs to go along with that ...)

## Which parts are actually good?
As always with game jams, there are quite some parts of the project with ugly code, bad structure, inefficient workflow, etcetera.

Nevertheless, these things are probably _good_ examples on how to do stuff:
* The general concept of the modules. It means that every script is really tiny and is responsible for exactly one thing, making it much much easier to program (without adding bugs). It also allows re-use everywhere.
* Splitting a web-like structure into points and edges, each of which work independently but reference each other if needed. (For example, if I _move_ a point, it informs all its edges that it should update and reposition the entities on them to fit the new edge.)
* Using Timers for many things (instead of doing things instantly, or updating a variable each frame)
* Using a globally accessible configuration object which allows me to turn on/off _any rule_ in the game. (Whenever I think "hmm, wouldn't it be better if it worked like X?", I just implement it, but add an easy toggle in the global configuration. That way, if it ends up being a terrible idea, I just toggle it off and move on.)
* The way I keep notes (and a devlog) during a project, building a good "game design doc" as we go (instead of planning it beforehand).
* The procedural animation on the legs and antennae of the bugs. It looks better than if I'd done it by hand, can respond to any movement/environment, and is relatively easy to code.
* Putting as many sprites as possible into neatly ordered spritesheets. It means the final assets for the game are only a few (large) textures re-used everywhere, which is great for simplicity and performance.

Many "bad" parts of the project are simply a result of "figuring out the game as we go". In a normal project, if I had more time, I'd take one day a week to clean up the old mess and restructure things. 

(Yes, this takes time. But the alternative is that I need to know exactly how the game should work before I write any code, and that I need to be 100% _right_ about that. Which won't happen. So write bad code first, learn from it, improve it later.) 

## What will happen to this project?
Your best ideas are never the first ones. Only after developing the game for a month, was I able to get _actually_ creative, unique, fitting ideas for this game. That's just how it works with creative stuff: experiment until you stumble upon what works.

As such, these are some things that could improve the game further:
* More unique trails/powerups that have to do with the main mechanic of the game: moving/jumping across a web _and_ the idea of "eat or be eaten". Right now, jumping is just a straight line. Bugs are just what they are - their points never change - and I was only able to implement a few special move patterns.
* Some more modes and arenas to complement the defaults.
* Actually give insects the legs they have (now there are just a few default legs everyone uses) + animate the legs during flight.
* Optimization improvements. Splitting everything into modules/nodes has the downside that even a simple game like this has _thousands_ of nodes active at the same time. Many of those nodes could be simplified to the most basic version ("Node") or optimized some other way.

Besides that, I'm thinking of turning this idea into a puzzle game as well. (With "this idea" being "solve puzzles on a spider web by creating new strands or destroying old ones".) If I make it a bit more abstract/simplified and constrain it to a grid, I think that'd be wonderful. 

(If you read this and think: "yes, great idea, I'm going to make that puzzle game!" That's fine by me, just let me know and maybe we can collaborate.)


## What can I use?
In the spirit of these game jams, I make absolutely everything available and freely accessible. 

I sincerely hope some part of this project (code, sprites, concept, devlog notes) inspires you or helps you solve problems in your own project.

That being said, please don't blatantly copy anything. Even if you copy something invisible (such as code), it's still best to go through it yourself and make sure you understand it, otherwise you'll learn nothing and have a project filled with code you do not understand. 


