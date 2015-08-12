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

All functions in Editgrid that require a `camera` can use all types of cameras.

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
    textFadeFactor = 0.5,
    hideOrigin = true,
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
* `textFadeFactor` -- color multiplier on grid labels. Similar to `fadeFactor`. Default is 1.0.
* `hideOrigin` -- boolean indicating whether or not to hide the origin circle. Default is false.
* `interval` -- optional argument that makes the grid use a fixed interval in world space instead of scaling with camera zoom.

All functions in Editgrid that require a `visuals` table expect this format.

```lua
editgrid.push(camera)
-- draw()
-- stuff()
love.graphics.pop()
```
Editgrid enables drawing with compatible cameras in cross platform way. Surround normal drawing
commands with an `editgrid.push` and a `love.graphics.pop` to convert screen space to grid
space in your drawing. This should have equivalent results to drawing with a compatible
camera module.

#### Querying the grid
```lua
local newx, newy = editgrid.convertCoords(camera, visuals, src, dest, x, y)
```
Converts coordinates from one coordinate system to another. `src` and `dest` are
the source coordinate system and destination coordinate system respectively, and can each be one of
three strings: `"screen"`, `"world"`, and `"cell"`. For example, to convert screen coordinates to world
coordinates, say for mouse interaction, let `src = "screen"` and `dest = "world"`. `"cell"` coordinates
are based on the cells that the camera sees on the screen; also, all `"cell"` coordinates are integers.

```lua
local worldx, worldy = editgrid.toWorld(camera, screenx, screeny)
```
Converts screen coordinates to world coordinates.
Shortcut for `editgrid.convertCoords(camera, nil, "screen", "world", screenx, screeny)`

```lua
local screenx, screeny = editgrid.toScreen(camera, worldx, worldy)
```
Converts world coordinates to screen coordinates.
Shortcut for `editgrid.convertCoords(camera, nil, "world", "screen", worldx, worldy)`

```lua
local vx, vy, vw, vh = editgrid.visible(camera)
```
Gets an Axis Aligned Bounding Box (AABB) containing the visible part of the grid that can be seen
from the camera. May contain some non-visible portions of the grid if the camera angle is not zero.

```lua
local interval = editgrid.minorInterval(camera, visuals)
```
Gets the distance between minor grid lines (in world space) on the screen. To get the
distance in screen space, just multiply `interval` by camera zoom.

```lua
local interval = editgrid.majorInterval(camera, visuals)
```
Similar to `editgrid.minorInterval`, but returns the distance between major grid lines (the bolder grid lines).

#### Wrapping it all together
```lua
local grid = editgrid.grid(camera, visuals)

grid:draw() -- Equivalent to editgrid.draw(camera, visuals)
grid:push() -- Equivalent to editgrid.push(camera)
local newx, newy = grid:convertCoords(src, dest, x, y) -- Equivalent to editgrid.convertCoords(camera, visuals, src, dest, x, y)
local worldx, worldy = grid:toWorld(x, y) -- Equivalent to editgrid.toWorld(camera, x, y)
local screenx, screeny = grid:toScreen(x, y) -- Equivalent to editgrid.toScreen(camera, x, y)
local vx, vy, vw, vh = grid:visible() -- Equivalent to editgrid.visible(camera)
local minor = grid:minorInterval() -- Equivalent to editgrid.minorInterval(camera, visuals)
local major = grid:majorInterval() -- Equivalent to editgrid.majorInterval(camera, visuals)
```
Instead of passing a `camera` and a `visuals` variable around all the time for Editgrid's functions,
Editgrid can create a grid object with methods that can be called with colon syntax. The `camera` and `visuals`
tables can be updated at any time without any adverse effects.

## Bugs
If there are bugs or you want to request features, feel free to submit issues.

## License
Copyright (c) 2015 Calvin Rose

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
