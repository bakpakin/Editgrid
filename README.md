![Image Not Found](https://github.com/bakpakin/Editgrid/raw/master/preview.gif)
# Editgrid

## What's this?
Editgrid is a module that implements a grid that automatically scales its resolution, like the background grids in 3d modeling software like blender.
Its great for level editors and the like because you can zoom in and out without loosing sight of the gridlines.
It also converts screen coordinates to grid coordinates and vice versa.

Editgrid is also useful for adding a debugging background to games - just call editgrid.draw(camera) with
a [gamera](https://github.com/kikito/gamera) or [HUMP](http://vrld.github.io/hump/) camera, or just any table.

## How to use
Place editgrid.lua in your project and require it like so:
```lua
local editgrid = require "editgrid"
```

## API

#### Drawing a grid
```lua
editgrid.draw(camera, visuals)
```
Draws a grid to the screen from the perspective of an optional camera with optional visual effects.

`camera` can be a HUMP or gamera camera, as well as a table containing the following:
```lua
local camera = {
    x = 20,
    y = 20,
    zoom = 2,
    angle = math.pi/2,
    sx = 5,
    sy = 5,
    sw = love.graphics.getWidth() - 10,
    sh = love.graphics.getHeight() - 10
}
```
* `(x, y)` -- the point the camera is looking at. Default is (0, 0).
* `zoom` -- the zoom factor of the camera. Default is 1.
* `angle` -- the angle of the camera. Default is 0.
* `(sx, sy, sw, sh)` -- the clipping rectangle (scissor rectangle) for the camera. By default,
the camera draws to the whole screen (0, 0, love.graphics.getWidth(), love.graphics.getHeight()).

`visuals` should be a table containing the following:
```lua
local visuals = {
    size = 100,
    subdivisions = 5,
    color = {128, 140, 250},
    drawScale = false,
    xColor = {255, 255, 0},
    yColor = {0, 255, 255},
    fadeFactor = 0.3,
    interval = 200
}
```
* `size` -- the distance between each major subdivision at 1x zoom. Default is 256.
* `subdivisions` -- the number of minor subdivisions between each major subdivision. Default is 4.
* `color` -- a list of three numbers representing the rgb values of the grid lines. Default is {220, 220, 220}.
* `drawScale` -- boolean indicating if the coordinate value is drawn for each gridline. Default is true.
* `xColor` -- color of the x axis. Default is {255, 0, 0} (red).
* `yColor` -- color of the y axis. Default is {0, 255, 0} (green).
* `fadeFactor` -- color multiplier on subdivision grid lines. For example, if `color` is {100, 100, 100} and `fadeFactor` is
0.8, then the color of the minor gridlines will be {80, 80, 80}. Default is 0.5.
* `interval` -- optional argument that makes the grid use a fixed interval instead of scaling with camera zoom.

#### Coordinate conversion
```lua
local worldx, worldy = editgrid.toWorld(camera, screenx, screeny)
```
Converts screen coordinates to world coordinates. `camera` can be any camera recognized by Editgrid (gamera, HUMP, table).

```lua
local screenx, screeny = editgrid.toScreen(camera, worldx, worldy)
```
Converts world coordinates to screen coordinates. `camera` can be any camera recognized by Editgrid (gamera, HUMP, table).

```lua
local vx, vy, vw, vh = editgrid.visible(camera)
```
Gets an Axis Aligned Bounding Box (AABB) containing the visible part of the grid that can be seen
from the camera. May contain some non-visible portions of the grid if the camera angle is not zero.

#### Wrapping it all together
```lua
local grid = editgrid.grid(camera, visuals)

grid:draw() -- Equivalent to editgrid.draw(camera, visuals)
local worldx, worldy = grid:toWorld(x, y) -- Equivalent to editgrid.toWorld(camera, x, y)
local screenx, screeny = grid:toScreen(x, y) -- Equivalent to editgrid.toScreen(camera, x, y)
local vx, vy, vw, vh = grid:visible() -- Equivalent to editgrid.visible(camera)
```
Instead of passing a `camera` and a `visuals` variable around all the time for Editgrid's functions,
Editgrid can create a grid object with methods that can be called with colon syntax.

## Bugs
If there are bugs or you want to request features, feel free to submit issues.
