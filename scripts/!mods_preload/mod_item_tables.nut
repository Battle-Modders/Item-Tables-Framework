::ItemTables <- {
	Version = "0.1.2",
	ID = "mod_item_tables",
	Name = "Item Tables",
	GitHubURL = "https://github.com/Battle-Modders/Item-Tables-Framework",
	Class = {},
	ItemInfoByScript = {},
	RollByProperties = [
		"Value",
		"Condition",
		"ConditionMax",
		"StaminaModifier",
		"SlotType",
		"ItemType"
	],

	function addRollByProperty( _property )
	{
		if (this.RollByProperties.find(_property) == null) this.RollByProperties.push(_property);
	}

	function removeRollByProperty( _property )
	{
		::MSU.Array.removeByValue(this.RollByProperties, _property);
	}
};

::ItemTables.MH <- ::Hooks.register(::ItemTables.ID, ::ItemTables.Version, ::ItemTables.Name);
::ItemTables.MH.require("mod_msu");
::ItemTables.MH.queue(">mod_msu", function() {
	::ItemTables.Mod <- ::MSU.Class.Mod(::ItemTables.ID, ::ItemTables.Version, ::ItemTables.Name);

	::ItemTables.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::ItemTables.GitHubURL);
	::ItemTables.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
});

::ItemTables.MH.queue(">mod_msu", function() {
	foreach (script in ::IO.enumerateFiles("scripts/items"))
	{
		if (script == "scripts/items/item_container") continue;

		try
		{
			local item = ::new(script);
			item.randomizeValues <- function() {};
			item.create();
			::ItemTables.ItemInfoByScript[script] <- {
				ID = item.getID()
			};
			foreach (property in ::ItemTables.RollByProperties)
			{
				// If the `property` is in `item`, it means it is a function, so call it, otherwise it is in item.m
				// We only support functions without parameters
				if (::MSU.isIn(property, item, true)) ::ItemTables.ItemInfoByScript[script][property] <- item[property]();
				else if (::MSU.isIn(property, item.m, true)) ::ItemTables.ItemInfoByScript[script][property] <- item.m[property];

			}
		}
		catch (error)
		{
			::logError(::ItemTables.Name + " -- Failed to cache info for item: " + script + ". Error: " + error);
		}
	}
}, ::Hooks.QueueBucket.AfterHooks);
