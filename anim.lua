local animation = {}
animation.__index = animation

--- Create a new animation
-- img: The image that contains the frames
-- frameW: The frame width
-- frameH: The frame height
-- delay: The delay between two frames
-- start: The starting frame for the initial animation
-- numFrames: The number of frames for the initial animation
-- returns the created animation
function newAnimation(img, frameW, frameH, delay, start, numFrames)
   local anim = {}
   anim.img = img
   anim.frames = {}
   anim.delays = {}
   anim.timer = 0
   anim.position = start
   anim.frameW = frameW
   anim.frameH = frameH
   anim.delay = delay
   anim.playing = true
   anim.speed = 1
   anim.mode = 'loop'
   anim.direction = 1
   anim.imgW = img:getWidth()
   anim.imgH = img:getHeight()
   anim.start = start
   anim.numFrames = numFrames or 1
   
   local anim =  setmetatable(anim, animation)
   anim:_setQuads(start or 1, (anim.imgW / frameW * anim.imgH / frameH))

   return anim
end

--- Set the quads for the animation
function animation:_setQuads(start, numFrames)
   local rowsize = self.imgW/self.frameW
   self.frames = {}
   self.delays = {}
   
   for i = start, (numFrames + start) do
      local row = math.floor((i-1)/rowsize)
      local column = (i-1)%rowsize
      local frame = love.graphics.newQuad(column*self.frameW, row*self.frameH, self.frameW, self.frameH, self.imgW, self.imgH)
      
      table.insert(self.frames, frame)
      table.insert(self.delays, self.delay)
   end
end

--- Change the animation start and stop frame in the given image file
function animation:setFrameRange(start, numFrames)
   self.start = start
   self.numFrames = numFrames
end

--- Update the animation
-- dt: Time that has passed since last call
function animation:update(dt)
   if not self.playing then return end
   if self.position < self.start then 
      self.position = self.start
   end
   self.timer = self.timer + dt * self.speed
   if self.timer > self.delays[self.position] then
      self.timer = self.timer - self.delays[self.position]
      self.position = self.position + self.direction
      if self.position > self.start + self.numFrames then
         if self.mode == 'loop' then
            self.position = self.start
         elseif self.mode == 'once' then
            self.position = self.position - 1
            self:stop()
         elseif self.mode == 'bounce' then
            self.direction = -1
            self.position = self.position - 1
         end
      elseif self.position < 1 and self.mode == 'bounce' then
         self.direction = 1
         self.position = self.position + 1
      elseif self.position < 1 and self.mode == 'reverse' then
         self.position = self.start + self.numFrames
      end
   end
end

--- Draw the animation
local drawq = love.graphics.drawq or love.graphics.draw
function animation:draw(...)
   return drawq(self.img, self.frames[self.position], ...)
end

--- Add a frame
-- x: The X coordinate of the frame on the original image
-- y: The Y coordinate of the frame on the original image
-- w: The width of the frame
-- h: The height of the frame
-- delay: The delay before the next frame is shown
function animation:addFrame(x, y, w, h, delay)
   local frame = love.graphics.newQuad(x, y, w, h, self.img:getWidth(), self.img:getHeight())
   table.insert(self.frames, frame)
   table.insert(self.delays, delay)
end

--- Play the animation
-- Starts it if it was stopped.
-- Basically makes sure it uses the delays
-- to switch to the next frame.
function animation:play()
   self.playing = true
end

--- Stop the animation
function animation:stop()
   self.playing = false
end

--- Reset
-- Go back to the first frame.
function animation:reset()
   return self:seek(self.start)
end

--- Seek to a frame
function animation:seek(frame)
   self.position = frame
   self.timer = 0
end

--- Get the currently shown frame
function animation:getCurrentFrame()
   return self.position
end

--- Get the number of frames
function animation:getSize()
   return #self.frames
end

--- Set the delay between frames
-- frame: Which frame to set the delay for
-- delay: The delay
function animation:setDelay(frame, delay)
   self.delays[frame] = delay
end

--- Set the speed
-- @param speed The speed to play at (1 is normal, 2 is double, etc)
function animation:setSpeed(speed)
   self.speed = speed
end

--- Get the width of the current frame
-- returns the width of the current frame
function animation:getWidth()
   return (select(3, self.frames[self.position]:getViewport()))
end

--- Get the height of the current frame
-- returns the height of the current frame
function animation:getHeight()
   return (select(4, self.frames[self.position]:getViewport()))
end

--- Set the play mode
-- 'loop' to loop it
-- 'once' to play it once
-- 'bounce' to play it, reverse it, and play it again (looping)
-- 'reverse' to change direction
function animation:setMode(mode)
   self.mode = mode
   if mode == 'reverse' then
      self.direction = -1
   end
end
