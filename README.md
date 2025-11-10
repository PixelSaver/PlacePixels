# Place Pixels

<a id="readme-top"></a>
<!-- PROJECT LOGO -->
<!--
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
	<img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Best-README-Template</h3>

  <p align="center">
	An awesome README template to jumpstart your projects!
	<br />
	<a href="https://github.com/othneildrew/Best-README-Template"><strong>Explore the docs »</strong></a>
	<br />
	<br />
	<a href="https://github.com/othneildrew/Best-README-Template">View Demo</a>
	&middot;
	<a href="https://github.com/othneildrew/Best-README-Template/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
	&middot;
	<a href="https://github.com/othneildrew/Best-README-Template/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>
-->


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
	<li><a href="#about-the-project">About The Project</a></li>
	<li><a href="#built-with">Built With</a></li>
	<li><a href="#play">How to play?</a></li>
	<li><a href="#roadmap">Roadmap</a></li>
	<li><a href="#license">License</a></li>
	<li><a href="#contact">Contact</a></li>
	<li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

### Overall
I know a lot of people have tried this... Turns out godot themselves have an example!! I didn't get around to checking it out since my systems were built before I realized i could piggyback off of their work (sad) but I'm quite proud of what I got done in 10 hours!

### What even is this?
A voxel-based sandbox game where you can place and break blocks... That's about it.
* Random noise from a seed to generate the world
* Voxel based blocks
* Stone, Dirt, and Grass blocks
* Place and break blocks instantly using raycast
* First person camera and movement
* Scrolling hotbar to choose which block

### What do I take out of this?
Minecraft devs ARE NOT LAZY!! This stuff is super hard and super slow... How did they optimize it so much? Is Godot slow? Am I bad at optimizing? Did I not do my homework? Yes for the last one...

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Screenshots

<details>
  <summary><strong>OS Shatter</strong></summary>
  <img src="Media/glitch_4.png" alt="One frame of the procedural shatter effect done on the OS menu. Eyeball is watching!!! ">
</details>

#### Notes
- Nothing

> [!TIP]
> Scroll! Look around! Have fun! Not a lot happens sooo...

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![Godot][Godot 4.4]][Godot-url]
<!--
* [![Next][Next.js]][Next-url]
* [![React][React.js]][React-url]
* [![Vue][Vue.js]][Vue-url]
* [![Angular][Angular.io]][Angular-url]
* [![Svelte][Svelte.dev]][Svelte-url]
* [![Laravel][Laravel.com]][Laravel-url]
* [![Bootstrap][Bootstrap.com]][Bootstrap-url]
* [![JQuery][JQuery.com]][JQuery-url]-->
<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Play

If you still insist on building this unoptimized mess, go ahead.

1. Install Godot 4.5
2. Download and unzip the code
3. Open the file with Godot project manager
4. Go to Project > Export, add whichever platform you're on (MacOS, Windows) and then click export.
5. You're good to go!

#### Tutorial
WASD to move
Mouse movements to pan camera
Left click to break
Right click to place
Space to jump

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

### Phase 1: Player Controller
- [ ] Movement
  - [X] Implement WASD movement
  - [X] Add jumping and gravity
  - [ ] Create collision detection with voxels
  - [ ] Implement sprinting
  - [ ] Add crouching/sneaking
  - [ ] Implement swimming mechanics
- [X] Camera
  - [X] Set up first-person camera
  - [X] Add crosshair
  - [ ] Add mouse look with sensitivity settings
  - [ ] Implement head bobbing
  - [ ] Add FOV adjustments

### Phase 2: Core Voxel Engine
- [ ] Block System
  - [X] Create `Block` resource class with properties (id, name, texture coordinates)
  - [X] Build block registry/database
  - [X] Implement block types (air, dirt, grass, stone, wood, leaves)
  - [ ] Set up texture atlas system
    - [X] Temporary color system for blocks
