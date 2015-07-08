-- fix path so all examples can use editgrid from parent directory.
package.path = [[../../?.lua;]]..package.path

local editgrid = require "editgrid"

-- the grid
local grid = editgrid.new{}

-- mouse location
local mx, my = 0, 0

-- location of mouse on the grid
local mWorldx, mWorldy = 0, 0

-- location of grid origin on screen
local oScreenx, oScreeny = 0, 0

-- cam.x, cam.y is the top left corner of the camera
local cam = {
    x = 0,
    y = 0,
    zoom = 1,
    angle = 0
}

function love.draw()
    grid:draw(cam.x, cam.y, cam.zoom, cam.angle)
    love.graphics.printf(
        "Camera position: (" ..
        cam.x .. ", " .. cam.y ..
        ")\nCamera zoom: " ..
        cam.zoom ..
        "\nMouse position on Grid: (" ..
        mWorldx  .. ", " .. mWorldy ..
        ")\nGrid origin position on screen: (" ..
        oScreenx .. ", " .. oScreeny .. ")",
    30, 30, 800, "left")
end

function love.update(dt)
    local newmx, newmy = love.mouse.getPosition()
    if love.mouse.isDown("l") then
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
    oScreenx, oScreeny = grid:toScreen(0, 0, cam.x, cam.y, cam.zoom, cam.angle)
    mWorldx, mWorldy = grid:toWorld(mx, my, cam.x, cam.y, cam.zoom, cam.angle)
end

function love.mousepressed(x, y, button)
    local zoomfactor = nil
    if button == "wu" then
        zoomfactor = 1.05
    elseif button == "wd" then
        zoomfactor = 1 / 1.05
    end
    if zoomfactor then
        cam.zoom = cam.zoom * zoomfactor
    end
end
