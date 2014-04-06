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

namespace scientia.apl
{
	public enum AplVariableClass
	{
		String, Number, Matrix
	}
	
	public interface AplVariable : GLib.Object
	{
		public abstract bool equals ( AplVariable b );
		public abstract bool less_than ( AplVariable b );
		public abstract bool greater_than ( AplVariable b );
		public abstract Object get_value ();
		public abstract void set_value ( Object o );
		public abstract AplVariableClass get_variableclass ( );
		public abstract string to_string ();		
		public abstract ulong size ();
		
		/* insert here actual operations */
		public abstract AplVariable? f_add (AplVariable a) throws AplInterpreterError;
		public abstract AplVariable? f_subtract ( AplVariable a ) throws AplInterpreterError;
		public abstract AplVariable? f_multiply ( AplVariable a ) throws AplInterpreterError;
		public abstract AplVariable? f_divide ( AplVariable a ) throws AplInterpreterError;
		public abstract AplVariable? f_equal ( AplVariable a ) throws AplInterpreterError;
		public abstract AplVariable? f_lessthan ( AplVariable a ) throws AplInterpreterError;
		public abstract AplVariable? f_gtthan ( AplVariable a ) throws AplInterpreterError;
		public abstract AplVariable? f_modulus ( AplVariable a ) throws AplInterpreterError;
		
		/* Unary functions */
		public abstract AplVariable? f_subtract_u () throws AplInterpreterError;

	}
}
