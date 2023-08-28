::ItemTables <- {
	Version = "0.1.0",
	ID = "mod_item_tables",
	Name = "Item Tables",
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

::mods_registerMod(::ItemTables.ID, ::ItemTables.Version, ::ItemTables.Name);
::mods_queue(::ItemTables.ID, "mod_msu", function() {

	// ::ItemTables.Mod <- ::MSU.Class.Mod(::ItemTables.ID, ::ItemTables.Version, ::ItemTables.Name);

	::mods_hookExactClass("root_state", function(o) {
		local onInit = o.onInit;
		o.onInit = function()
		{
			local ret = onInit();
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
						::ItemTables.ItemInfoByScript[script][property] <- ::MSU.isIn(property, item, true) ? item[property]() : item.m[property];
					}
				}
				catch (error)
				{
					::logError(::ItemTables.Name + " -- Failed to cache info for item: " + script + ". Error: " + error);
				}
			}

			return ret;
		}
	});
});
