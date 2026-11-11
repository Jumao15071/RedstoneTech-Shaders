# RedstoneTech Shader
![](https://img.shields.io/github/languages/code-size/OEOTYAN/useless-shaders?style=for-the-badge)
![](https://img.shields.io/github/languages/top/OEOTYAN/useless-shaders?style=for-the-badge)
![](https://img.shields.io/github/license/OEOTYAN/useless-shaders?style=for-the-badge)
![](https://img.shields.io/github/downloads/OEOTYAN/useless-shaders/total?style=for-the-badge)
![](https://img.shields.io/github/v/release/OEOTYAN/useless-shaders?style=for-the-badge)

RENDER DRAGON version made by https://github.com/ddf8196/MaterialBinTool

中文/EN

支持 Windows、Android 和 iOS
作者：bilibili 王2408
https://www.curseforge.com/minecraft-bedrock/texture-packs/redstonetech-shader

如何使用着色器：
1. 保持红区显光影版本与游戏版本一致
2. 使用 LeviLauncher（Windows 或 Android）/ mbl2（Android）/ HynisLoader（iOS）装载资源包，并切换至红石模式子包
或 手动替换原版文件 renderer/materials/RenderChunk.material.bin 部分
3. 享受游戏：)
如果没变化，可最小化游戏再点进去试试看；变虚空是因为光影与游戏版本不一致

Supports on Windows, Android, and iOS.
Author: bilibili 王2408
https://www.curseforge.com/minecraft-bedrock/texture-packs/redstonetech-shader

How to use the shader:
1. Keep the Redstone shader version consistent with the game version.
2. Use LeviLauncher (Windows or Android) / mbl2 (Android) / HynisLoader (iOS) to load the resource pack, and switch to the Redstone mode subpack.
Or manually replace the relevant part of the original file renderer/materials/RenderChunk.material.bin.
3. Enjoy the game :)
If there is no change, try minimizing the game and then tapping back into it; if it turns into the void, it is because the shader and game version are inconsistent.

Shader client link:
https://github.com/LiteLDev/LeviLauncher
https://github.com/0Sombra666/LeviLaunchroidUnlocked
https://github.com/congcq/HynisLoader/releases

使用指导：
https://www.bilibili.com/video/BV1735u6oEAz
https://www.bilibili.com/video/BV1CYGi6zE82

## 仓库里都有什么

根目录下有几个文件夹，各自管一摊事。

**`RedstoneTechShaders/` 是着色器源码。** 光影的显示效果全在这里。进到
`RenderChunk/shaders/` 会看到几个文件：`fragment.sc` 是主体，`RCN_apply.h`
负责画红石粉亮度、方块光照数字和区块边框，`RCN_config.h` 决定哪些效果在哪些
方块上生效、以及每个子包用哪套开关。想改光影效果就改这几个文件。

矿透单独放在 `RenderChunkXray/` 这个工程里，用的是另一份片元着色器
`RenderChunk/shaders/fragment_xray.sc`，和 `fragment.sc` 互不影响。

**`pack/` 是资源包本身。** 除了着色器以外的东西都在这里：包的清单
`manifest.json`（管名字、版本号、子包列表）、图标 `pack_icon.png`、各种贴图
`textures/`。想改包名、改版本、换图标、换贴图，就在这个文件夹里改。
`pack/subpacks/X-ray/` 是矿透子包用的贴图和方块列表。

**`tools/` 是打包工具。** 里面是打包脚本和一份 lazurite 编译器，平时不用碰。

**`RenderDragon/` 是 MaterialBinTool 的源码**，用来反编译游戏里的材质，
跟打包没关系，不看也不影响。

**`build/` 是打出来的东西**，全是临时产物，删掉也没事，下次打包会重新生成。

## 怎么打包

第一次用之前要先做两件事。

第一件，装 Python 依赖。命令行里跑：

```
pip install pyjson5 myers pcpp pycryptodome sympy
```

第二件，告诉脚本原版材质库放在哪。在仓库根目录建一个 `local.env.bat`，里面写
一行，路径换成你自己电脑上的位置：

```bat
set "REDSTONE_VANILLA_MATERIALS=D:\你的路径\Vanilla\materials"
```

这个文件不会提交到仓库。不想建文件的话，改成设同名环境变量效果一样。

之后打包就两个命令。

**全部打包**，平时用这个：

```bat
all-packing.bat
```

它会按顺序编译 9 个子包（含矿透），把 `pack/` 复制一份出来，再把编好的材质一个
个塞进对应子包的 `renderer/materials/`，最后压成一个 `.mcpack` 放进 `build/`。

想给输出文件加个版本后缀（比如发 26.60 版本），就带上参数：

```bat
all-packing.bat 2660
```

出来的是 `build\RedstoneTechShader_2660.mcpack`。后缀只影响文件名，不影响编
出来的内容。

**只编一个子包**，调试的时候用：

```bat
packing.bat Default 3
```

第一个参数是子包名，随便起，只用来命名输出文件夹；第二个参数才是真正决定编
哪套功能的编号，不能乱写。结果在 `build\bin\Default\RenderChunk.material.bin`。

### 压缩 bin 体积（press）

`press/` 里那套工具会重写 bin 里的 ESSL shader：解包 → glslang 转 SPIR-V →
`spirv-opt -Os` 优化 → spirv-cross 转回 GLSL → 精简文本 → 重新打包。实测：

| 子包 | 原始 | 压缩后 | 比例 |
| --- | --- | --- | --- |
| Default | 841,530 B | 539,810 B | 64.1% |
| LightOverlay | 1,014,790 B | 784,022 B | 77.3% |
| NightVision | 817,410 B | 511,910 B | 62.6% |
| NightVision-LightOverlay | 990,720 B | 756,120 B | 76.3% |
| NoChunkBorders | 809,038 B | 489,406 B | 60.5% |
| NoChunkBorders-LightOverlay | 983,076 B | 733,154 B | 74.6% |
| NoChunkBorders-NightVision | 784,870 B | 461,396 B | 58.8% |
| NoChunkBorders-NightVision-LightOverlay | 958,958 B | 705,140 B | 73.5% |
| X-ray | 约 1,003,000 B | 约 767,700 B | 76.6% |

用的时候在命令后面加 `press`：

```bat
all-packing.bat 2660 press    :: 全部子包都压一遍再打包
packing.bat Default 3 press   :: 只编一个并压缩
```

只有 ESSL_310 平台的 shader 文本会被重写，DXBC 和 Metal 的部分原样保留。

**有个反直觉的点：bin 变小了，但 .mcpack 反而变大。** 9 个子包合计从约 7.4 MB 降到
约 5.7 MB，可 zip 后的包从 719 KB 涨到 770 KB —— 原始 bin 里重复的文本多、zip 压得
狠，优化后的代码更"干净"反而难压。所以：

- 想让游戏少读点内存 / 加载快一点 → 用 `press`；
- 想发出去的包尽量小 → 不要用 `press`。

注意几点：

- 压缩后 bin 的大小会和源包对不上，不能再靠"比大小"验证；改用
  `lazurite info` 看 shader 数和平台数是否还是 240 / 3。
- 这是实验性压缩，改的是 shader 文本，发布前最好进游戏实测一遍。
- `press/` 里原来的 `regex-replace.py` 正则只能匹配 `layout(location = N)`，而现在的
  spirv-cross 输出是 `layout(location=18,binding=0)`，匹配不到；那个位置已经换成
  `tools/press-clean.py`，顺带把默认精度从 mediump 改回 highp。

编号对应的功能（写在 `RCN_config.h` 里，脚本编译时会覆盖它）：

| 编号 | 子包 | 夜视 | 亮度 | 区块边框 |
| --- | --- | --- | --- | --- |
| 0 | NightVision-LightOverlay | 有 | 有 | 有 |
| 1 | NightVision | 有 | 无 | 有 |
| 2 | LightOverlay | 无 | 有 | 有 |
| 3 | Default | 无 | 无 | 有 |
| 4 | NoChunkBorders-NightVision-LightOverlay | 有 | 有 | 无 |
| 5 | NoChunkBorders-NightVision | 有 | 无 | 无 |
| 6 | NoChunkBorders-LightOverlay | 无 | 有 | 无 |
| 7 | NoChunkBorders | 无 | 无 | 无 |
| 8 | X-ray | 有 | 有 | 有 |

编号 8 是脚本里的别名：它是 `SUBPACKS 0`，但换用 `RenderChunkXray` 工程来编译，
所以实际的片元着色器是 `fragment_xray.sc`，不是 `fragment.sc`。

## 想改东西，改哪里

**改光影效果** → 改 `RedstoneTechShaders/RenderChunk/shaders/` 里的文件，然后跑
一次 `all-packing.bat`。不用手动复制，打包时会重新编译。

**改矿透效果** → 改 `RedstoneTechShaders/RenderChunk/shaders/fragment_xray.sc`。
它和 `fragment.sc` 是两份独立的文件，矿透用自己那份，普通子包完全不受影响。
矿透工程在 `RedstoneTechShaders/RenderChunkXray/`，它的 `config.json` 只是把
fragment 指向 `fragment_xray.sc`，vertex/varying 复用 `RenderChunk/shaders/` 里的。

**改资源包内容**（包名、版本号、图标、贴图）→ 改 `pack/` 里对应的文件，再跑
`all-packing.bat`，这些文件会被原样复制进最终的包。

**加一个新子包** → 两处一起改：`all-packing.bat` 里加一行 `call :build 子包名 编号`，
`pack/manifest.json` 的 `subpacks` 里加一条对应条目，两边的名字要一致。

**想手动替换游戏文件**（不用子包那种玩法）→ 用 `pack/renderer/materials/RenderChunk.material.bin`，
这份是原样打包进去的，脚本不会重新编译它。

## 几个需要知道的

- 矿透靠 `fragment_xray.sc` 里那段 alpha 处理：只丢掉几乎全透明的像素，其余
  压到 60% 不透明度，再配合 `pack/subpacks/X-ray/` 里的透明方块贴图才能透视。
  `fragment.sc` 里同样位置留着一份注释掉的等价代码，那是历史写法，不要直接
  启用——普通子包和矿透用的是两个文件。
- 编译时偶尔会冒出 `:3 error: Bad macro definition`，是 glslang 校验的噪音，
  不影响产物，可以忽略。
