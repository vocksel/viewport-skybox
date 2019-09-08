# ViewportSkybox

A Roact-based 3D skybox, modified from the [3DSkybox devforum post](https://devforum.roblox.com/t/3dskybox-a-way-to-create-more-immersive-skyboxes-for-your-game/208760).

![Example of a skybox showing off celestial bodies, plentary rings, and stars](screenshots/skybox-sample.png)

The skybox is entirely made out of instances, which can be seen in this screenshot:

![A screenshot showing how the skybox looks from a different angle](screenshots/how-it-works.png)

## Usage

```lua
local Roact = require(script.Parent.Roact)
local ViewportSkybox = require(script.Parent.ViewportSkybox)

local playerGui = game.Players.LocalPlayer.PlayerGui

local skybox = Roact.createElement(Skybox, {
	content = game.ReplicatedStorage.SkyboxModel
})

Roact.mount(skybox, playerGui, "Skybox")
```
