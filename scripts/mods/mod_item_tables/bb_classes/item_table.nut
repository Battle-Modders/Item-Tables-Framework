this.item_table <- {
	m = {
		ID = null,
		Items = ::MSU.Class.WeightedContainer() // contains item scripts with weights
	},

	function getID()
	{
		return this.m.ID;
	}

	function getItems()
	{
		return this.m.Items;
	}

	function add( _script, _weight )
	{
		this.m.Items.add(_script, _weight);
	}

	function remove( _script )
	{
		this.m.Items.remove(_script);
	}

	function roll( _options = null )
	{
		local options = {
			Multipliers = null,
			Exclude = null
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

		return items.roll(options.Exclude);
	}

	function rollByProperty( _property, _options = null )
	{
		local options = {
			Multipliers = null
			Invert = false,
			Exclude = null
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
		items.apply(@(script, weight) ::ItemTables.ItemInfoByScript[script][_property]); // Set the weight equal to the value of the property

		if (options.Multipliers != null) this.__applyMultipliers(items, options.Multipliers);

		return items.roll(options.Exclude);
	}

	function __applyMultipliers( _itemContainer, _multipliers )
	{
		foreach (script, mult in _multipliers)
		{
			if (!_itemContainer.contains(script) || _itemContainer.getWeight(script) < 0) continue;

			if (mult < 0) _itemContainer.setWeight(script, -1);
			else _itemContainer.setWeight(script, _itemContainer.getWeight(script) * mult);
		}
	}
};
