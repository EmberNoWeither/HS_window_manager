-- 使用【Option+Q】在不同屏幕之间移动鼠标
hs.hotkey.bind({'option'}, 'Q', function()
    local screen = hs.mouse.getCurrentScreen()
    local nextScreen = screen:next()
    local rect = nextScreen:fullFrame()
    local center = hs.geometry.rectMidPoint(rect)
    hs.mouse.absolutePosition(center)
end)
  
-- 使用【Option+W】在不同屏幕之间移动窗口
hs.hotkey.bind({'option'}, 'W', function()
    -- get the focused window
    local win = hs.window.focusedWindow()
    -- get the screen where the focused window is displayed, a.k.a. current screen
    local screen = win:screen()
    -- compute the unitRect of the focused window relative to the current screen
    -- and move the window to the next screen setting the same unitRect 
    win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
end)

-- 使用【Option+F】切换当前活动窗口的全屏状态
hs.hotkey.bind({'option'}, 'F', function()
    local win = hs.window.focusedWindow()
    if win then
        win:toggleFullScreen()
    end
end)

-- 使用【Option+Shift+F】将当前活动窗口移动到下一个屏幕，全屏并切换到该窗口
hs.hotkey.bind({'option', 'shift'}, 'F', function()
    local win = hs.window.focusedWindow()
    if win then
        local screen = win:screen()
        local nextScreen = screen:next()
        
        -- 函数：将窗口移动到指定屏幕并全屏
        local function moveAndFullScreen(window, targetScreen)
            -- 如果窗口当前是全屏，先退出全屏
            if window:isFullScreen() then
                window:setFullScreen(false)
            end
            
            -- 等待窗口退出全屏（如果需要）
            hs.timer.waitUntil(
                function() return not window:isFullScreen() end,
                function()
                    -- 移动窗口到目标屏幕
                    window:moveToScreen(targetScreen)
                    -- 等待窗口移动完成
                    hs.timer.doAfter(1, function()
                        -- 聚焦窗口并尝试设置全屏
                        window:focus()
                        local attempts = 0
                        local function attemptFullScreen()
                            attempts = attempts + 1
                            window:setFullScreen(true)
                            hs.timer.doAfter(1, function()
                                if not window:isFullScreen() and attempts < 3 then
                                    attemptFullScreen()
                                else
                                    window:focus()
                                end
                            end)
                        end
                        attemptFullScreen()
                    end)
                end,
                0.1 -- 检查间隔
            )
        end

        -- 检查下一个屏幕是否有全屏窗口
        local nextScreenFullScreenWin = nil
        for _, w in ipairs(hs.window.visibleWindows()) do
            if w:screen() == nextScreen and w:isFullScreen() then
                nextScreenFullScreenWin = w
                break
            end
        end

        if nextScreenFullScreenWin then
            -- 如果下一个屏幕有全屏窗口，先将其退出全屏
            nextScreenFullScreenWin:setFullScreen(false)
            hs.timer.doAfter(1, function()
                moveAndFullScreen(win, nextScreen)
            end)
        else
            -- 如果下一个屏幕没有全屏窗口，直接移动并全屏
            moveAndFullScreen(win, nextScreen)
        end
    end
end)