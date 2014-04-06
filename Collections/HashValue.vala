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
	/***
	 * Interface to allow two hashes to be compared in a hashmap structure
	 ***/
	public interface HashValue<T> : GLib.Object
	{
		/***
		 * Compare this HashValue object to another. 
		 * Returns < 0 if less than, 0 if equal and > 0 if greater than
		 ***/
		public abstract int compare_to (HashValue<T> h);

		/***
		 * Check if HashValue h is equal to this one
		 ***/
		public abstract bool equals (HashValue<T> h);
		/***
		 * Check if HashValue h is less than to this one
		 ***/
		public abstract bool less_than (HashValue<T> h);
		/***
		 * Check if HashValue h is greater than to this one
		 ***/
		public abstract bool greater_than (HashValue<T> h);
		/***
		 * Return the actual value of the hash as a primitive unencapsulated object
		 ***/
		public abstract T get_hash();
	}
}
