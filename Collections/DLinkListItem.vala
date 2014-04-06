using GLib;
/*
 * OpenAPL 2011
 * A Modern open source replacement for APL
 * Released under the GNU Public License. 2011.
 * Author: Shaun Campbell
 * Class: DLinkListItem
 * Date: 04 May 2011
 * Version: 1.0
 */
namespace scientia.Collections
{
	public class DLinkListItem <T> : GLib.Object
	{
		/* Instance Variables */
		private DLinkListItem<T> _next = null;
		private DLinkListItem<T> _prev = null;
		private T _obj;

		/***
		 * Construct a new LinkListItem
		 ***/
		public DLinkListItem(T item)
		{
			this._obj = item;
		}

		/***
		 * Return the next item in the list
		 ***/
		public DLinkListItem<T> next()
		{
			return this._next;
		}

		/***
		 * Return the previous item in the list
		 ***/
		public DLinkListItem<T> prev()
		{
			return this._prev;
		}

		/***
		 * Set the next item in the list
		 ***/
		public void set_next(DLinkListItem<T> next)
		{
			this._next = next;
		}

		/***
		 * Set the previous item in the list
		 ***/
		public void set_prev(DLinkListItem<T> prev)
		{
			this._prev = prev;
		}
	
		/***
		 * Return the item encapsulated in this one
		 ***/
		public T get_item()
		{
			return _obj;
		}
	}
}
