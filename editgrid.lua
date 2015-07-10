--[[
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
]]

local lg = love.graphics
local grid = {}
grid.__index = grid

-- helper functions

local function floor(x, y)
    return math.floor(x / y) * y
end

local function mod(x, y)
    return x - floor(x, y)
end

local function getScreen(sx, sy, sw, sh)
    return sx or 0, sy or 0, sw or lg.getWidth(), sh or lg.getHeight()
end

local function getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh)
    return camx or 0, camy or 0, zoom or 1, angle or 0, getScreen(sx, sy, sw, sh)
end

local function getGridInterval(self, zoom)
    if self.interval then
        return self.interval
    else
        local sds = self.subdivisions
        return self.size * math.pow(sds, -math.ceil(math.log(zoom, sds)))
    end
end

-- return the visible aabb in grid-space as x, y, w, h
local function visibleBox(camx, camy, zoom, angle, sx, sy, sw, sh)
    camx, camy, zoom, angle, sx, sy, sw, sh = getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh)
    local w, h = sw / zoom, sh / zoom
    if angle ~= 0 then
        local sin, cos = math.abs(math.sin(angle)), math.abs(math.cos(angle))
        w, h = cos * w + sin * h, sin * w + cos * h
    end
    return camx - w * 0.5, camy - h * 0.5, w, h
end

local function toWorld(screenx, screeny, camx, camy, zoom, angle, sx, sy, sw, sh)
    local sin, cos = math.sin(angle), math.cos(angle)
    local x, y = (screenx - sw/2 - sx) / zoom, (screeny - sh/2 - sy) / zoom
    x, y = cos * x - sin * y, sin * x + cos * y
    return x + camx, y + camy
end

local function toScreen(worldx, worldy, camx, camy, zoom, angle, sx, sy, sw, sh)
    local sin, cos = math.sin(angle), math.cos(angle)
    local x, y = worldx - camx, worldy - camy
    x, y = cos * x + sin * y, -sin * x + cos * y
    return zoom * x + sw/2 + sx, zoom * y + sh/2 + sy
end

-- TODO make this function smaller?
local function drawScale(self, camx, camy, zoom, sx, sy, sw, sh)
    local camleft, camtop = toWorld(sx, sy, camx, camy, zoom, 0, sx, sy, sw, sh)
    local d = getGridInterval(self, zoom)
    local sds = self.subdivisions
    local ff = 0.5
    local c = self.color
    local xcol = self.xColor
    local ycol = self.yColor
    local delta = d * 0.5
    local zeroString = "0"
    local tmpZeroString

    local x1 = -mod(camleft, d) * zoom + sx
    local y1 = -mod(camtop, d) * zoom + sy

    -- vertical lines
    local xc = mod(camleft / d, sds) - 1
    local realx = camleft + (x1 - sx) / zoom
    for x = x1, sx + sw, d * zoom do
        tmpZeroString = nil
        if math.abs(realx) < delta then
            lg.setColor(ycol[1], ycol[2], ycol[3], 255)
            tmpZeroString = zeroString
            xc = 0
        elseif xc >= sds - 1 then
            lg.setColor(c[1], c[2], c[3], 255)
            xc = 0
        else
            lg.setColor(c[1] * ff, c[2] * ff, c[3] * ff, 255)
            xc = xc + 1
        end
        lg.printf(tmpZeroString or realx, x + 2, sy, 200, "left")
        realx = realx + d
    end

    -- horizontal lines
    local yc = mod(camtop / d, sds) - 1
    local realy = camtop + (y1 - sy) / zoom
    for y = y1, sy + sh, d * zoom do
        tmpZeroString = nil
        if math.abs(realy) < delta then
            lg.setColor(xcol[1], xcol[2], xcol[3], 255)
            tmpZeroString = zeroString
            yc = 0
        elseif yc >= sds - 1 then
            lg.setColor(c[1], c[2], c[3], 255)
            yc = 0
        else
            lg.setColor(c[1] * ff, c[2] * ff, c[3] * ff, 255)
            yc = yc + 1
        end
        lg.printf(tmpZeroString or realy, sx + 2, y, 200, "left")
        realy = realy + d
    end
