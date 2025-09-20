try(destroyDialog GoskinCubeRollout) catch()

-- 常量定义
global SMALL_BUTTON_WIDTH = 40
global SMALL_BUTTON_HEIGHT = 17
global CONTROL_SPACING = 5
global UNDO_GENERATE_SINGLE = "生成单个小方块"
global UNDO_GENERATE_BATCH = "批量生成小方块"

-- 捕捉目标设为全局
global capturedTarget

-- 预设存储
global cubePresets = #(
    #("DMC5", #(
        #("但丁人形-身体", #(
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

-- 字符串转义辅助函数
fn EscapeString s =
(
    s = substituteString s "\\" "\\\\"
    s = substituteString s "\"" "\\\""
    s = substituteString s "\n" "\\n"
    s = substituteString s "\r" "\\r"
    s
)

-- 获取脚本路径
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

-- 保存为JSON格式
fn SaveAsJson baseDir =
(
    local jsonPath = baseDir + "小方块预设.json"
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
        messageBox "保存JSON预设文件失败！"
        return false
    )
)

-- 保存为MaxScript格式
fn SaveAsMaxScript baseDir =
(
    local msPath = baseDir + "小方块预设.ms"
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
        messageBox "保存MS预设文件失败！"
        return false
    )
)

-- 保存预设到文件
fn SaveCubePresetsToFiles =
(
    local scriptPath = GetScriptPath()
    local baseDir = getFilenamePath scriptPath
    local jsonSuccess = SaveAsJson baseDir
    local msSuccess = SaveAsMaxScript baseDir
    return jsonSuccess and msSuccess
)

-- 从文件加载预设
fn LoadCubePresetsFromFiles =
(
    local scriptPath = GetScriptPath()
    local baseDir = getFilenamePath scriptPath
    local msPath = baseDir + "小方块预设.ms"
    if doesFileExist msPath then
    (
        try
        (
            fileIn msPath
            return true
        )
        catch
        (
            messageBox "加载预设文件失败！"
            return false
        )
    )
    return false
)

-- 预设名称输入弹窗
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
        win.Text = "输入预设名称"
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
        btnOk.Text = "确定"
        btnOk.DialogResult = (dotNetClass "System.Windows.Forms.DialogResult").OK
        btnOk.Bounds = dotNetObject "System.Drawing.Rectangle" 130 60 75 25
        local btnCancel = dotNetObject "System.Windows.Forms.Button"
        btnCancel.Text = "取消"
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

-- 字符串数组连接函数
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

-- 核心函数：仅创建方块（无任何刷新操作）
fn CreateRawCube cubeName pos =
(
    local smallCube = box length:0.001 width:0.001 height:0.001 name:cubeName
    smallCube.pos = pos
    convertToMesh smallCube
    smallCube
)

-- 核心函数：批量处理蒙皮（集中处理，一次刷新）
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

