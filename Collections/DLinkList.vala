using GLib;
using Gee;
/*
 * OpenAPL 2011
 * A Modern open source replacement for APL
 * Released under the GNU Public License. 2011.
 * Author: Shaun Campbell
 * Class: DLinkList
 * Date: 04 May 2011
 * Version: 1.0
 */
namespace scientia.Collections
{
	public class DLinkList <T> : Iterator<T>, Iterable<T>, GLib.Object
	{
		/* Instance Variables */
		private DLinkListItem<T> _head 		= null;
		private DLinkListItem<T> _tail 		= null;
		private DLinkListItem<T> _current 	= null;
		private int  _size = 0;
		private bool _end  = false;

		/***
		 * Add a new Item to the list
		 ***/
		public void add ( T item )
		{
			DLinkListItem<T> dli = new DLinkListItem<T>(item);
			
			//	Exception for first item
			if (_size == 0)
			{
				_head = dli;
				_tail = dli;
			}
			else
			{
				_tail.set_next ( dli );
				dli.set_prev ( _tail );
				_tail = dli;
			}
			_size++;
		}

		/***
		 * Return the first item in the list
		 ***/
		public DLinkListItem<T> get_head()
		{
			return _head;
		}

		/***
		 * Return the last item in the list
		 ***/
		public DLinkListItem<T> get_tail()
		{
			return _tail;
		}

		/***
		 * Return the item at position index in the list
		 ***/
		public T get_item(int index)
		{
			/* To speed up searching, start at the end if more than half way down the list */
			if ( index > (0.5*this._size) )
			{
				DLinkListItem<T> d = this._tail;
				int diff = this._size - index -1;
				for (int i = 0; i < diff; i++)
					d = d.prev();
				return d.get_item();
			} 
			else
			{
				DLinkListItem<T> d = this._head;
				for (int i = 0; i < index; i++)
					d = d.next();
				return d.get_item();
			}
		}
		
		/***
		 * Delete the item at positing index in the list
		 ***/
		public void remove_at (int index)
		{
			/* To speed up searching, start at the end if more than half way down the list */
			if ( index > (0.5*this._size) )
			{
				DLinkListItem<T> d = this._tail;
				int diff = this._size - index -1;
				for (int i = 0; i < diff; i++)
					d = d.prev();
				DLinkListItem<T> prv = d.prev();
				DLinkListItem<T> nxt = d.next();
				prv.set_next(nxt);
				prv.set_prev(prv);
				_size--;
			} 
			else
			{
				DLinkListItem<T> d = this._head;
				for (int i = 0; i < index; i++)
					d = d.next();

				DLinkListItem<T> prv = d.prev();
				DLinkListItem<T> nxt = d.next();
				prv.set_next(nxt);
				nxt.set_prev(prv);
				_size--;
			}
		}
		
		/***
		 * Return the number of elements in the list
		 ***/	
		public int size()
		{
			return _size;
		}

		/* Iterator Interface */
		
		/***
		 * Check if there is a next item in the list
		 ***/
		public bool has_next()
		{
			return (_current != null || (!_end && _head != null));
		}		

		/***
		 * Retrieve the current item in the iteration
		 ***/
		public new T get()
		{
			T item = _current.get_item();
			return item;
		}
		
		/***
		 * Move the iterator one step down the list
		 ***/
		public bool next()
		{
			if (_current != null)
				_current = _current.next();
			else if (!_end)
				_current = _head;
			
			if (_current == null)
				_end = true;
			return (_current != null);
		}

		/***
		 * Move the iterator to the head of the list
		 ***/
		public bool first()
		{
			_current = _head;
			_end = false;
			return (_head != null);
		}
	
		/***
		 * Remove the current item from the iteration
		 ***/
		public void remove()
		{
			if (_current.prev() != null && _current.next() != null)
			{
				_current.prev().set_next(_current.next());
				_current.next().set_prev(_current.prev());
			}
			else if (_current.prev() != null)
			{
				_head = _current.next();
			}
			else if (_current.next() != null)
			{
				_tail = _current.prev();
			}
			
			_current = _current.prev();
			_size--;
		}

		/*	Iterable interface */

		/***
		 * Return the type of object held by this list
		 ***/
		public Type element_type
		{
			get { return typeof(T); }
		}

		/***
		 * Return an iterator so that foreach may be used
		 ***/
		public Iterator<T> iterator()
		{
			return this;
		}
	}
}
