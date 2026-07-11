--[[
     _      ___         ____  ______
    | | /| / (_)__  ___/ / / / /  _/
    | |/ |/ / / _ \/ _  / /_/ // /  
    |__/|__/_/_//_/\_,_/\____/___/
    
    v1.6.65  |  2026-07-01  |  Roblox UI Library for scripts
    Chart Extension - FTGS Coding Style
    
    Author: Footagesus (Footages, .ftgs, oftgs)
    Github: https://github.com/Footagesus/WindUI
    License: MIT
]]

local Chart = {}
Chart.New = nil
Chart.Init = nil

function Chart.Init(New, WindUI)
  Chart.New = New
  return Chart.New
end

function Chart.Create(cfg, parent, WindUI)
  local title = cfg.Title or "Chart"
  local height = cfg.Height or 150
  local lineColor = cfg.LineColor or Color3.fromRGB(100, 200, 255)
  
  local chartObj = {
    Title = title,
    Height = height,
    LineColor = lineColor,
    Data = {},
    Bars = {},
    Frame = nil,
    Canvas = nil,
  }
  
  -- Main Chart Frame
  chartObj.Frame = Chart.New("Frame", {
    Size = UDim2.new(1, 0, 0, height),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.95,
    BorderSizePixel = 0,
  }, parent)
  
  -- Title Label
  local titleLabel = Chart.New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.new(0, 10, 0, 5),
    BackgroundTransparency = 1,
    Text = title,
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
  }, chartObj.Frame)
  
  -- Canvas for drawing bars
  chartObj.Canvas = Chart.New("Frame", {
    Size = UDim2.new(1, -20, 1, -40),
    Position = UDim2.new(0, 10, 0, 30),
    BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
    BorderSizePixel = 1,
    BorderColor3 = Color3.new(0.2, 0.2, 0.2),
  }, chartObj.Frame)
  
  -- Grid Lines
  for i = 1, 4 do
    Chart.New("Frame", {
      Size = UDim2.new(1, 0, 0, 1),
      Position = UDim2.new(0, 0, 0, (height - 40) / 4 * i),
      BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
      BorderSizePixel = 0,
      BackgroundTransparency = 0.7,
    }, chartObj.Canvas)
  end
  
  function chartObj:SetData(data)
    self.Data = data
    self:Render()
    return self
  end
  
  function chartObj:Render()
    -- Clear existing bars
    for _, bar in ipairs(self.Bars) do
      bar:Destroy()
    end
    self.Bars = {}
    
    if #self.Data == 0 then return end
    
    -- Calculate max value for scaling
    local maxVal = math.max(unpack(self.Data))
    if maxVal == 0 then maxVal = 1 end
    
    local barWidth = self.Canvas.AbsoluteSize.X / #self.Data
    local maxHeight = self.Canvas.AbsoluteSize.Y
    
    -- Draw bars
    for i, val in ipairs(self.Data) do
      local barHeight = (val / maxVal) * maxHeight
      
      local bar = Chart.New("Frame", {
        Size = UDim2.new(0, math.max(barWidth - 4, 2), 0, barHeight),
        Position = UDim2.new(0, (i - 1) * barWidth + 2, 1, -barHeight),
        BackgroundColor3 = self.LineColor,
        BorderSizePixel = 0,
      }, self.Canvas)
      
      table.insert(self.Bars, bar)
    end
  end
  
  function chartObj:SetLineColor(color)
    self.LineColor = color
    self:Render()
    return self
  end
  
  function chartObj:SetTitle(newTitle)
    self.Title = newTitle
    titleLabel.Text = newTitle
    return self
  end
  
  function chartObj:SetHeight(newHeight)
    self.Height = newHeight
    self.Frame.Size = UDim2.new(1, 0, 0, newHeight)
    self.Canvas.Size = UDim2.new(1, -20, 1, -40)
    self:Render()
    return self
  end
  
  return chartObj
end

return Chart
