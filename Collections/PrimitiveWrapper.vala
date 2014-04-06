using GLib;
using scientia.apl;
using scientia.Collections;
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
	public class PrimitiveWrapper<T> : GLib.Object
	{
		private T? _d;
		
		public PrimitiveWrapper ( T d )
		{
			_d = d;
		}
		
		public T? get_value ()
		{
			return _d;
		}
		
		public void set_value (T? d)
		{
			_d = d;
		}
	}
}
