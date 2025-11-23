--[[
    Application Center - Roblox Luau Client
    
    This ModuleScript creates a dynamic application UI in Roblox
    based on configuration from the Application Center server.
    
    USAGE:
    local AppCenter = require(script.AppCenterClient)
    
    local app = AppCenter.new({
        AppId = "your_app_id_here",
        ServerUrl = "https://bulletproof.astroyds.com"
    })
    
    app:ShowToPlayer(player)
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local AppCenterClient = {}
AppCenterClient.__index = AppCenterClient

-- Configuration
local CONFIG = {
    MAX_SHORT_ANSWER_LENGTH = 300,
    MAX_MC_OPTIONS = 6,
    MAX_CHECKBOX_OPTIONS = 10,
    ANIMATION_DURATION = 0.3
}

-- Create new application instance
function AppCenterClient.new(config)
    local self = setmetatable({}, AppCenterClient)
    
    self.AppId = config.AppId
    self.ServerUrl = config.ServerUrl
    self.Config = nil
    self.Answers = {}
    
    return self
end

-- Load application configuration from server
function AppCenterClient:LoadConfig()
    local url = string.format("%s/index.php?action=getConfig&id=%s", 
        self.ServerUrl, 
        HttpService:UrlEncode(self.AppId))
    
    local success, result = pcall(function()
        return HttpService:GetAsync(url)
    end)
    
    if not success then
        warn("Failed to load application config:", result)
        return false
    end
    
    local data = HttpService:JSONDecode(result)
    
    if not data.success then
        warn("Server returned error:", data.error)
        return false
    end
    
    self.Config = data.config
    return true
end

-- Submit application to server
function AppCenterClient:SubmitApplication(userId)
    local url = string.format("%s/index.php?action=submit", self.ServerUrl)
    
    local payload = {
        app_id = self.AppId,
        user_id = userId,
        answers = self.Answers
    }
    
    local success, result = pcall(function()
        return HttpService:PostAsync(
            url,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    if not success then
        warn("Failed to submit application:", result)
        return nil
    end
    
    return HttpService:JSONDecode(result)
end

-- Create UI for player
function AppCenterClient:ShowToPlayer(player)
    -- Load config if not already loaded
    if not self.Config then
        if not self:LoadConfig() then
            return
        end
    end
    
    -- Remove existing UI
    local existingUI = player:FindFirstChild("PlayerGui"):FindFirstChild("ApplicationCenter")
    if existingUI then
        existingUI:Destroy()
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ApplicationCenter"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create main frame (glass effect background)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 700)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add UI corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    -- Add shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Create header
    self:CreateHeader(mainFrame)
    
    -- Create scrolling frame for questions
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "QuestionsScroll"
    scrollFrame.Size = UDim2.new(1, -40, 1, -180)
    scrollFrame.Position = UDim2.new(0, 20, 0, 100)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame
    
    -- Add list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 15)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame
    
    -- Create questions
    self:CreateQuestions(scrollFrame)
    
    -- Create submit button
    self:CreateSubmitButton(mainFrame, player)
    
    -- Parent to player
    screenGui.Parent = player:FindFirstChild("PlayerGui")
    
    -- Animate entrance
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, 
        TweenInfo.new(CONFIG.ANIMATION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 600, 0, 700)}
    ):Play()
end

-- Create header
function AppCenterClient:CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 80)
    header.BackgroundTransparency = 1
    header.Parent = parent
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = self.Config.app.name or "Application"
    title.TextColor3 = Color3.fromRGB(241, 245, 249)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Description
    local desc = Instance.new("TextLabel")
    desc.Name = "Description"
    desc.Size = UDim2.new(1, -40, 0, 30)
    desc.Position = UDim2.new(0, 20, 0, 50)
    desc.BackgroundTransparency = 1
    desc.Text = self.Config.app.description or ""
    desc.TextColor3 = Color3.fromRGB(148, 163, 184)
    desc.TextSize = 14
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextWrapped = true
    desc.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -60, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 28
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        parent.Parent:Destroy()
    end)
end

-- Create questions
function AppCenterClient:CreateQuestions(parent)
    local questions = self.Config.questions or {}
    
    for i, question in ipairs(questions) do
        if question.type == "multiple_choice" then
            self:CreateMultipleChoice(parent, question, i)
        elseif question.type == "short_answer" then
            self:CreateShortAnswer(parent, question, i)
        elseif question.type == "checkboxes" then
            self:CreateCheckboxes(parent, question, i)
        end
    end
