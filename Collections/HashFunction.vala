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
	public interface HashFunction <K, V> : GLib.Object
	{
		/***
		 * Generate a hash of type K for object of type V
		 ***/
		public abstract HashValue<K> get_hash ( V item );
	}
}
