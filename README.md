# StriveGame(Unity5 + ULUA + kbengine)


* 使用Unity+KBEngine开发的mmo游戏demo的第二版，主要工作是将KBE的客户端插件以及大部分游戏逻辑Lua化，实现客户端热更新

* kbe插件层逻辑分离出去作为[submodule](https://github.com/liuxq/kbengine_unity3d_lua_plugins)，请先更新插件

* 运行前需要先点击LuaFramework->Build XXX Resource来创建游戏资源的assetbundle, 并点击Lua->Generate All来wrap一些C#代码到lua里面，这部分有疑问可以查看tolua官方教程[TOLUA](https://github.com/jarjin/LuaFramework_UGUI)

* 目前游戏内容并没有实现完全，可以仿照游戏第一版[TestGame](https://github.com/liuxq/TestGame)中的C#逻辑改写Lua代码补全游戏功能

* 使用kbengine-0.9.17版本，服务器脚本在：[MyGameServerAssets](https://github.com/liuxq/MyGameServerAssets.git)
//

//-------------2017-07-18-------------

(1)kbe的插件层分离出去，升级lua插件到tolua#1.0.7.337，升级kbe到0.9.17

//-------------2017-05-21-------------

(1)升级lua插件到tolua#1.0.6.311

//-------------2017-05-09-------------

(1)升级kbengine到v0.9.13

//-------------2017-01-01-------------

(1)升级kbengine到v0.9.7

//-------------2016-11-06-------------

(1)升级lua插件到tolua#1.0.6.266

//-------------2016-6-06-------------

(1)升级kbengine服务器版本到0.8.10


###### lua代码结构说明   
![ui-demo](/structure.png)
###### ip、port等配置位置
![ui-demo2](/config.png)
###### 游戏截图
![ui-demo2](/strivegamedemo.png)




