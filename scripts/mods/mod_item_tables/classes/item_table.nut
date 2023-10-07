::ItemTables.Class.ItemTable <- class extends ::MSU.Class.WeightedContainer
{
	constructor( _array = null )
	{
		base.constructor(_array);
	}

	function roll( _options = null )
	{
		if (_options == null || typeof _options == "array")
			return base.roll(_options);

		local options = {
			Exclude = null,
			Add = null
			Apply = null
		}

		foreach (key, value in _options)
		{
			if (!(key in options)) throw "invalid parameter " + key;
			options[key] = value;
		}

		if (options.Apply != null || options.Add != null)
		{
			local container = clone this;

			if (options.Apply != null) container.apply(options.Apply);

			switch (typeof options.Add)
			{
				case "array":
					container.addArray(options.Add);
					break;

				case "instance":
					container.merge(options.Add);
					break;

				default:
					throw ::MSU.Exception.InvalidType(options.Add);
			}

			return container.roll(options.Exclude);
		}

		return base.roll(options.Exclude);
	}

	function rollByProperty( _property, _options = null )
	{
		local options = {
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

		local invert = options.Invert;
		options.Apply <- @(script, weight) invert ? 1.0 / ::Math.minf(1.0, ::ItemTables.ItemInfoByScript[script][_property]) : ::ItemTables.ItemInfoByScript[script][_property];
		delete options.Invert;

		return this.roll(options);
	}
}
