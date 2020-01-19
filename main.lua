
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED=200
Class = require 'class'
push = require 'push'
require 'Paddle'
require 'Ball'
gameState="start"
function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont("font.ttf", 8)
    scoreFont = love.graphics.newFont("font.ttf", 32)
    winFont = love.graphics.newFont("font.ttf", 16)
  
    sounds={
        ["wall_hit"]=love.audio.newSource("sounds/wall_hit.wav", 'static'),
        ["paddle_hit"]=love.audio.newSource("sounds/paddle_hit.wav", 'static'),
        ["score"]=love.audio.newSource("sounds/score.wav", 'static')
    }
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT, WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1Score = 0
    player2Score = 0
    servingPlayer=1
    love.window.setTitle("Pong")

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH-15,VIRTUAL_HEIGHT-30,5,20)
    ball=Ball(VIRTUAL_WIDTH / 2 - 2,VIRTUAL_HEIGHT / 2 - 2,5,5)
    ball.dx = math.abs(ball.dx)
    

    
end
function love.resize(w,h)
    push:resize(w,h)
end

function love.update(dt)
    -- player 1 movement control
    if love.keyboard.isDown("w") then 
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
    --  player 2 movement control
    if love.keyboard.isDown("up") then 
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)

        --#################
        -- checking balls position and adjusting it relatively to xy and paddles
        if ball:collides(player1) then
            ball.x = player1.x + player1.width
            ball.dx = -ball.dx * 1.5
            if ball.dy <= 0 then
                ball.dy = -math.random(1,150)
            else
                ball.dy = math.random(1,150)
            end
            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.x = player2.x - ball.width
            ball.dx = -ball.dx * 1.5
            if ball.dy <= 0 then
                ball.dy = -math.random(1,150)
            else
                ball.dy = math.random(1,150)
            end
            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        elseif ball.y >= VIRTUAL_HEIGHT-ball.height then
            ball.y = VIRTUAL_HEIGHT-ball.height
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        -- ###############
        -- scoring system
        if ball.x <= -ball.width then
            player2Score = player2Score + 1
            servingPlayer = 1
            sounds['score']:play()
            if player2Score == 10 then
                gameState = 'done'
                winningPlayer = 2
            else
                gameState = "serve"
                ball:reset()
            end
        elseif ball.x >= VIRTUAL_WIDTH then
            player1Score = player1Score + 1
            servingPlayer = 2
            sounds['score']:play()
            if player1Score == 10 then
                gameState = 'done'
                winningPlayer = 1
            else
                gameState = "serve"
                ball:reset()
            end
        end
    end
    if gameState == 'serve' then
        if servingPlayer == 1 then
            ball.dx = math.abs(ball.dx)
        else
            if ball.dx > 0 then
                ball.dx = -ball.dx
            end
        end
    end
    player1:update(dt)
    player2:update(dt)
end


function love.keypressed(key)
    if key == "return" or key=="enter" then
        
        if gameState=="start" then
            gameState = "serve"
        elseif gameState=='serve' then
            gameState = "play"
        elseif gameState=='done' then 
            player1Score=0
            player2Score=0
            ball:reset()
            gameState='serve'
        end
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    push:apply("start")
    love.graphics.clear(40/255, 45/255, 52/255,1)
    
    love.graphics.setFont(smallFont)
    printText = "Pong Start"
    if gameState == "play" then 
        printText="Pong Play"
                     -- alignment mode, can be 'center', 'left', or 'right'
    elseif gameState== 'serve' then
        printText = "Player "..tostring(servingPlayer).."'s serve! Ready?'"
    end
        if gameState=='done' then
            love.graphics.setFont(winFont)
            love.graphics.printf(
                "Player "..tostring(winningPlayer).." wins!",
                0,
                6,
                VIRTUAL_WIDTH,
                'center'
            )
            love.graphics.printf(
                "Press Enter to Play Again",
                0, VIRTUAL_HEIGHT/4,VIRTUAL_WIDTH, 'center'           
        )
        else 
            love.graphics.printf(
                printText,          -- text to render
                0,                      -- starting X (0 since we're going to center it based on width)
                6,  -- starting Y (halfway down the screen)
                VIRTUAL_WIDTH,           -- number of pixels to center within (the entire screen here)
                'center')  
        end
            

    --printing out scores for both users
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
    
    --player 1
    -- love.graphics.rectangle('fill', 10, player1Y, 5, 20)
    player1:render()
    --player 2
    player2:render()
    --ball
    ball:render()

    displayFPS()
    push:apply('end')
end
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,1,0,1)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end