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
	public class StackItem <T> : GLib.Object
	{
		/* Instance Variables */
		private StackItem<T> _next = null;
		private T _obj;

		/***
		 * Create a  new StackItem object
		 ***/
		public StackItem(T item)
		{
			this._obj = item;
		}

		/***
		 * Retrieve the next Item in the stack
		 ***/
		public StackItem<T> next()
		{
			return this._next;
		}

		/***
		 * Set the next item in the stack
		 ***/
		public void set_next(StackItem<T> next)
		{
			this._next = next;
		}

		/***
		 * Return the item encapsulated by this one
		 ***/
		public T get_item()
		{
			return _obj;
		}
	}
}
