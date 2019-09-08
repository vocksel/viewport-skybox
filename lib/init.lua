--[[
	Allows you to easily compose a skybox out of instances.

	Modified from:
	https://devforum.roblox.com/t/3dskybox-a-way-to-create-more-immersive-skyboxes-for-your-game/208760
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local import = require(ReplicatedStorage.lib.import)

local Dumpster = import("lib/Dumpster")
local Roact = import("lib/Roact")
local t = import("lib/t")

local camera = workspace.CurrentCamera

local Skybox = Roact.Component:extend("Skybox")

Skybox.validateProps = t.interface({
	content = t.Instance,

	-- The distance where the skybox gui plane is. It’s best to have this quite
	-- big so it doesn’t clip with anything in the workspace.
	distance = t.optional(t.number),

	-- The origin for the camera used by the skybox.
	origin = t.optional(t.Vector3),

	-- This allows the skybox to 'move' relative to the player.
	allowMovement = t.optional(t.boolean),

	-- This value defines how much the skybox will move when the camera does,
	-- the smaller the value, the faster the skybox will move (It’s good to set
	-- a larger value if you want to make the skybox seem further away than it
	-- really is).
	movementScale = t.optional(t.number),

	Ambient = t.optional(t.Color3),
	LightColor = t.optional(t.Color3),
	LightDirection = t.optional(t.Vector3),
})

Skybox.defaultProps = {
	distance = 10000,
	origin = Vector3.new(0, 0, 0),
	allowMovement = true,
	movementScale = 2500,
	Ambience = Color3.fromRGB(200, 200, 200),
	LightColor = Color3.fromRGB(140, 140, 140),
	LightDirection = Vector3.new(-1, -1, -1),
}

function Skybox:init()
	self.viewportRef = Roact.createRef()
	self.cameraRef = Roact.createRef()
	self.adorneeRef = Roact.createRef()

	self.dumpster = Dumpster.new()

	self.cameraCFrame, self.updateCameraCFrame = Roact.createBinding(CFrame.new())
	self.adorneeCFrame, self.updateAdorneeCFrame = Roact.createBinding(CFrame.new())
	self.skyboxSize, self.updateSkyboxSize = Roact.createBinding(camera.ViewportSize)
end

function Skybox:render()
	return Roact.createElement("BillboardGui", {
		Adornee = self.adorneeRef,
		LightInfluence = 0,
		ResetOnSpawn = false,
		Size = self.skyboxSize:map(function(viewportSize)
			return UDim2.new(0, viewportSize.X, 0, viewportSize.Y)
		end)
	}, {
		Viewport = Roact.createElement("ViewportFrame", {
			Ambient = self.props.Ambient,
			LightColor = self.props.LightColor,
			LightDirection = self.props.LightDirection,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			CurrentCamera = self.cameraRef,
			[Roact.Ref] = self.viewportRef,
		}),

		Adornee = Roact.createElement("Part", {
			Anchored = true,
			Transparency = 1,
			CanCollide = false,
			CFrame = self.adorneeCFrame,
			[Roact.Ref] = self.adorneeRef,
		}),

		Camera = Roact.createElement("Camera", {
			CFrame = self.cameraCFrame,
			[Roact.Ref] = self.cameraRef,
		}),
	})
end

function Skybox:didMount()
	local content = self.props.content:Clone()
	content.Parent = self.viewportRef.current
	self.dumpster:dump(content)

	self.dumpster:dump(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		self.updateSkyboxSize(camera.ViewportSize)
	end))

	self.dumpster:dump(RunService.RenderStepped:Connect(function()
		local camPos = self.props.origin

		if self.props.allowMovement then
			camPos = self.props.origin + (camera.CFrame.Position / self.props.movementScale)
		end

		self.updateAdorneeCFrame(camera.CFrame * CFrame.new(0, 0, -self.props.distance))
		self.updateCameraCFrame(CFrame.fromMatrix(camPos, camera.CFrame.RightVector, camera.CFrame.UpVector))
	end))
end

function Skybox:willUnmount()
	self.dumpster:burn()
end

return Skybox
