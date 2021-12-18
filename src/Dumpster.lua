-- https://gist.github.com/Fraktality/f0ab4ad950698e9f08bb01bea486845e

local Dumpster = {}
do
	Dumpster.__index = Dumpster

	local finalizers = setmetatable({
		["function"] = function(item)
			return item()
		end,
		["Instance"] = function(item)
			return item:Destroy()
		end,
		["RBXScriptConnection"] = function(item)
			return item:Disconnect()
		end,
	}, {
		__index = function(_self, className)
			error(("Can't dump item of type '%s'"):format(className), 3)
		end,
	})

	function Dumpster.new()
		return setmetatable({}, Dumpster)
	end

	function Dumpster:dump(item)
		self[item] = finalizers[typeof(item)]
	end

	function Dumpster:burn()
		for item, finalizer in pairs(self) do
			finalizer(item)
			self[item] = nil
		end
	end
end

return Dumpster
