using GLib;
using Gee;
/*
 * OpenAPL 2011
 * A Modern open source replacement for APL
 * Released under the GNU Public License. 2011.
 * Author: Shaun Campbell
 * Class: HashmapItem
 * Date: 04 May 2011
 * Version: 1.0
 */
namespace scientia.Collections
{
	/***
	 * Error structure that can be used when utilising the hashmap
	 ***/
	public errordomain HashmapError
	{
		HASHNOTFOUND
	}

	public class HashmapItem <K,V> : GLib.Object
	{
		/* Instance Variables */
		private HashmapItem<K, V> _left;	
		private HashmapItem<K, V> _right;
		private HashValue<K> _hash;
		private V _item;

		/***
		 * Create a new HashmapItem containing item V and hash K
		 ***/
		public HashmapItem ( V item, HashValue<K> hash )
		{
			this._item = item;
			this._hash = hash;
		}

		/***
		 * Return the hash as an unencapsulated object
		 ***/
		public K get_hash ()
		{
			return this._hash.get_hash();
		}

		/***
		 * Return the object being hashed against
		 ***/
		public V get_item ( HashValue<K> hash ) throws HashmapError
		{
			if (this._hash.equals(hash))
				return this._item;
			else if (this._hash.greater_than(hash) && this._left != null)
				return this._left.get_item ( hash );
			else if (this._hash.less_than(hash) && this._right != null)
				return this._right.get_item ( hash );
			else
				throw new HashmapError.HASHNOTFOUND("Cannot find hash in tree");			
		}

		/***
		 * Add an item to the hashtable. Usually called by the HashMap object that this 
		 * is associated with. This is needed because a binary search tree is created.
		 * TODO: Turn this into an AVL Tree structure to increase efficiency
		 ***/
		public void add_item ( V item, HashValue<K> hash )
		{
			/* If hash of the new item is less than this item by some metric 
			 * then add it to the left hand branch. If it is greater than this item
			 * by some metric then add it to the right hand branch. 
			 * If equal to this item, then a collision has been detected (does nothing)
			 */
			if (this._hash.greater_than(hash))
			{
				//	Add to left
				if (this._left == null)
					this._left = new HashmapItem<V,K>(item, hash);
				else
					this._left.add_item(item, hash);
			} 
			else if (this._hash.less_than(hash))
			{
				//	Add to right
				if (this._right == null)
					this._right = new HashmapItem<V,K>(item, hash);
				else
					this._right.add_item(item, hash);
			}
		}
	}
}
