::ItemTables.Class.ItemTable <- class extends ::MSU.Class.WeightedContainer
{
	constructor( _array = null )
	{
		base.constructor(_array);
	}

	function roll( _options = null )
	{
		local options = {
			Exclude = null,
			Add = null
			Apply = null
		}

		if (_options != null)
		{
			foreach (key, value in _options)
			{
				if (!(key in options)) throw "invalid parameter " + key;
				options[key] = value;
			}
		}

		local tableBackup = clone this.Table;
		local totalBackup = this.Total;

		if (options.Apply != null) this.apply(options.Apply);

		switch (typeof options.Add)
		{
			case "null":
				break;

			case "array":
				this.addArray(options.Add);
				break;

			case "instance":
				this.merge(options.Add);
				break;

			default:
				throw ::MSU.Exception.InvalidType(options.Add);
		}

		local ret = base.roll(options.Exclude);

		this.Table = tableBackup;
		this.Total = totalBackup;

		return ret;
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
