using GLib;
using Gee;
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
	public class UlongHashValue : HashValue<ulong>, GLib.Object
	{
		/* Instance Variables */
		private ulong _val= 0;

		/***
		 * Create a new Object to encapsulate a ulong so that it may be compared 
		 ***/
		public UlongHashValue(ulong val)
		{
			_val = val;
		}

		/***
		 * Compare this HashValue object to another. 
		 * Returns < 0 if less than, 0 if equal and > 0 if greater than
		 ***/
		public int compare_to (HashValue<ulong> h)
		{
			ulong hu = h.get_hash();
			return (int)(_val - hu);			
		}

		/***
		 * Check if HashValue h is equal to this one
		 ***/
		public bool equals (HashValue<ulong> h)
		{
			return (this.compare_to(h) == 0);
		}

		/***
		 * Check if HashValue h is less than to this one
		 ***/
		public bool less_than (HashValue<ulong> h)
		{
			return (this.compare_to(h) < 0);
		}

		/***
		 * Check if HashValue h is greater than to this one
		 ***/
		public bool greater_than (HashValue<ulong> h)
		{
			return (this.compare_to(h) > 0);
		}

		/***
		 * Return the actual value of the hash as a primitive unencapsulated object
		 ***/
		public ulong get_hash()
		{
			return _val;
		}
	}
}