end

-- Create multiple choice question
function AppCenterClient:CreateMultipleChoice(parent, question, index)
    local container = Instance.new("Frame")
    container.Name = "Question_" .. question.id
    container.Size = UDim2.new(1, -20, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    container.BorderSizePixel = 0
    container.LayoutOrder = index
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = container
    
    -- Question text
    local questionText = Instance.new("TextLabel")
    questionText.Size = UDim2.new(1, 0, 0, 0)
    questionText.AutomaticSize = Enum.AutomaticSize.Y
    questionText.BackgroundTransparency = 1
    questionText.Text = string.format("Q%d. %s", index, question.text)
    questionText.TextColor3 = Color3.fromRGB(241, 245, 249)
    questionText.TextSize = 16
    questionText.Font = Enum.Font.GothamSemibold
    questionText.TextXAlignment = Enum.TextXAlignment.Left
    questionText.TextWrapped = true
    questionText.Parent = container
    
    -- Options container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 30)
    optionsFrame.AutomaticSize = Enum.AutomaticSize.Y
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.Parent = container
    
    local optionsList = Instance.new("UIListLayout")
    optionsList.Padding = UDim.new(0, 8)
    optionsList.Parent = optionsFrame
    
    -- Create option buttons
    for _, option in ipairs(question.options or {}) do
        self:CreateOptionButton(optionsFrame, question.id, option)
    end
end

-- Create option button for multiple choice
function AppCenterClient:CreateOptionButton(parent, questionId, option)
    local btn = Instance.new("TextButton")
    btn.Name = "Option_" .. option.id
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    btn.Text = option.text
    btn.TextColor3 = Color3.fromRGB(203, 213, 225)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        -- Deselect other options
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
            end
        end
        
        -- Select this option
        btn.BackgroundColor3 = Color3.fromRGB(255, 75, 110)
        self.Answers[questionId] = option.id
    end)
end

-- Create short answer question
function AppCenterClient:CreateShortAnswer(parent, question, index)
    local container = Instance.new("Frame")
    container.Name = "Question_" .. question.id
    container.Size = UDim2.new(1, -20, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    container.BorderSizePixel = 0
    container.LayoutOrder = index
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = container
    
    -- Question text
    local questionText = Instance.new("TextLabel")
    questionText.Size = UDim2.new(1, 0, 0, 0)
    questionText.AutomaticSize = Enum.AutomaticSize.Y
    questionText.BackgroundTransparency = 1
    questionText.Text = string.format("Q%d. %s", index, question.text)
    questionText.TextColor3 = Color3.fromRGB(241, 245, 249)
    questionText.TextSize = 16
    questionText.Font = Enum.Font.GothamSemibold
    questionText.TextXAlignment = Enum.TextXAlignment.Left
    questionText.TextWrapped = true
    questionText.Parent = container
    
    -- Text box
    local textBox = Instance.new("TextBox")
    textBox.Name = "AnswerBox"
    textBox.Size = UDim2.new(1, 0, 0, 100)
    textBox.Position = UDim2.new(0, 0, 0, 30)
    textBox.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    textBox.PlaceholderText = "Enter your answer here..."
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(241, 245, 249)
    textBox.PlaceholderColor3 = Color3.fromRGB(100, 116, 139)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.TextWrapped = true
    textBox.MultiLine = true
    textBox.ClearTextOnFocus = false
    textBox.Parent = container
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 8)
    textBoxCorner.Parent = textBox
    
    local textBoxPadding = Instance.new("UIPadding")
    textBoxPadding.PaddingTop = UDim.new(0, 8)
    textBoxPadding.PaddingBottom = UDim.new(0, 8)
    textBoxPadding.PaddingLeft = UDim.new(0, 8)
    textBoxPadding.PaddingRight = UDim.new(0, 8)
    textBoxPadding.Parent = textBox
    
    -- Character counter
    local counter = Instance.new("TextLabel")
    counter.Name = "CharCounter"
    counter.Size = UDim2.new(1, 0, 0, 20)
    counter.Position = UDim2.new(0, 0, 0, 135)
    counter.BackgroundTransparency = 1
    counter.Text = string.format("0/%d", question.max_length or CONFIG.MAX_SHORT_ANSWER_LENGTH)
    counter.TextColor3 = Color3.fromRGB(148, 163, 184)
    counter.TextSize = 12
    counter.Font = Enum.Font.Gotham
    counter.TextXAlignment = Enum.TextXAlignment.Right
    counter.Parent = container
    
    -- Update answer and counter
    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = textBox.Text
        local maxLen = question.max_length or CONFIG.MAX_SHORT_ANSWER_LENGTH
        
        if #text > maxLen then
            textBox.Text = string.sub(text, 1, maxLen)
            text = textBox.Text
        end
        
        counter.Text = string.format("%d/%d", #text, maxLen)
        self.Answers[question.id] = text
    end)
