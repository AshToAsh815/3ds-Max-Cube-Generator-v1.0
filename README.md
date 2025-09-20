# 3ds-Max-Cube-Generator-v1.0
小方块生成器

————————————————————————————————————————————————————————
用途描述
该脚本是一个 3D 建模辅助工具，主要用于快速生成绑定蒙皮的小型立方体（"小方块"）。它允许用户：
捕捉目标对象并生成与其绑定的单个或批量小方块
通过预设管理不同游戏角色的部件名称
保存和加载自定义预设，提高重复操作的效率
一键导入当前选择对象的名称作为小方块命名参考

做鬼泣5MOD的时候，当你的模型子网格比鬼泣5的源文件少的时候，比如：原版但丁人形态的身体有9个子网格，一共七个材质名，而你的模型就一个子网格，
那你要是不想改mdf文件里的材质数量，你就得补6个小方块一起导出，那就不用改mdf文件中的材质了

————————————————————————————————————————————————————————
Description
This script is a 3D modeling auxiliary tool designed to quickly generate skin-bound small cubes. It allows users to:
Capture target objects and generate single or batch skin-bound cubes
Manage part names for different game characters through presets
Save and load custom presets to improve efficiency in repeated operations
Import names of currently selected objects as naming references for cubes

When creating mods for Devil May Cry 5 (DMC5), if your custom model has fewer submeshes than the original DMC5 files—for instance,
 the original Dante (Human Form) body has 9 submeshes with a total of 7 material names, but your custom model only has 1 submesh—you will need to add 6 extra small cubes to export alongside it if you want to avoid modifying the number of materials in the MDF file. 
This way, there’s no need to edit the materials in the MDF file.
————————————————————————————————————————————————————————
小方块生成器简要说明书
适用于 3ds Max，快速生成带蒙皮的小方块，支持预设管理。
————————————————————————————————————————————————————————
一、核心步骤（3 步搞定）
捕捉目标
在 Max 中选蒙皮目标（如角色模型），点脚本【捕捉目标】，确认输入框显示目标名。
设方块名称
方式 1（用预设）：选游戏→选预设，名称自动填充；
方式 2（手动）：在 “自定义名称” 框输名称（每行 1 个），或点【一键写入当前选择】读取已选对象名。
生成方块
单个：点【生成单个小方块】；
批量：点【批量生成小方块】，状态标签显示结果。
————————————————————————————————————————————————————————
二、预设管理（可选）
新增游戏：点游戏区【新增】，输游戏名保存。
保存预设：填好名称后，点预设区【保存】，输预设名即可。
删除：选游戏  预设后，点对应【删除】按钮（谨慎操作）。
————————————————————————————————————————————————————————
三、注意
预设文件存脚本同级目录，勿删；
生成失败先检查是否已捕捉目标、名称是否合规。



Quick Start Guide for Goskin Cube Generator
For 3ds Max, it enables quick generation of skinned small cubes and supports preset management.
————————————————————————————————————————————————————————
I. Core Steps (3 Steps to Complete)
1. Capture Target
Select a skinning target (e.g., a character model) in 3ds Max, click Capture Target in the script, and confirm the target name is displayed in the input box.
2. Set Cube Names
Method 1 (Use Preset): Select a game → select a preset, and the names will be automatically populated.
Method 2 (Manual Input): Enter names in the "Custom Names" box (one name per line), or click One-Click Write Current Selection to load names of selected objects.
3. Generate Cubes
Single Cube: Click Generate Single Small Cube.
Batch Cubes: Click Batch Generate Small Cubes; the status label will show the result.
————————————————————————————————————————————————————————
II. Preset Management (Optional)
Add Game: Click Add in the game section, enter a game name, and save.
Save Preset: After filling in names, click Save in the preset section, and enter a preset name.
Delete: Select a game/preset first, then click the corresponding Delete button (operate with caution).
————————————————————————————————————————————————————————
III. Notes
Preset files are stored in the same directory as the script; do not delete them.
If generation fails, first check whether the target has been captured and whether the names are valid.