- [ ] Chunk System
  - [X] Design chunk data structure (16x16x16 or 32x32x32 blocks)
  - [X] Implement chunk class with 3D array storage
  - [X] Saving and loading chunks
  - [ ] Create chunk mesh generation (greedy meshing algorithm)
  - [ ] Add face culling (don't render hidden faces)
  - [ ] Implement chunk serialization/deserialization
- [x] World Management
  - [x] Create world manager to handle multiple chunks
  - [x] Implement chunk loading/unloading based on player position
  - [ ] Add chunk pooling for performance
  - [ ] Set up coordinate system (world → chunk → local block)

### Phase 3: Terrain Generation
- [ ] Noise-based Generation
  - [x] Implement 2D height map using FastNoiseLite
  - [X] Add multiple octaves for varied terrain
  - [ ] Create biome system (plains, forest, desert, mountains)
  - [ ] Generate caves using 3D noise
  - [ ] Add ore distribution (coal, iron, gold, diamond)
- [ ] World Features
  - [ ] Generate trees (oak, birch, pine)
  - [ ] Add surface decorations (grass, flowers)
  - [ ] Implement water lakes
  - [ ] Create bedrock layer

### Phase 4: Block Interaction
- [x] Raycasting
  - [x] Implement voxel raycasting for block selection
  - [ ] Make efficient mesh reloading (so we don't rebuild entire chunk every time)
  - [X] Add block outline/highlight shader (did it with a box that's slightly bigger)
  - [ ] Detect which face was hit
- [ ] Block Modification
  - [ ] Implement block breaking with timing
  - [ ] Add break animation/particles
  - [ ] Implement block placement
  - [ ] Handle placement validation (no placing inside player)
  - [ ] Update adjacent chunks when needed
  - [ ] Possibly gravity / other animations (falling trees or exploding tnt maybe? something lively)
- [ ] Block Sounds
  - [ ] Add sound effects for breaking blocks
  - [ ] Add sound effects for placing blocks
  - [ ] Implement footstep sounds

### Phase 5: Inventory & Crafting
- [ ] Inventory System
  - [ ] Create inventory data structure
  - [ ] Implement hotbar (9 slots)
  - [ ] Build full inventory UI (27+ slots)
  - [ ] Add item stacking
  - [ ] Implement item pickup system
  - [ ] Create inventory save/load
- [ ] Crafting
  - [ ] Design crafting table UI
  - [ ] Implement recipe system
  - [ ] Add 2x2 player crafting
  - [ ] Add 3x3 crafting table crafting
  - [ ] Create furnace smelting system

### Phase 6: Survival Mechanics
- [ ] Player Stats
  - [ ] Implement health system (hearts)
  - [ ] Add hunger/food system
  - [ ] Create regeneration mechanics
  - [ ] Add death and respawn
- [ ] Environmental Hazards
  - [ ] Implement fall damage
  - [ ] Add drowning in water
  - [ ] Create lava damage
  - [ ] Add day/night cycle
  - [ ] Implement lighting system
- [ ] Mobs (Basic)
  - [ ] Create basic mob AI framework
  - [ ] Add passive mobs (pig, cow, chicken)
  - [ ] Implement basic hostile mob (zombie)
  - [ ] Mob navigation / state machines
  - [ ] Add mob spawning system
  - [ ] Create basic combat system

### Phase 7: Optimization
- [ ] Profile and optimize mesh generation
- [ ] Implement threading for chunk generation (this is going to hurt)
- [ ] Optimize collision detection (figure out if godot does this well enough)
- [ ] Implement occlusion culling (figure out if godot does this for me)
- [ ] Add distance fog
- [ ] Optimize memory usage
- [ ] Add level of detail (LOD) system

### Phase 8: Polish & Advanced Features
- [ ] Graphics
  - [ ] Add ambient occlusion
  - [ ] Implement proper lighting propagation
  - [ ] Add particle effects
  - [ ] Create weather system (rain, snow)
  - [ ] Add sky/cloud rendering
  - [ ] God rays
  - [ ] Find cool minecraft shaders and implement??
- [ ] World Features
  - [ ] Generate villages
  - [ ] Add dungeons/structures
  - [ ] Implement the Nether (alternate dimension)
  - [ ] Create strongholds and End portal
- [ ] Advanced Mechanics
  - [ ] Add farming mechanics
  - [ ] Implement enchanting system
  - [ ] Create brewing system
  - [ ] Redstone-like logic system
  - [ ] Add multiplayer support (NEVER lol)

### Bugs and Notes for future
- [ ] Moving into a place while falling doesn't move you into the place... why?

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Pixel Saver - [itch.io](https://pixelsaver.itch.io/)

Project Link: [https://github.com/PixelSaver/PlacePixels](https://github.com/PixelSaver/PlacePixels)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

for now nothing because i havent added anything
