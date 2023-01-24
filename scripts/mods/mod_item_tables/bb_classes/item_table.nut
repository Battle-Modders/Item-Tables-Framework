this.item_table <- {
	m = {
		ID = null,
		Items = ::MSU.Class.WeightedContainer() // contains item ids with weights
	},

	function getID()
	{
		return this.m.ID;
	}

	function getItems()
	{
		return this.m.Items;
	}

	function add( _itemID, _weight )
	{
		this.m.Items.add(_itemID, _weight);
	}

	function remove( _itemID )
	{
		this.m.Items.remove(_itemID);
	}

	function roll( _options = null )
	{
		local options = {
			Multipliers = null,
			Exclude = null,
			IDOnly = false
		};

		if (_options != null)
		{
			foreach (key, value in _options)
			{
				if (!(key in options)) throw "invalid parameter " + key;
				options[key] = value;
			}
		}

		local items = options.Multipliers == null ? this.m.Items : clone this.m.Items;
		if (options.Multipliers != null) this.__applyMultipliers(items, options.Multipliers);

		local ret = items.roll(options.Exclude);
		if (ret == null) return null;

		return options.IDOnly ? ret : ::new(::ItemTables.ItemIDToScriptMap[ret].Script);
	}

	function rollByProperty( _property, _options = null )
	{
		local options = {
			Multipliers = null
			Invert = false,
			Exclude = null,
			IDOnly = false
		};

		if (_options != null)
		{
			foreach (key, value in _options)
			{
				if (!(key in options)) throw "invalid parameter " + key;
				options[key] = value;
			}
		}

		local items = clone this.m.Items;
		items.apply(@(id, weight) ::ItemTables.ItemInfoByID[id][_property]); // Set the weight equal to the value of the property

		if (options.Multipliers != null) this.__applyMultipliers(items, options.Multipliers);

		local ret = items.roll(options.Exclude);
		if (ret == null) return null;

		return options.IDOnly ? ret : ::new(::ItemTables.ItemInfoByID[id].Script);
	}

	function __applyMultipliers( _itemContainer, _multipliers )
	{
		foreach (id, mult in _multipliers)
		{
			if (!_itemContainer.contains(id) || _itemContainer.getWeight(id) < 0) continue;

			if (mult < 0) _itemContainer.setWeight(id, -1);
			else _itemContainer.setWeight(id, _itemContainer.getWeight(id) * mult);
		}
	}
};