rollout GoskinCubeRollout "小方块生成器" width:280 height:470
(
    -- 控件定义
    label lblTargetPrompt "当前已捕捉目标：" pos:[10,5]
    edittext etTarget "" pos:[6,20] readonly:true
    button btnRefresh "捕捉目标" pos:[10,40]
    button btnGenerate "生成单个小方块" pos:[10,65]
    label lblGame "选择游戏:" pos:[10,95]
    button btnAddGame "新增" pos:[75,93] width:SMALL_BUTTON_WIDTH height:SMALL_BUTTON_HEIGHT
    button btnRemoveGame "删除" pos:[120,93] width:SMALL_BUTTON_WIDTH height:SMALL_BUTTON_HEIGHT
    dropdownlist ddlGames items:(for g in cubePresets collect g[1]) pos:[10,115]
    label lblPreset "选择预设:" pos:[10,145]
    button btnSavePreset "保存" pos:[75,143] width:SMALL_BUTTON_WIDTH height:SMALL_BUTTON_HEIGHT
    button btnDeletePreset "删除" pos:[120,143] width:SMALL_BUTTON_WIDTH height:SMALL_BUTTON_HEIGHT
    dropdownlist ddlPresets items:#() pos:[10,165]
    button btnWriteSelection "一键写入当前选择" pos:[10,206]
    label lblCustom "自定义名称(每行一个):" pos:[10,190]
    edittext etCustomNames "" pos:[6,230] multiline:true height:140
    button btnGeneratePreset "批量生成小方块" pos:[10,375]
    -- 修复1：文字提示设为左对齐，初始宽度设为260（留足左右边距），确保完整显示
    label lblGenerationStatus "" pos:[10,400] width:260

    -- 调整控件大小（关键修复：单独处理文字提示宽度，避免被压缩）
    fn ResizeControls newWidth =
    (
        if newWidth == undefined then newWidth = 280
        local controlWidth = newWidth - 20  -- 普通控件宽度（左右留10px边距）
        local statusWidth = newWidth - 20    -- 文字提示宽度（与普通控件同宽，确保完整显示）
        
        if controlWidth < 100 then controlWidth = 100
        if statusWidth < 100 then statusWidth = 100  -- 防止窗口过小导致文字被截断
        
        -- 普通控件宽度设置
        etTarget.width = controlWidth
        btnRefresh.width = controlWidth
        btnGenerate.width = controlWidth
        ddlGames.width = controlWidth
        ddlPresets.width = controlWidth
        btnWriteSelection.width = controlWidth
        btnGeneratePreset.width = controlWidth
        etCustomNames.width = controlWidth
        
        -- 修复2：单独设置文字提示宽度，确保左对齐且不被截断
        lblGenerationStatus.width = statusWidth
    )

    -- 刷新预设下拉框
    fn UpdatePresetDropdown =
    (
        local gameIndex = ddlGames.selection
        local presetItems = #("自定义")
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

    -- 刷新游戏下拉框
    fn UpdateGameDropdown =
    (
        local currentSelection = ddlGames.selection
        ddlGames.items = for g in cubePresets collect g[1]
        if currentSelection > 0 and currentSelection <= ddlGames.items.count then
            ddlGames.selection = currentSelection
        else if ddlGames.items.count > 0 then
            ddlGames.selection = 1
    )

    -- 检查游戏名称是否存在
    fn IsGameExists gameName =
    (
        for g in cubePresets do if g[1] == gameName then return true
        return false
    )

    -- 新增游戏
    on btnAddGame pressed do
    (
        local gameName = PromptPresetName "请输入新游戏名称：" "新游戏"
        if gameName != undefined and gameName != "" do
        (
            if IsGameExists gameName then
            (
                messageBox "该游戏名称已存在！"
                return()
            )
            append cubePresets #(gameName, #())
            UpdateGameDropdown()
            if SaveCubePresetsToFiles() then
                messageBox ("已添加新游戏: " + gameName)
            else
                messageBox "添加游戏成功，但保存预设失败！"
        )
    )

    -- 删除游戏
    on btnRemoveGame pressed do
    (
        if cubePresets.count == 0 then
        (
            messageBox "没有可删除的游戏！"
            return()
        )
        local gameIndex = ddlGames.selection
        if gameIndex == 0 or gameIndex > cubePresets.count then
        (
            messageBox "请先选择要删除的游戏！"
            return()
        )
        local gameName = cubePresets[gameIndex][1]
        local confirmDelete = queryBox ("删除了整个游戏都没了嗷！考虑清楚！\n确定要删除游戏 \"" + gameName + "\" 吗？")
        if confirmDelete then
        (
            deleteItem cubePresets gameIndex
            UpdateGameDropdown()
            UpdatePresetDropdown()
            if SaveCubePresetsToFiles() then
                messageBox ("已删除游戏: " + gameName)
            else
                messageBox "删除游戏成功，但保存预设失败！"
        )
    )

    -- 写入当前选择
    on btnWriteSelection pressed do
    (
        if selection.count == 0 then
        (
            messageBox "请先选择要写入名称的网格对象！"
            return()
        )
        local selectedNames = for obj in selection collect obj.name
        etCustomNames.text = JoinStrings selectedNames "\n"
    )

    -- 捕捉目标
    on btnRefresh pressed do
    (
        lblGenerationStatus.text = ""
        if selection.count == 0 then
        (
            capturedTarget = undefined
            etTarget.text = "未选择目标"
            btnRefresh.text = "捕捉目标"
        )
        else
        (
            capturedTarget = selection[1]
            etTarget.text = capturedTarget.name
            btnRefresh.text = "重新捕捉"
        )
        -- 按钮文字变化后，重新应用宽度设置
        ResizeControls GoskinCubeRollout.width
    )

    -- 生成单个小方块（无闪烁版）
    on btnGenerate pressed do
    (
        if capturedTarget == undefined then
        (
            messageBox "请先捕捉目标！"
            return()
        )
        
        local cubeName = capturedTarget.name + "_Cube"
        local targetPos = capturedTarget.pos
        
        -- 三重锁死刷新
        disableSceneRedraw()
        suspendEditing()
        try
        (
            undo UNDO_GENERATE_SINGLE on
            (
                local newCube = CreateRawCube cubeName targetPos
                BatchProcessSkin #(newCube) capturedTarget
                lblGenerationStatus.text = "已生成单个小方块: " + cubeName
            )
        )
        catch
        (
            messageBox ("生成失败: " + cubeName + "\n错误: " + (getCurrentException() as string))
        )
        finally
        (
            -- 恢复刷新
            resumeEditing()
            enableSceneRedraw()
            -- 强制单次刷新
            redrawViews()
        )
    )

    -- 批量生成小方块（终极无闪烁版）
    on btnGeneratePreset pressed do
    (
        if capturedTarget == undefined then
        (
            messageBox "请先捕捉目标！"
            return()
        )
        
        local names = filterString etCustomNames.text "\n"
        if names.count == 0 then
        (
            messageBox "请先选择预设或输入自定义名称！"
            return()
        )
        
        local targetPos = capturedTarget.pos
        local cubelist = #()
        
        -- 三重锁死刷新（全程无任何中间刷新）
        disableSceneRedraw()
        suspendEditing()
        try
        (
            undo UNDO_GENERATE_BATCH on
            (
                -- 第一阶段：纯批量创建几何体（无任何修改器）
                for n in names do
                (
                    local cube = CreateRawCube n targetPos
                    append cubelist cube
                )
                
                -- 第二阶段：集中处理所有蒙皮（一次性完成）
                BatchProcessSkin cubelist capturedTarget
                
                lblGenerationStatus.text = "已生成 " + cubelist.count as string + "/" + names.count as string + " 个小方块"
            )
        )
        catch
        (
            messageBox ("批量生成失败\n错误: " + (getCurrentException() as string))
        )
        finally
        (
            -- 恢复刷新机制
            resumeEditing()
            enableSceneRedraw()
            -- 强制一次完整刷新
            redrawViews()
        )
    )

    -- 保存预设
    on btnSavePreset pressed do
    (
        local names = filterString etCustomNames.text "\n"
        if names.count == 0 then
        (
            messageBox "请输入小方块名称才能保存预设！"
            return()
        )
        local presetName = PromptPresetName "请输入预设名称：" "新预设"
        if presetName != undefined and presetName != "" do
        (
            local gameIndex = ddlGames.selection
            if gameIndex > 0 and gameIndex <= cubePresets.count then
            (
                append cubePresets[gameIndex][2] #(presetName, names)
                UpdatePresetDropdown()
                if SaveCubePresetsToFiles() then
                    messageBox ("已保存预设: " + presetName)
                else
                    messageBox "预设已添加，但保存到文件失败！"
            )
            else
            (
                messageBox "请先选择一个游戏！"
            )
        )
    )

    -- 删除预设
    on btnDeletePreset pressed do
    (
        local gameIndex = ddlGames.selection
        local selPresetIndex = ddlPresets.selection
        if selPresetIndex == 1 then
        (
            messageBox "无法删除'自定义'选项！"
            return()
        )
        local adjustedIndex = selPresetIndex - 1
        if gameIndex == 0 or gameIndex > cubePresets.count then
        (
            messageBox "请先选择一个游戏！"
            return()
        )
        local presets = cubePresets[gameIndex][2]
        if adjustedIndex == 0 or adjustedIndex > presets.count then
        (
            messageBox "请先选择一个预设！"
            return()
        )
        local selPresetName = presets[adjustedIndex][1]
        local res = queryBox ("确认删除预设: " + selPresetName + " ?")
        if res then
        (
            deleteItem presets adjustedIndex
            UpdatePresetDropdown()
            if SaveCubePresetsToFiles() then
                messageBox ("已删除预设: " + selPresetName)
            else
                messageBox "预设已删除，但保存到文件失败！"
        )
    )

    -- 游戏选择变更
    on ddlGames selected i do
    (
        UpdatePresetDropdown()
    )

    -- 预设选择变更
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

    -- 窗口大小改变
    on GoskinCubeRollout resized newSize do
    (
        ResizeControls newSize.x
    )

    -- 初始化
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
        etTarget.text = "未选择目标"
        btnRefresh.text = "捕捉目标"
        lblGenerationStatus.text = ""
    )
)

createDialog GoskinCubeRollout 200 420 style:#(#style_titlebar, #style_sysmenu, #style_resizing)