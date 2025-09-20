try(destroyDialog GoskinCubeRollout) catch()

-- Constant Definitions
global SMALL_BUTTON_WIDTH = 40
global SMALL_BUTTON_HEIGHT = 17
global CONTROL_SPACING = 5
global UNDO_GENERATE_SINGLE = "Generate Single Cube"
global UNDO_GENERATE_BATCH = "Batch Generate Cubes"

-- Global Capture Target
global capturedTarget

-- Preset Storage
global cubePresets = #(
    #("DMC5", #(
        #("Dante Body", #(
            "LOD_1_Group_0_Sub_1__m_coat",
            "LOD_1_Group_0_Sub_2__m_coat_parts",
            "LOD_1_Group_0_Sub_3__m_button",
            "LOD_1_Group_0_Sub_4__m_body",
            "LOD_1_Group_0_Sub_5__m_hand",
            "LOD_1_Group_0_Sub_6__m_leg",
            "LOD_1_Group_1_Sub_2__m_glove"
        ))
    ))
)

-- String Escaping Helper Function
fn EscapeString s =
(
    s = substituteString s "\\" "\\\\"
    s = substituteString s "\"" "\\\""
    s = substituteString s "\n" "\\n"
    s = substituteString s "\r" "\\r"
    s
)

-- Get Script Path
fn GetScriptPath =
(
    local path = ""
    try
    (
        path = getSourceFileName()
    )
    catch
    (
        path = getDir #scripts + "\\GoskinCubeTool.ms"
    )
    path
)

-- Save as JSON Format
fn SaveAsJson baseDir =
(
    local jsonPath = baseDir + "CubePresets.json"
    fn GameToJson game =
    (
        local gameName = EscapeString game[1]
        local presetsStr = "["
        for i = 1 to game[2].count do
        (
            local preset = game[2][i]
            local presetName = EscapeString preset[1]
            local namesStr = "["
            for j = 1 to preset[2].count do
            (
                namesStr += "\"" + EscapeString preset[2][j] + "\""
                if j < preset[2].count do namesStr += ","
            )
            namesStr += "]"
            presetsStr += "{\"name\":\"" + presetName + "\",\"items\":" + namesStr + "}"
            if i < game[2].count do presetsStr += ","
        )
        presetsStr += "]"
        return "{\"game\":\"" + gameName + "\",\"presets\":" + presetsStr + "}"
    )
    local jsonText = "["
    for i = 1 to cubePresets.count do
    (
        jsonText += GameToJson cubePresets[i]
        if i < cubePresets.count do jsonText += ","
    )
    jsonText += "]"
    try
    (
        local f = createFile jsonPath
        format "%\n" jsonText to:f
        close f
        return true
    )
    catch
    (
        messageBox "Failed to save JSON preset file!"
        return false
    )
)

-- Save as MaxScript Format
fn SaveAsMaxScript baseDir =
(
    local msPath = baseDir + "CubePresets.ms"
    fn GameToMs game =
    (
        local presetsStr = "#(\n"
        for i = 1 to game[2].count do
        (
            local preset = game[2][i]
            local namesStr = "#(\n"
            for j = 1 to preset[2].count do
            (
                namesStr += "\"" + EscapeString preset[2][j] + "\""
                if j < preset[2].count do namesStr += ",\n"
            )
            namesStr += "\n)"
            presetsStr += "#(\"" + EscapeString preset[1] + "\", " + namesStr + ")"
            if i < game[2].count do presetsStr += ",\n"
        )
        presetsStr += "\n)"
        return "#(\"" + EscapeString game[1] + "\", " + presetsStr + ")"
    )
    local msText = "global cubePresets\n"
    msText += "cubePresets = #(\n"
    for i = 1 to cubePresets.count do
    (
        msText += GameToMs cubePresets[i]
        if i < cubePresets.count do msText += ",\n"
    )
    msText += "\n)\n"
    try
    (
        local f = createFile msPath
        format "%\n" msText to:f
        close f
        return true
    )
    catch
    (
        messageBox "Failed to save MaxScript preset file!"
        return false
    )
)

-- Save Presets to Files
fn SaveCubePresetsToFiles =
(
    local scriptPath = GetScriptPath()
    local baseDir = getFilenamePath scriptPath
    local jsonSuccess = SaveAsJson baseDir
    local msSuccess = SaveAsMaxScript baseDir
    return jsonSuccess and msSuccess
)

-- Load Presets from Files
fn LoadCubePresetsFromFiles =
(
    local scriptPath = GetScriptPath()
    local baseDir = getFilenamePath scriptPath
    local msPath = baseDir + "CubePresets.ms"
    if doesFileExist msPath then
    (
        try
        (
            fileIn msPath
            return true
        )
        catch
        (
            messageBox "Failed to load preset file!"
            return false
        )
    )
    return false
)

