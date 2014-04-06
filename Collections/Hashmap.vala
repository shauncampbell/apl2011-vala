using GLib;
/*
 * OpenAPL 2011
 * A Modern open source replacement for APL
 * Released under the GNU Public License. 2011.
 * Author: Shaun Campbell
 * Date: 04 May 2011
 * Version: 1.0
 */
namespace scientia.Collections
{
	public class Hashmap<K,V> : GLib.Object
	{
		/* Instance Variables */
		private HashmapItem <K,V>  _topnode;
		private HashFunction<K,V> _func;
		private int _itemCount = 0;

		/***
		 * Create a new hashmap that generates hash values using function
		 ***/
		public Hashmap ( HashFunction<K,V> function )
		{
			this._func = function;
		}

		/***
		 * Add an item to this hashmap
		 ***/
		public HashValue<K> add_item (V item )
		{
			//	Generate a hash for this item
			HashValue<K> hash = this._func.get_hash (item);
			
			//	If no values, then this is the only entry in the map
			if (this._topnode == null)
				this._topnode = new HashmapItem<K,V>(item, hash);
			else
				this._topnode.add_item (item, hash);

			this._itemCount++;
			//	Return the hash for users to use
			return hash;
		}

		/***
		 * Retrieve an item from the hashmap
		 ***/
		public V get_item ( HashValue<K> hash ) throws HashmapError
		{
			if (_topnode != null)
			{
				return _topnode.get_item(hash);
			}
			throw new HashmapError.HASHNOTFOUND("Cannot find hash");
		}
		
		/***
		 * Retrieve the number of elements in the hashmap
		 ***/
		public int size ()
		{
			return _itemCount;
		}
	}
}