end

-- module grid functions

function grid.new(args)
    args = args or {}
    local self = setmetatable({}, grid)
    self.size = args.size or 256
    self.subdivisions = args.subdivisions or 4
    self.color = args.color or {220, 220, 220}
    if args.drawScale == nil then
        self.drawScale = true
    else
        self.drawScale = args.drawScale
    end
    self.xColor = args.xColor or {255, 0, 0}
    self.yColor = args.yColor or {0, 255, 0}
    self.interval = args.interval
    return self
end

function grid.toScreen(worldx, worldy, camx, camy, zoom, angle, sx, sy, sw, sh)
    return toScreen(worldx, worldy, getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh))
end

function grid.toWorld(screenx, screeny, camx, camy, zoom, angle, sx, sy, sw, sh)
    return toWorld(screenx, screeny, getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh))
end

-- grid methods

function grid:draw(camx, camy, zoom, angle, sx, sy, sw, sh)

    camx, camy, zoom, angle, sx, sy, sw, sh = getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh)

    lg.setScissor(sx, sy, sw, sh)
    local vx, vy, vw, vh = visibleBox(camx, camy, zoom, angle, sx, sy, sw, sh)
    local d = getGridInterval(self, zoom)
    local sds = self.subdivisions

    -- color fade factor between main grid lines and subdivisions
    local ff = 0.5
    local c = self.color
    local xcol = self.xColor
    local ycol = self.yColor

    -- floating point comparison delta
    local delta = d * 0.5

    lg.push()
    lg.scale(zoom)
    lg.translate((sw/2 + sx) / zoom, (sh/2 + sy) / zoom)
    lg.rotate(-angle)
    lg.translate(-camx, -camy)

    local oldLineWidth = lg.getLineWidth()
    lg.setLineWidth(1 / zoom)

    -- lines parallel to y axis
    local xc = sds
    for x = floor(vx, d * sds), vx + vw, d do
        if math.abs(x) < delta then
            lg.setColor(ycol[1], ycol[2], ycol[3], 255)
            xc = 1
        elseif xc >= sds then
            lg.setColor(c[1], c[2], c[3], 255)
            xc = 1
        else
            lg.setColor(c[1] * ff, c[2] * ff, c[3] * ff, 255)
            xc = xc + 1
        end
        lg.line(x, vy, x, vy + vh)
    end

    -- lines parallel to x axis
    local yc = sds
    for y = floor(vy, d * sds), vy + vh, d do
        if math.abs(y) < delta then
            lg.setColor(xcol[1], xcol[2], xcol[3], 255)
            yc = 1
        elseif yc >= sds then
            lg.setColor(c[1], c[2], c[3], 255)
            yc = 1
        else
            lg.setColor(c[1] * ff, c[2] * ff, c[3] * ff, 255)
            yc = yc + 1
        end
        lg.line(vx, y, vx + vw, y)
    end

    lg.pop()
    lg.setLineWidth(oldLineWidth)

    -- draw origin
    lg.setColor(255, 255, 255, 255)
    local ox, oy = toScreen(0, 0, camx, camy, zoom, angle, sx, sy, sw, sh)
    lg.rectangle("fill", ox - 1, oy - 1, 2, 2)
    lg.circle("line", ox, oy, 8)

    -- TODO draw scale at non-zero angles
    if self.drawScale and angle == 0 then
        drawScale(self, camx, camy, zoom, sx, sy, sw, sh)
    end

    lg.setColor(255, 255, 255, 255)

    lg.setScissor()
end

function grid:drawGamera(camera)
    local x, y = camera:getPosition()
    self:draw(x, y, camera:getScale(), camera:getAngle(), camera:getWindow())
end

function grid:drawHump(camera)
    self:draw(camera.x, camera.y, camera.scale, camera.rot)
end

return grid