-- Preset Name Input Dialog
fn PromptPresetName prompt defaultText =
(
    try
    (
        local gs = getString prompt defaultText
        if gs != undefined then return gs
    )
    catch()
    try
    (
        local win = dotNetObject "System.Windows.Forms.Form"
        win.Text = "Enter Preset Name"
        win.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").FixedDialog
        win.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").CenterScreen
        win.ClientSize = dotNetObject "System.Drawing.Size" 300 100
        win.MaximizeBox = false
        win.MinimizeBox = false
        win.ShowInTaskbar = false
        win.TopMost = true
        local lbl = dotNetObject "System.Windows.Forms.Label"
        lbl.Text = prompt
        lbl.Bounds = dotNetObject "System.Drawing.Rectangle" 10 10 280 20
        local txt = dotNetObject "System.Windows.Forms.TextBox"
        txt.Bounds = dotNetObject "System.Drawing.Rectangle" 10 35 280 22
        txt.Text = defaultText
        local btnOk = dotNetObject "System.Windows.Forms.Button"
        btnOk.Text = "OK"
        btnOk.DialogResult = (dotNetClass "System.Windows.Forms.DialogResult").OK
        btnOk.Bounds = dotNetObject "System.Drawing.Rectangle" 130 60 75 25
        local btnCancel = dotNetObject "System.Windows.Forms.Button"
        btnCancel.Text = "Cancel"
        btnCancel.DialogResult = (dotNetClass "System.Windows.Forms.DialogResult").Cancel
        btnCancel.Bounds = dotNetObject "System.Drawing.Rectangle" 215 60 75 25
        win.Controls.AddRange #(lbl, txt, btnOk, btnCancel)
        win.AcceptButton = btnOk
        win.CancelButton = btnCancel
        local res = win.ShowDialog()
        if res == (dotNetClass "System.Windows.Forms.DialogResult").OK then
        (
            local out = txt.Text
            win.Dispose()
            return out
        )
        else
        (
            win.Dispose()
            return undefined
        )
    )
    catch
    (
        local resq = queryBox prompt
        if resq then return defaultText else return undefined
    )
)

-- String Array Join Function
fn JoinStrings arr delimiter =
(
    local result = ""
    for i = 1 to arr.count do
    (
        result += arr[i]
        if i < arr.count then result += delimiter
    )
    result
)

-- Core Function: Create Cube Only (No Refresh)
fn CreateRawCube cubeName pos =
(
    local smallCube = box length:0.001 width:0.001 height:0.001 name:cubeName
    smallCube.pos = pos
    convertToMesh smallCube
    smallCube
)

-- Core Function: Batch Process Skin (Centralized, One Refresh)
fn BatchProcessSkin cubelist target =
(
    for cube in cubelist do
    (
        local skinMod = Skin()
        addModifier cube skinMod
        try(skinOps.AddBone skinMod target 1) catch()
        
        local vCount = getNumVerts cube
        for i = 1 to vCount do
        (
            skinOps.SetVertexWeights skinMod i #(1) #(100.0)
        )
    )
)

