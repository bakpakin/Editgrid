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
    self.xColor = args.xColor or {0, 0, 255}
    self.yColor = args.yColor or {0, 255, 0}
    self.interval = args.interval
    return self
end

local function mod(x, y)
    return x - math.floor(x / y) * y
end

local function getScreen(sx, sy, sw, sh)
    return sx or 0, sy or 0, sw or lg.getWidth(), sh or lg.getHeight()
end

local function getGridInterval(self, zoom)
    if self.interval then
        return self.interval
    else
        local sds = self.subdivisions
        return self.size * math.pow(sds, -math.ceil(math.log(zoom, sds)))
    end
end

function grid:screenToWorld(screenx, screeny, camleft, camtop, zoom, sx, sy)
    sx, sy = sx or 0, sy or 0
    return ((screenx - sx) / zoom) + camleft, ((screeny - sy) / zoom) + camtop
end

function grid:worldToScreen(worldx, worldy, camleft, camtop, zoom, sx, sy)
    sx, sy = sx or 0, sy or 0
    return (worldx - camleft) * zoom + sx, (worldy - camtop) * zoom + sy
end

function grid:draw(camleft, camtop, zoom, sx, sy, sw, sh)
    local oldsx, oldsy, oldsw, oldsh = love.graphics.getScissor()
    sx, sy, sw, sh = getScreen(sx, sy, sw, sh)
    love.graphics.setScissor(sx, sy, sw, sh)
    camleft, camtop, zoom = camleft or 0, camtop or 0, zoom or 1

    local c = self.color

    local d = getGridInterval(self, zoom)
    local x1 = -mod(camleft, d) * zoom + sx
    local y1 = -mod(camtop, d) * zoom + sy

    -- color fade factor between main grid lines and subdivisions
    local ff = 0.5
    local xcol = self.xColor
    local ycol = self.yColor

    -- floating point comparison delta
    local delta = d * 0.5
    local zeroString = "0"
    local tmpZeroString

    -- vertical lines
    local xc = mod(camleft / d, self.subdivisions) - 1
    local realx = camleft + x1 / zoom
    for x = x1, sx + sw, d * zoom do
        tmpZeroString = nil
        if math.abs(realx) < delta then
            lg.setColor(ycol[1], ycol[2], ycol[3], 255)
            lg.rectangle("fill", x - 1, sy, 2, sh)
            -- force axis to be labeled '0' (prevent rounding error)
            tmpZeroString = zeroString
            xc = 0
        elseif xc >= self.subdivisions - 1 then
            lg.setColor(c[1], c[2], c[3], 255)
            lg.rectangle("fill", x, sy, 1, sh)
            xc = 0
        else
            lg.setColor(c[1] * ff, c[2] * ff, c[3] * ff, 255)
            lg.rectangle("fill", x, sy, 1, sh)
            xc = xc + 1
        end
        if self.drawScale then
            lg.printf(tmpZeroString or realx, x + 2, sy, 200, "left")
        end
        realx = realx + d
    end

    -- horizontal lines
    local yc = mod(camtop / d, self.subdivisions) - 1
    local realy = camtop + y1 / zoom
    for y = y1, sy + sh, d * zoom do
        tmpZeroString = nil
        if math.abs(realy) < delta then
            lg.setColor(xcol[1], xcol[2], xcol[3], 255)
            lg.rectangle("fill", sx, y - 1, sw, 2)
            -- force axis to be labeled '0' (prevent rounding error)
            tmpZeroString = zeroString
            yc = 0
        elseif yc >= self.subdivisions - 1 then
            lg.setColor(c[1], c[2], c[3], 255)
            lg.rectangle("fill", sx, y, sw, 1)
            yc = 0
        else
            lg.setColor(c[1] * ff, c[2] * ff, c[3] * ff, 255)
            lg.rectangle("fill", sx, y, sw, 1)
            yc = yc + 1
        end
        if self.drawScale then
            lg.printf(tmpZeroString or realy, sx + 2, y, 200, "left")
        end
        realy = realy + d
    end

    -- draw origin
    lg.setColor(255, 255, 255, 255)
    local ox, oy = self:worldToScreen(0, 0, camleft, camtop, zoom, sx, sy)
    lg.rectangle("fill", ox - 1, oy - 1, 2, 2)
    lg.circle("line", ox, oy, 8)

    love.graphics.setScissor(oldsx, oldsy, oldsw, oldsh)
end

function grid:drawGamera(camera)
    if camera:getAngle() ~= 0 then -- don't throw error, just don't draw grid.
        print "editgrid does not yet support non-zero camera angles :(."
        return
    end
    local gl, gt, gw, gh = camera:getWindow()
    local gvl, gvt = camera:getVisible()
    self:draw(gvl, gvt, camera:getScale(), gl, gt, gw, gh)
end

return grid
