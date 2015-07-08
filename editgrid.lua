local lg = love.graphics
local grid = {}
grid.__index = grid

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

function grid:toWorld(screenx, screeny, camx, camy, zoom, angle, sx, sy, sw, sh)

    camx, camy, zoom, angle, sx, sy, sw, sh = getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh)

    local sin, cos = math.sin(angle), math.cos(angle)
    local x, y = (screenx - sw/2 - sx) / zoom, (screeny - sh/2 - sy) / zoom
    x, y = cos * x - sin * y, sin * x + cos * y
    return x + camx, y + camy
end

function grid:toScreen(worldx, worldy, camx, camy, zoom, angle, sx, sy, sw, sh)

    camx, camy, zoom, angle, sx, sy, sw, sh = getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh)

    local sin, cos = math.sin(angle), math.cos(angle)
    local x, y = worldx - camx, worldy - camy
    x, y = cos * x + sin * y, -sin * x + cos * y
    return zoom * x + sw/2 + sx, zoom * y + sh/2 + sy
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

local function drawScale(self, camx, camy, zoom, angle, sx, sy, sw, sh)
    camx, camy, zoom, angle, sx, sy, sw, sh = getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh)
    -- TODO
end

function grid:draw(camx, camy, zoom, angle, sx, sy, sw, sh)

    camx, camy, zoom, angle, sx, sy, sw, sh = getDefaults(camx, camy, zoom, angle, sx, sy, sw, sh)

    lg.setScissor(sx, sy, sw, sh)
    local vx, vy, vw, vh = visibleBox(camx, camy, zoom, angle, sx, sy, sw, sh)
    local c = self.color
    local d = getGridInterval(self, zoom)
    local sds = self.subdivisions

    -- color fade factor between main grid lines and subdivisions
    local ff = 0.5
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

    -- vertical lines
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

    -- horizontal lines
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
    local ox, oy = self:toScreen(0, 0, camx, camy, zoom, angle, sx, sy, sw, sh)
    lg.rectangle("fill", ox - 1, oy - 1, 2, 2)
    lg.circle("line", ox, oy, 8)

    if self.drawScale then
        drawScale(self, camx, camy, zoom, angle, sx, sy, sw, sh)
    end

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