rollout GoskinCubeRollout "Cube Generator v1.0" width:280 height:470
(
    -- Control Definitions
    label lblTargetPrompt "Current Captured Target:" pos:[10,5]
    edittext etTarget "" pos:[6,20] readonly:true
    button btnRefresh "Capture Target" pos:[10,40]  -- Fixed left position
    button btnGenerate "Gen Single Cube" pos:[10,65]  -- Fixed left position to align with above
    label lblGame "Game:" pos:[10,95]
    button btnAddGame "Add" pos:[70,93] width:SMALL_BUTTON_WIDTH height:SMALL_BUTTON_HEIGHT
    button btnRemoveGame "Del" pos:[120,93] width:SMALL_BUTTON_WIDTH height:SMALL_BUTTON_HEIGHT
    dropdownlist ddlGames items:(for g in cubePresets collect g[1]) pos:[10,115]
    label lblPreset "Preset:" pos:[10,145]
    button btnSavePreset "Save" pos:[70,143] width:SMALL_BUTTON_WIDTH height:SMALL_BUTTON_HEIGHT
    button btnDeletePreset "Del" pos:[120,143] width:SMALL_BUTTON_WIDTH height:SMALL_BUTTON_HEIGHT
    dropdownlist ddlPresets items:#() pos:[10,165]
    button btnWriteSelection "Write Selection" pos:[10,206]
    label lblCustom "Custom Names (One per line):" pos:[10,190]
    edittext etCustomNames "" pos:[6,230] multiline:true height:140
    button btnGeneratePreset "Batch Gen Cubes" pos:[10,375]
    label lblGenerationStatus "" pos:[10,400] width:260

    -- Resize Controls - Key fix to maintain alignment
    fn ResizeControls newWidth =
    (
        if newWidth == undefined then newWidth = 280
        local controlWidth = newWidth - 20  -- Consistent width calculation
        
        if controlWidth < 100 then controlWidth = 100
        
        -- Set all main buttons to same width and x position
        etTarget.width = controlWidth
        btnRefresh.width = controlWidth
        btnRefresh.pos.x = 10  -- Force x position to 10
        
        btnGenerate.width = controlWidth
        btnGenerate.pos.x = 10  -- Force x position to 10 to match above
        
        ddlGames.width = controlWidth
        ddlPresets.width = controlWidth
        btnWriteSelection.width = controlWidth
        btnGeneratePreset.width = controlWidth
        etCustomNames.width = controlWidth
        
        lblGenerationStatus.width = controlWidth
    )

    -- Update Preset Dropdown
    fn UpdatePresetDropdown =
    (
        local gameIndex = ddlGames.selection
        local presetItems = #("Custom")
        if gameIndex > 0 and gameIndex <= cubePresets.count then
        (
            local presets = cubePresets[gameIndex][2]
            for p in presets do append presetItems p[1]
            ddlPresets.items = presetItems
            ddlPresets.selection = 1
            etCustomNames.text = ""
        )
        else
        (
            ddlPresets.items = presetItems
            ddlPresets.selection = 1
            etCustomNames.text = ""
        )
    )

    -- Update Game Dropdown
    fn UpdateGameDropdown =
    (
        local currentSelection = ddlGames.selection
        ddlGames.items = for g in cubePresets collect g[1]
        if currentSelection > 0 and currentSelection <= ddlGames.items.count then
            ddlGames.selection = currentSelection
        else if ddlGames.items.count > 0 then
            ddlGames.selection = 1
    )

    -- Check if Game Exists
    fn IsGameExists gameName =
    (
        for g in cubePresets do if g[1] == gameName then return true
        return false
    )

    -- Add New Game
    on btnAddGame pressed do
    (
        local gameName = PromptPresetName "Enter new game name:" "New Game"
        if gameName != undefined and gameName != "" do
        (
            if IsGameExists gameName then
            (
                messageBox "This game name already exists!"
                return()
            )
            append cubePresets #(gameName, #())
            UpdateGameDropdown()
            if SaveCubePresetsToFiles() then
                messageBox ("Added new game: " + gameName)
            else
                messageBox "Game added successfully, but failed to save presets!"
        )
    )

    -- Remove Game
    on btnRemoveGame pressed do
    (
        if cubePresets.count == 0 then
        (
            messageBox "No games to delete!"
            return()
        )
        local gameIndex = ddlGames.selection
        if gameIndex == 0 or gameIndex > cubePresets.count then
        (
            messageBox "Please select a game to delete first!"
            return()
        )
        local gameName = cubePresets[gameIndex][1]
        local confirmDelete = queryBox ("Deleting the game will remove all its presets!\nAre you sure you want to delete game \"" + gameName + "\"?")
        if confirmDelete then
        (
            deleteItem cubePresets gameIndex
            UpdateGameDropdown()
            UpdatePresetDropdown()
            if SaveCubePresetsToFiles() then
                messageBox ("Deleted game: " + gameName)
            else
                messageBox "Game deleted successfully, but failed to save presets!"
        )
    )

    -- Write Current Selection
    on btnWriteSelection pressed do
    (
        if selection.count == 0 then
        (
            messageBox "Please select mesh objects to write names first!"
            return()
        )
        local selectedNames = for obj in selection collect obj.name
        etCustomNames.text = JoinStrings selectedNames "\n"
    )

    -- Capture Target
    on btnRefresh pressed do
    (
        lblGenerationStatus.text = ""
        if selection.count == 0 then
        (
            capturedTarget = undefined
            etTarget.text = "No Target Selected"
            btnRefresh.text = "Capture Target"
        )
        else
        (
            capturedTarget = selection[1]
            etTarget.text = capturedTarget.name
            btnRefresh.text = "Recapture"
        )
        -- Force repositioning after text change
        ResizeControls GoskinCubeRollout.width
    )

    -- Generate Single Cube (No Flicker)
    on btnGenerate pressed do
    (
        if capturedTarget == undefined then
        (
            messageBox "Please capture a target first!"
            return()
        )
        
        local cubeName = capturedTarget.name + "_Cube"
        local targetPos = capturedTarget.pos
        
        -- Disable Refresh
        disableSceneRedraw()
        suspendEditing()
        try
        (
            undo UNDO_GENERATE_SINGLE on
            (
                local newCube = CreateRawCube cubeName targetPos
                BatchProcessSkin #(newCube) capturedTarget
                lblGenerationStatus.text = "Generated single cube: " + cubeName
            )
        )
        catch
        (
            messageBox ("Generation failed: " + cubeName + "\nError: " + (getCurrentException() as string))
        )
        finally
        (
            -- Restore Refresh
            resumeEditing()
            enableSceneRedraw()
            -- Force Single Refresh
            redrawViews()
        )
    )

    -- Batch Generate Cubes (No Flicker)
    on btnGeneratePreset pressed do
    (
        if capturedTarget == undefined then
        (
            messageBox "Please capture a target first!"
            return()
        )
        
        local names = filterString etCustomNames.text "\n"
        if names.count == 0 then
        (
            messageBox "Please select a preset or enter custom names first!"
            return()
        )
        
        local targetPos = capturedTarget.pos
        local cubelist = #()
        
        -- Disable Refresh
        disableSceneRedraw()
        suspendEditing()
        try
        (
            undo UNDO_GENERATE_BATCH on
            (
                -- Phase 1: Batch Create Geometry
                for n in names do
                (
                    local cube = CreateRawCube n targetPos
                    append cubelist cube
                )
                
                -- Phase 2: Batch Process Skin
                BatchProcessSkin cubelist capturedTarget
                
                lblGenerationStatus.text = "Generated " + cubelist.count as string + "/" + names.count as string + " cubes"
            )
        )
        catch
        (
            messageBox ("Batch generation failed\nError: " + (getCurrentException() as string))
        )
        finally
        (
            -- Restore Refresh
            resumeEditing()
            enableSceneRedraw()
            -- Force Full Refresh
            redrawViews()
        )
    )

    -- Save Preset
    on btnSavePreset pressed do
    (
        local names = filterString etCustomNames.text "\n"
        if names.count == 0 then
        (
            messageBox "Please enter cube names to save as preset!"
            return()
        )
        local presetName = PromptPresetName "Enter preset name:" "New Preset"
        if presetName != undefined and presetName != "" do
        (
            local gameIndex = ddlGames.selection
            if gameIndex > 0 and gameIndex <= cubePresets.count then
            (
                append cubePresets[gameIndex][2] #(presetName, names)
                UpdatePresetDropdown()
                if SaveCubePresetsToFiles() then
                    messageBox ("Saved preset: " + presetName)
                else
                    messageBox "Preset added successfully, but failed to save to file!"
            )
            else
            (
                messageBox "Please select a game first!"
            )
        )
    )

    -- Delete Preset
    on btnDeletePreset pressed do
    (
        local gameIndex = ddlGames.selection
        local selPresetIndex = ddlPresets.selection
        if selPresetIndex == 1 then
        (
            messageBox "Cannot delete 'Custom' option!"
            return()
        )
        local adjustedIndex = selPresetIndex - 1
        if gameIndex == 0 or gameIndex > cubePresets.count then
        (
            messageBox "Please select a game first!"
            return()
        )
        local presets = cubePresets[gameIndex][2]
        if adjustedIndex == 0 or adjustedIndex > presets.count then
        (
            messageBox "Please select a preset first!"
            return()
        )
        local selPresetName = presets[adjustedIndex][1]
        local res = queryBox ("Confirm deletion of preset: " + selPresetName + "?")
        if res then
        (
            deleteItem presets adjustedIndex
            UpdatePresetDropdown()
            if SaveCubePresetsToFiles() then
                messageBox ("Deleted preset: " + selPresetName)
            else
                messageBox "Preset deleted successfully, but failed to save to file!"
        )
    )

    -- Game Selection Change
    on ddlGames selected i do
    (
        UpdatePresetDropdown()
    )

    -- Preset Selection Change
    on ddlPresets selected i do
    (
        if i == 1 then
            etCustomNames.text = ""
        else
        (
            local gameIndex = ddlGames.selection
            local adjustedIndex = i - 1
            if gameIndex > 0 and gameIndex <= cubePresets.count and adjustedIndex > 0 and adjustedIndex <= cubePresets[gameIndex][2].count then
            (
                local preset = cubePresets[gameIndex][2][adjustedIndex]
                etCustomNames.text = JoinStrings preset[2] "\n"
            )
        )
    )

    -- Window Resize
    on GoskinCubeRollout resized newSize do
    (
        ResizeControls newSize.x
    )

    -- Initialization
    on GoskinCubeRollout open do
    (
        ResizeControls GoskinCubeRollout.width
        LoadCubePresetsFromFiles()
        UpdateGameDropdown()
        if ddlGames.items.count > 0 then
        (
            ddlGames.selection = 1
            UpdatePresetDropdown()
        )
        capturedTarget = undefined
        etTarget.text = "No Target Selected"
        btnRefresh.text = "Capture Target"
        lblGenerationStatus.text = ""
    )
)

createDialog GoskinCubeRollout 200 420 style:#(#style_titlebar, #style_sysmenu, #style_resizing)
