![Image Not Found](https://github.com/bakpakin/Editgrid/raw/master/preview.gif)
# Editgrid

## What's this?
Editgrid is a module that implements a grid that automatically scales its resolution, like the background grids in 3d modeling software like blender.
Its great for level editors and the like because you can zoom in and out without loosing sight of the gridlines.
It also converts screen coordinates to grid coordinates and vice versa.

Editgrid is also useful for adding a debugging background to games - just call grid:draw(camleft, camtop, zoom)
before the rest of your draw calls, or if using with gamera, call grid:drawGamera(camera).

## How to use
Place editgrid.lua in your project and require it like so:
```lua
local editgrid = require "editgrid"
```

## API

#### Creating a new grid
```lua
local grid = editgrid.new{
    size = 100,
    subdivisions = 5,
    color = {128, 140, 250},
    drawScale = false,
    xColor = {255, 255, 0},
    yColor = {0, 255, 255},
    interval = 200
}
```
This function creates a new grid with a variety of optional paramers. It can take a map
of parameters or nothing, which creates the default grid.
* `size` -- the distance between each major subdivision at 1x zoom. Default is 256.
* `subdivisions` -- the number of minor subdivisions between each major subdivision. Default is 4.
* `color` -- a list of three numbers representing the rgb values of the grid lines. Default is {220, 220, 220}.
* `drawScale` -- boolean indicating if the coordinate value is drawn for each gridline. Scale is only drawn when the grid angle is 0.
Default is true.
* `xColor` -- color of the x axis. Default is {255, 0, 0} (red).
* `yColor` -- color of the y axis. Default is {0, 255, 0} (green).
* `interval` -- optional argument that makes the grid use a fixed interval instead of scaling with camera zoom.

#### Drawing the grid
```lua
grid:draw(camx, camy, zoom, angle, [sx, sy, sw, sh])
```
Draws the grid to the screen from a perspective. `camx` and `camy` represent the grid coordinate at the center of the screen.
`zoom` is the scale multiplier. The four optional parameters represent a rectangle on the screen where the grid is drawn.
By default, grid is drawn on the whole screen.

```lua
grid:drawGamera(camera)
```
Draws a grid from the perspective of a gamera camera.

```lua
grid:drawHump(camera)
```
Draws a grid from the perspective of a HUMP camera.

#### Coordinate conversion
```lua
local worldx, worldy = editgrid.toWorld(screenx, screeny, camx, camy, zoom, angle, [sx, sy])
```
Converts screen coordinates to world coordinates.

```lua
local screenx, screeny = editgrid.toScreen(worldx, worldy, camx, camy, zoom, angle, [sx, sy])
```
Converts world coordinates to screen coordinates.

## Bugs
If there are are bugs or you want to request features, feel free to submit issues.
