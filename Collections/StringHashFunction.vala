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
	public class StringHashFunction: HashFunction<ulong, string>, GLib.Object
	{
		/***
		 * Generate a new hash of a string, returning a ulong representation
		 ***/
		public new HashValue<ulong> get_hash (string item )
		{
			ulong hash = 0;
			int c;
			for (int i = 0; i < item.length; i++)
			{
				c = item[i];
				hash = c + (hash << 6) + (hash << 16) - hash;
			}
	
			return new UlongHashValue(hash);
		}
	}
}
