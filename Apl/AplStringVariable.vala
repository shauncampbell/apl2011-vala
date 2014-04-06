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
	public class AplStringVariable : AplVariable, GLib.Object
	{
		private string _val = "";
		
		public static AplStringVariable FromString ( string txt )
		{
			AplStringVariable a = new AplStringVariable ( txt );
			return a;
		}
			
		private AplStringVariable ( string txt )
		{
			_val = txt;		
		}
		
		public ulong size ()
		{
			return _val.length;
		}
		
		public bool equals ( AplVariable b )
		{
			if ( b.get_variableclass() == this.get_variableclass() )
			{
				return ( ( (string?) b.get_value () ).ascii_casecmp( (string?) this.get_value () ) == 0 );
			} 
			else
			{
				return false;
			}
		}
		
		public bool less_than ( AplVariable b )
		{
			if ( b.get_variableclass() == this.get_variableclass() )
			{
				return ( ( (string?) b.get_value () ).ascii_casecmp( (string?) this.get_value () ) < 0 );
			} 
			else
			{
				return false;
			}		
		}
		
		public bool greater_than ( AplVariable b )
		{
			if ( b.get_variableclass() == this.get_variableclass() )
			{
				return ( ( (string?) b.get_value () ).ascii_casecmp( (string?) this.get_value () ) > 0 );
			} 
			else
			{
				return false;
			}		
		}
		
		public Object get_value ()
		{
			return new PrimitiveWrapper<string?> ( _val );
		}
		
		public void set_value (Object o)
		{
			PrimitiveWrapper<string?> v = (PrimitiveWrapper<string?>) o;
			_val =   v.get_value();
		}
		
		public AplVariableClass get_variableclass ()
		{
			return AplVariableClass.String;
		}
		
		public string to_string ()
		{
			return _val.to_string();
		}
		/* insert here actual operations */
		public AplVariable? f_add (AplVariable a) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.String:
					StringBuilder sb = new StringBuilder();
					sb.append(_val);
					PrimitiveWrapper<string?> s = (PrimitiveWrapper<string?>)a.get_value();
					sb.append(s.get_value());
					return AplStringVariable.FromString(sb.str);
				default:
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );
			}
		}
		
		public AplVariable? f_subtract ( AplVariable a ) throws AplInterpreterError
		{
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );		
		}
		
		public AplVariable? f_multiply ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					return a.f_multiply ( this );
				default:
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );
			}
		}
		
		public AplVariable? f_divide ( AplVariable a ) throws AplInterpreterError
		{
			throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );		
		}
		
		public AplVariable? f_equal ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.String:
					PrimitiveWrapper<string?> s = (PrimitiveWrapper<string?>)a.get_value();
					string ss = s.get_value();
					return AplNumberVariable.FromNumber ( (ss == _val) ? 1 : 0 );
				case AplVariableClass.Matrix:
					AplMatrixVariable m = (AplMatrixVariable) a;
					return m.f_equal_r ( this );
				default:
					return AplNumberVariable.FromNumber ( 0 );
			}
		}
		
		public AplVariable? f_modulus ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				default:
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );	
			}
		}	
		
		public AplVariable? f_lessthan ( AplVariable a) throws AplInterpreterError
		{
			return null;
		}
		
		public AplVariable? f_gtthan ( AplVariable a) throws AplInterpreterError
		{
			return null;
		}
		public AplVariable? f_subtract_u ( ) throws AplInterpreterError
		{
			return AplStringVariable.FromString ( _val.down() );
		}			
	}
}
