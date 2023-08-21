::ItemTables.Class.ItemTable <- class extends ::MSU.Class.WeightedContainer
{
	TableBackup = null;
	TotalBackup = null;

	constructor( _array = null )
	{
		base.constructor(_array);
		this.TableBackup = {};
		this.TotalBackup = 0;
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

		this.TableBackup = clone this.Table;
		this.TotalBackup = this.Total;

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

		this.Table = clone this.TableBackup;
		this.Total = this.TotalBackup;
		this.TableBackup.clear();

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
