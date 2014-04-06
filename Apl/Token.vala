using GLib;
/*
 * OpenAPL 2011
 * A Modern open source replacement for APL
 * Released under the GNU Public License. 2011.
 * Author: Shaun Campbell
 * Date: 04 May 2011
 * Version: 1.0
 */
namespace scientia.apl
{
	public class Token<T> : GLib.Object
	{
		private T _content;
		private AplTokenClass _class;
		
		/***
		 * Create a new Token object with a given class and content
		 ***/
		public Token (AplTokenClass tokenClass, T content)
		{
			this._content = content;
			this._class = tokenClass;
		}
	
		/***
		 * Retrieve the class associated with this token
		 ***/
		public AplTokenClass get_tokenclass()
		{
			return this._class;
		}

		/***
		 * Retrieve the raw content encapsulated within this token
		 ***/
		public T get_content()
		{
			return this._content;
		}
		
	}	
}
