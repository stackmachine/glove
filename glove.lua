-- Glove is a compatibility layer
-- So that you can write LOVE modules
-- That work on both 0.8.0 and 0.9.0
--
-- The local functions are named after 0.8.0
local glove = {}

-- Features
local love9 = love._version == "0.9.0"
local love8 = love._version == "0.8.0"

require "love.filesystem"
require "love.graphics"

if love9 then
  require "love.window"
end

glove.filesystem = {}
glove.window = {}
glove.graphics = {}
glove.thread = {}

-- http://www.love2d.org/wiki/love.filesystem.enumerate
local function enumerate(dir)
  if love.filesystem.enumerate then
    return love.filesystem.enumerate(dir)
  else
    return love.filesystem.getDirectoryItems(dir)
  end
end

glove.filesystem.enumerate = enumerate
glove.filesystem.getDirectoryItems = enumerate

-- http://www.love2d.org/wiki/love.filesystem.mkdir
local function mkdir(name)
  if love.filesystem.mkdir then
    return love.filesystem.mkdir(name)
  else
    return love.filesystem.createDirectory(name)
  end
end

glove.filesystem.mkdir = mkdir
glove.filesystem.createDirectory = mkdir


-- The NamedThread class provides the Love 0.8.0
-- thread interface in Love 0.9.0
local NamedThread = {}
NamedThread.__index = NamedThread

function NamedThread:init(name, filedata)
  self.thread = love.thread.newThread(filedata)
  self.name = name
end

function NamedThread:start()
  return self.thread:start()
end

function NamedThread:wait()
  return self.thread:wait()
end

function NamedThread:set(name, value)
  local channel = love.thread.getChannel(name)
  return channel:push(value) 
end

function NamedThread:peek(name)
  local channel = love.thread.getChannel(name)
  return channel:peek()
end

function NamedThread:get(name)
  if name == "error" then
    return self.thread:getError()
  end
  local channel = love.thread.getChannel(name)
  return channel:pop()
end


function NamedThread:demand(name)
  local channel = love.thread.getChannel(name)
  return channel:demand()
end

local _threads = {}

-- http://www.love2d.org/wiki/love.thread.newThread 
local function newThread(name, filedata)
  if love8 then
    return love.thread.newThread(name, filedata)
  end

  if _threads[name] then
    error("A thread with that name already exists.")
  end
  
  local thread = {}
  setmetatable(thread, NamedThread)
  thread:init(name, filedata)

  -- Mark this name as taken
  _threads[name] = true

  return thread
end

local function getThread()
  if love.thread.getThread then
    return love.thread.getThread()
  end
  local thread = {}
  setmetatable(thread, NamedThread)
  return thread
end

glove.thread.newThread = newThread
glove.thread.getThread = getThread


--glove.window.getDesktopDimension
--glove.window.getFullscreen
--glove.window.getFullscreenModes
--glove.window.getIcon
--glove.window.getMode

glove.window.getHeight = love.graphics.getHeight
glove.window.getWidth = love.graphics.getWidth

glove.graphics.getHeight = love.graphics.getHeight
glove.graphics.getWidth = love.graphics.getWidth

local function getTitle() 
  if love.window and love.window.getTitle then
    return love.window.getTitle()
  else
    return love.graphics.getCaption()
  end
end

glove.window.getTitle = getTitle
glove.graphics.getCaption = getTitle

local function setTitle(title)
  if love.window and love.window.setTitle then
    return love.window.setTitle(title)
  else
    return love.graphics.setCaption(title)
  end
end

glove.window.setTitle = setTitle
glove.graphics.setCaption = setTitle

local function getDimensions(title)
  if love.graphics.getDimensions then
    return love.graphics.getDimensions()
  else
    return love.graphics.getWidth(), love.graphics.getHeight()
  end
end

glove.window.getDimensions = getDimensions
glove.graphics.getDimensions = getDimensions


--glove.window.hasFocus
--glove.window.hasMouseFocus
--glove.window.isCreated
--glove.window.isVisible
--glove.window.setFullscreen
--glove.window.setIcon
--glove.window.setMode

return glove
