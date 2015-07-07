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
    x = love.graphics.getWidth() * -0.5,
    y = love.graphics.getHeight() * -0.5,
    zoom = 1
}

function love.draw()
    grid:draw(cam.x, cam.y, cam.zoom)
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
        cam.x = cam.x + (-newmx + mx) / cam.zoom
        cam.y = cam.y + (-newmy + my) / cam.zoom
    end
    mx, my = newmx, newmy
    oScreenx, oScreeny = grid:worldToScreen(0, 0, cam.x, cam.y, cam.zoom)
    mWorldx, mWorldy = grid:screenToWorld(mx, my, cam.x, cam.y, cam.zoom)
end

function love.mousepressed(x, y, button)
    local zoomfactor = nil
    if button == "wu" then
        zoomfactor = 1.05
    elseif button == "wd" then
        zoomfactor = 1 / 1.05
    end
    if zoomfactor then
        local wx, wy = cam.x + x / cam.zoom, cam.y + y / cam.zoom
        cam.zoom = cam.zoom * zoomfactor
        cam.x, cam.y = wx - x / cam.zoom, wy - y / cam.zoom
    end
end
