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

local EMPTY = {}

local function floor(x, y)
    return math.floor(x / y) * y
end

local function mod(x, y)
    return x - floor(x, y)
end

local function getGeometry(t)
    local sx, sy, sw, sh
    if t.getWindow then -- assume t is a gamera camera
        sx, sy, sw, sh = t:getWindow()
    else
        sx, sy, sw, sh = t.sx or 0, t.sy or 0, t.sw or lg.getWidth(), t.sh or lg.getHeight()
    end
    return t.x or 0, t.y or 0, t.scale or t.zoom or 1, t.angle or t.rot or 0, sx, sy, sw, sh
end

local function getVisuals(t)
    local size = t.size or 256
    local sds = t.subdivisions or 4
    local color = t.color or {220, 220, 220}
    local drawScale
    if t.drawScale == nil then
        drawScale = true
    else
        drawScale = t.drawScale
    end
    local xColor = t.xColor or {255, 0, 0}
    local yColor = t.yColor or {0, 255, 0}
    return size, sds, drawScale, color, xColor, yColor
end

local function getGridInterval(visuals, zoom)
    if visuals.interval then
        return visuals.interval
    else
        local size, sds = getVisuals(visuals)
        return size * math.pow(sds, -math.ceil(math.log(zoom, sds)))
    end
end

local function visibleBox(args)
    local camx, camy, zoom, angle, sx, sy, sw, sh = getGeometry(args)
    local w, h = sw / zoom, sh / zoom
    if args.angle ~= 0 then
        local sin, cos = math.abs(math.sin(angle)), math.abs(math.cos(angle))
        w, h = cos * w + sin * h, sin * w + cos * h
    end
    return camx - w * 0.5, camy - h * 0.5, w, h
end

local function toWorld(args, screenx, screeny)
    local camx, camy, zoom, angle, sx, sy, sw, sh = getGeometry(args)
    local sin, cos = math.sin(angle), math.cos(angle)
    local x, y = (screenx - sw/2 - sx) / zoom, (screeny - sh/2 - sy) / zoom
    x, y = cos * x - sin * y, sin * x + cos * y
    return x + camx, y + camy
end

local function toScreen(args, worldx, worldy)
    local camx, camy, zoom, angle, sx, sy, sw, sh = getGeometry(args)
    local sin, cos = math.sin(angle), math.cos(angle)
    local x, y = worldx - camx, worldy - camy
    x, y = cos * x + sin * y, -sin * x + cos * y
    return zoom * x + sw/2 + sx, zoom * y + sh/2 + sy
end

local function drawScaleText(args, visuals)
    local camx, camy, zoom, angle, sx, sy, sw, sh = getGeometry(args)
    local size, sds, drawScale, color, xColor, yColor = getVisuals(visuals)
    local camleft, camtop = toWorld(args, sx, sy)
    local d = getGridInterval(visuals, zoom)
    local ff = 0.6
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
            lg.setColor(yColor[1], yColor[2], yColor[3], 255)
            tmpZeroString = zeroString
            xc = 0
        elseif xc >= sds - 1 then
            lg.setColor(color[1], color[2], color[3], 255)
            xc = 0
        else
            lg.setColor(color[1] * ff, color[2] * ff, color[3] * ff, 255)
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
            lg.setColor(xColor[1], xColor[2], xColor[3], 255)
            tmpZeroString = zeroString
            yc = 0
        elseif yc >= sds - 1 then
            lg.setColor(color[1], color[2], color[3], 255)
            yc = 0
        else
            lg.setColor(color[1] * ff, color[2] * ff, color[3] * ff, 255)
            yc = yc + 1
        end
        lg.printf(tmpZeroString or realy, sx + 2, y, 200, "left")
        realy = realy + d
    end
end

local function draw(args, visuals)
    args = args or EMPTY
    visuals = visuals or EMPTY
    local camx, camy, zoom, angle, sx, sy, sw, sh = getGeometry(args)
    local size, sds, drawScale, color, xColor, yColor = getVisuals(visuals)

    lg.setScissor(sx, sy, sw, sh)
    local vx, vy, vw, vh = visibleBox(args)
    local d = getGridInterval(visuals, zoom)

    -- color fade factor between main grid lines and subdivisions
    local ff = 0.6

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
            lg.setColor(yColor[1], yColor[2], yColor[3], 255)
            xc = 1
        elseif xc >= sds then
            lg.setColor(color[1], color[2], color[3], 255)
            xc = 1
        else
            lg.setColor(color[1] * ff, color[2] * ff, color[3] * ff, 255)
            xc = xc + 1
        end
        lg.line(x, vy, x, vy + vh)
    end

    -- lines parallel to x axis
    local yc = sds
    for y = floor(vy, d * sds), vy + vh, d do
        if math.abs(y) < delta then
            lg.setColor(xColor[1], xColor[2], xColor[3], 255)
            yc = 1
        elseif yc >= sds then
            lg.setColor(color[1], color[2], color[3], 255)
            yc = 1
        else
            lg.setColor(color[1] * ff, color[2] * ff, color[3] * ff, 255)
            yc = yc + 1
        end
        lg.line(vx, y, vx + vw, y)
    end

    lg.pop()
    lg.setLineWidth(1)

    -- draw origin
    lg.setColor(255, 255, 255, 255)
    local ox, oy = toScreen(args, 0, 0)
    lg.rectangle("fill", ox - 1, oy - 1, 2, 2)
    lg.circle("line", ox, oy, 8)

    lg.setLineWidth(oldLineWidth)

    -- TODO draw scale at non-zero angles
    if drawScale and angle == 0 then
        drawScaleText(args, visuals)
    end

    lg.setColor(255, 255, 255, 255)

    lg.setScissor()
end

return {
    toWorld = toWorld,
    toScreen = toScreen,
    draw = draw
}
