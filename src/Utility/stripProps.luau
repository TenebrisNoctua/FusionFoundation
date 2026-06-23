local defaultKeys = {"backgroundStyle", "tag", "children", "padding", "stroke", "scope", "layout"}

-- Strips the given properties in the <code>exclude</code> table from the <code>props</code> table.
return function(props: {[any]: any}, exclude: {any}, doNotRemoveDefaults: boolean?)
    local export = table.clone(props)

    for _, k in ipairs(exclude) do
        export[k] = nil
	end
	
	-- By default, we always remove the certain default properties, unless specified otherwise.
	if not doNotRemoveDefaults then
		for _, key in defaultKeys do
			export[key] = nil
		end
	end

    return export
end
