local assetLoader = {}

assetLoader.loading = 0
assetLoader.loaded = 0
assetLoader.load = function(config)
	assetLoader.loading = assetLoader.loading + 1

	local asset = {}
	asset.type = config.type or "none"
	asset.onLoad = config.onLoad or function(_) end
	asset.onError = config.onError
		or function(_)
			error("Failed to load '" .. asset.url .. "'. Status code: " .. asset.status_code, 2)
		end

	asset.request = HTTP:Get(config.url, function(res)
		asset.status_code = res.StatusCode

		if asset.type == "none" then
			asset.data = res.Body
		elseif asset.type == "json" then
			local exec, error = pcall(function()
				asset.data = JSON:Decode(res.Body)
			end)
			if error == true then
				error("Failed to load '" .. asset.url .. "'. Wrong JSON input", 2)
			end
		elseif asset.type == "script" then
			asset.data = load(res.Body, nil, "bt", env)
		else
			error("Failed to load '" .. asset.url .. "'. Wrong type '" .. asset.type .. "'.", 2)
		end

		if asset.StatusCode ~= 200 then
			assetLoader.loading = assetLoader.loading - 1
			asset:onError()
			return
		end

		assetLoader.loaded = assetLoader.loaded + 1
		assetLoader.loading = assetLoader.loading - 1
		asset:onLoad()
	end)

	return asset
end

return assetLoader
