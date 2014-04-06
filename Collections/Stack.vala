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
	public class Stack <T> : GLib.Object
	{
		/*	instance Variables */
		private long _stackSize = 0;
		private StackItem<T> _head = null;
	
		/***
		 * Push a value into the stack
		 ***/
		public void push ( T item )
		{
			StackItem<T> stackItem = new StackItem<T> ( item );
			if (this._head == null)
			{
				this._head = stackItem;
			}
			else
			{
				stackItem.set_next ( this._head);
				this._head = stackItem;
			}				
			this._stackSize++;
		}

		/***
		 * Pop a value back off of the stack
		 ***/
		public T pop ()
		{
			T item = this._head.get_item();
			this._head = this._head.next();
			this._stackSize--;
			return item;
		}

		/***
		 * Get the number of items on the stack
		 ***/
		public long size()
		{
			return this._stackSize;
		}

	}
}