end

-- Create checkboxes question
function AppCenterClient:CreateCheckboxes(parent, question, index)
    local container = Instance.new("Frame")
    container.Name = "Question_" .. question.id
    container.Size = UDim2.new(1, -20, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    container.BorderSizePixel = 0
    container.LayoutOrder = index
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = container
    
    -- Question text
    local questionText = Instance.new("TextLabel")
    questionText.Size = UDim2.new(1, 0, 0, 0)
    questionText.AutomaticSize = Enum.AutomaticSize.Y
    questionText.BackgroundTransparency = 1
    questionText.Text = string.format("Q%d. %s (Select all that apply)", index, question.text)
    questionText.TextColor3 = Color3.fromRGB(241, 245, 249)
    questionText.TextSize = 16
    questionText.Font = Enum.Font.GothamSemibold
    questionText.TextXAlignment = Enum.TextXAlignment.Left
    questionText.TextWrapped = true
    questionText.Parent = container
    
    -- Options container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 30)
    optionsFrame.AutomaticSize = Enum.AutomaticSize.Y
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.Parent = container
    
    local optionsList = Instance.new("UIListLayout")
    optionsList.Padding = UDim.new(0, 8)
    optionsList.Parent = optionsFrame
    
    -- Initialize answers array for this question
    self.Answers[question.id] = {}
    
    -- Create checkbox options
    for _, option in ipairs(question.options or {}) do
        self:CreateCheckbox(optionsFrame, question.id, option)
    end
end

-- Create checkbox option
function AppCenterClient:CreateCheckbox(parent, questionId, option)
    local btn = Instance.new("TextButton")
    btn.Name = "Checkbox_" .. option.id
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    btn.Text = "☐ " .. option.text
    btn.TextColor3 = Color3.fromRGB(203, 213, 225)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 12)
    btnPadding.Parent = btn
    
    local isChecked = false
    
    btn.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        
        if isChecked then
            btn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
            btn.Text = "☑ " .. option.text
            table.insert(self.Answers[questionId], option.id)
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
            btn.Text = "☐ " .. option.text
            
            -- Remove from answers
            for i, id in ipairs(self.Answers[questionId]) do
                if id == option.id then
                    table.remove(self.Answers[questionId], i)
                    break
                end
            end
        end
    end)
end

-- Create submit button
function AppCenterClient:CreateSubmitButton(parent, player)
    local submitBtn = Instance.new("TextButton")
    submitBtn.Name = "SubmitButton"
    submitBtn.Size = UDim2.new(1, -40, 0, 50)
    submitBtn.Position = UDim2.new(0, 20, 1, -70)
    submitBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 110)
    submitBtn.Text = "Submit Application"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextSize = 18
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = parent
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 25)
    submitCorner.Parent = submitBtn
    
    submitBtn.MouseButton1Click:Connect(function()
        submitBtn.Text = "Submitting..."
        submitBtn.BackgroundColor3 = Color3.fromRGB(100, 116, 139)
        
        local result = self:SubmitApplication(player.UserId)
        
        if result and result.success then
            if result.passed then
                submitBtn.Text = "✓ Application Accepted!"
                submitBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
            else
                submitBtn.Text = "✗ Application Rejected"
                submitBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
            end
            
            wait(3)
            parent.Parent:Destroy()
        else
            submitBtn.Text = "Failed - Try Again"
            submitBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
            
            wait(2)
            submitBtn.Text = "Submit Application"
            submitBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 110)
        end
    end)
end

return AppCenterClient
