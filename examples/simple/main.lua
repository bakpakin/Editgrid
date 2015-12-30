-- fix path so all examples can use editgrid from parent directory.
package.path = [[../../?.lua;]]..package.path

local editgrid = require "editgrid"

-- mouse location
local mx, my = 0, 0

-- location of mouse on the grid
local mWorldx, mWorldy = 0, 0

-- location of grid origin on screen
local oScreenx, oScreeny = 0, 0

-- cam.x, cam.y is center of the camera
local cam = {
    x = 0,
    y = 0,
    zoom = 1,
    angle = 0
}

local grid = editgrid.grid(cam)

function love.draw()
    grid:draw()
    local cx, cy = grid:convertCoords("screen", "cell", mx, my)
    love.graphics.printf(
        "Camera position: (" ..
        cam.x .. ", " .. cam.y ..
        ")\nCamera zoom: " ..
        cam.zoom ..
        "\nMouse position on Grid: (" ..
        mWorldx  .. ", " .. mWorldy ..
        ")\nCell coordinate under mouse: (" ..
        cx .. ", " .. cy ..
        ")\nGrid origin position on screen: (" ..
        oScreenx .. ", " .. oScreeny .. ")",
    30, 30, 800, "left")
end

function love.update(dt)
    local newmx, newmy = love.mouse.getPosition()
    if love.mouse.isDown(1) then
        local s, c = math.sin(cam.angle), math.cos(cam.angle)
        local dx = (-newmx + mx) / cam.zoom
        local dy = (-newmy + my) / cam.zoom
        cam.x = cam.x + dx * c - dy * s
        cam.y = cam.y + dy * c + dx * s
    end
    if love.keyboard.isDown("q") then
        cam.angle = cam.angle + dt
    end
    if love.keyboard.isDown("e") then
        cam.angle = cam.angle - dt
    end
    mx, my = newmx, newmy
    oScreenx, oScreeny = grid:toScreen(0, 0)
    mWorldx, mWorldy = grid:toWorld(mx, my)
end

function love.wheelmoved(x, y)
    local zoomfactor = nil
    if y > 0 then
        zoomfactor = 1.05
    elseif y < 0 then
        zoomfactor = 1 / 1.05
    end
    if zoomfactor then
        cam.zoom = cam.zoom * zoomfactor
    end
end
