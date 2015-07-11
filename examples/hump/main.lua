-- fix path so all examples can use editgrid from parent directory.
package.path = [[../../?.lua;]]..package.path

local editgrid = require "editgrid"
local camera = require "humpcamera"

-- mouse location
local mx, my = 0, 0

-- location of mouse on the grid
local mWorldx, mWorldy = 0, 0

-- location of grid origin on screen
local oScreenx, oScreeny = 0, 0

local cam = camera.new(0, 0)

function love.draw()
    editgrid.draw(cam)
    local camx, camy = cam:pos()
    local scale = cam.scale
    love.graphics.printf(
        "Camera position: (" ..
        camx .. ", " .. camy ..
        ")\nCamera zoom: " ..
        scale ..
        "\nMouse position on Grid: (" ..
        mWorldx  .. ", " .. mWorldy ..
        ")\nGrid origin position on screen: (" ..
        oScreenx .. ", " .. oScreeny .. ")",
    30, 30, 800, "left")
end

function love.update(dt)
    local newmx, newmy = love.mouse.getPosition()
    local camx, camy = cam:pos()
    local scale = cam.scale
    local angle = cam.rot
    if love.mouse.isDown("l") then
        local s, c = math.sin(angle), math.cos(angle)
        local dx = (-newmx + mx) / scale
        local dy = (-newmy + my) / scale
        cam:lookAt(camx + dx * c - dy * s, camy + dy * c + dx * s)
    end
    if love.keyboard.isDown("q") then
        cam:rotateTo(cam.rot + dt)
    end
    if love.keyboard.isDown("e") then
        cam:rotateTo(cam.rot - dt)
    end
    mx, my = newmx, newmy
    oScreenx, oScreeny = cam:cameraCoords(0, 0)
    mWorldx, mWorldy = cam:worldCoords(mx, my)
end

function love.mousepressed(x, y, button)
    local zoomfactor = nil
    if button == "wu" then
        zoomfactor = 1.05
    elseif button == "wd" then
        zoomfactor = 1 / 1.05
    end
    if zoomfactor then
        cam:zoomTo(cam.scale * zoomfactor)
    end
end
