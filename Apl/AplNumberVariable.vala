using GLib;
using GLib.Math;
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
	public class AplNumberVariable : AplVariable, GLib.Object
	{
		private double _val = 0.0;
		
		/* Factory Methods */
		public static AplNumberVariable FromNumber ( double number )
		{
			AplNumberVariable a = new AplNumberVariable ( number );
			return a;
		}
		
		/* Constructor */
		private AplNumberVariable ( double number )
		{
			_val = number;		
		}
		
		/* Object Comparison Methods */
		public bool equals ( AplVariable b )
		{
			if ( b.get_variableclass() == this.get_variableclass() )
			{
				return ( ( (double?) b.get_value () ) == ( (double?) this.get_value () ) );
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
				return ( ( (double?) b.get_value () ) > ( (double?) this.get_value () ) );
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
				return ( ( (double?) b.get_value () ) < ( (double?) this.get_value () ) );
			} 
			else
			{
				return false;
			}		
		}
		
		/* Object information methods */
		
		public ulong size ()
		{
			return sizeof (double);
		}
		
		public Object get_value ()
		{
			return new PrimitiveWrapper<double?> ( _val );
		}
		
		public void set_value (Object o)
		{
			PrimitiveWrapper<double?> v = (PrimitiveWrapper<double?>) o;
			_val =   v.get_value();
		}
		
		public AplVariableClass get_variableclass ()
		{
			return AplVariableClass.Number;
		}
		
		public string to_string ()
		{
			return _val.to_string();
		}
		
		/* APL Function stubs */
		
		public AplVariable? f_add (AplVariable a) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					PrimitiveWrapper<double?> w = (PrimitiveWrapper<double?>) a.get_value();
					double wv = w.get_value();
					return AplNumberVariable.FromNumber ( wv + _val );
				case AplVariableClass.Matrix:
					return a.f_add ( this );
				default:
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );
			}
		}
		
		public AplVariable? f_subtract ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					PrimitiveWrapper<double?> w = (PrimitiveWrapper<double?>) a.get_value();
					double wv = w.get_value();
					return AplNumberVariable.FromNumber ( _val - wv );
				case AplVariableClass.Matrix:
					AplMatrixVariable m = (AplMatrixVariable) a;
					return m.f_subtract_r ( this );
				default:
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );
			}		
		}
		
		public AplVariable? f_multiply ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					PrimitiveWrapper<double?> w = (PrimitiveWrapper<double?>) a.get_value();
					double wv = w.get_value();
					return AplNumberVariable.FromNumber ( _val * wv );					
				case AplVariableClass.Matrix:
					AplMatrixVariable m = (AplMatrixVariable) a;
					return m.f_multiply_r ( this );
				case AplVariableClass.String:
					PrimitiveWrapper<string?> sw = (PrimitiveWrapper<string?>) a.get_value();
					string s = sw.get_value();
					StringBuilder sb = new StringBuilder();
					for ( int i = 0; i < _val; i++)
						sb.append(s);
					return AplStringVariable.FromString ( sb.str );
				default:
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );
			}
		}
		
		public AplVariable? f_divide ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					PrimitiveWrapper<double?> w = (PrimitiveWrapper<double?>) a.get_value();
					double wv = w.get_value();
					return AplNumberVariable.FromNumber ( _val / wv );					
				case AplVariableClass.Matrix:
					AplMatrixVariable m = (AplMatrixVariable) a;
					return m.f_divide_r ( this );
				default:
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );
			}		
		}
		
		public AplVariable? f_equal ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					PrimitiveWrapper<double?> w = (PrimitiveWrapper<double?>) a.get_value();
					double wv = w.get_value();
					return AplNumberVariable.FromNumber ( ( _val == wv ) ? 1 : 0 );
				case AplVariableClass.Matrix:
					AplMatrixVariable m = (AplMatrixVariable) a;
					return m.f_equal_r ( this );
				default:
					return AplNumberVariable.FromNumber ( 0 );
			}
		}

		public AplVariable? f_lessthan ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					PrimitiveWrapper<double?> w = (PrimitiveWrapper<double?>) a.get_value();
					double wv = w.get_value();
					return AplNumberVariable.FromNumber ( ( _val < wv ) ? 1 : 0 );
				case AplVariableClass.Matrix:
					AplMatrixVariable m = (AplMatrixVariable) a;
					return m.f_lessthan_r ( this );
				default:
					return AplNumberVariable.FromNumber ( 0 );
			}
		}
		
		public AplVariable? f_gtthan ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					PrimitiveWrapper<double?> w = (PrimitiveWrapper<double?>) a.get_value();
					double wv = w.get_value();
					return AplNumberVariable.FromNumber ( ( _val > wv ) ? 1 : 0 );
				case AplVariableClass.Matrix:
					AplMatrixVariable m = (AplMatrixVariable) a;
					return m.f_gtthan_r ( this );
				default:
					return AplNumberVariable.FromNumber ( 0 );
			}
		}
		
		public AplVariable? f_modulus ( AplVariable a ) throws AplInterpreterError
		{
			switch (a.get_variableclass())
			{
				case AplVariableClass.Number:
					PrimitiveWrapper<double?> w = (PrimitiveWrapper<double?>) a.get_value();
					double wv = w.get_value();
					return AplNumberVariable.FromNumber ( ( Math.fmod ( _val, wv ) ) );
				case AplVariableClass.Matrix:
					AplMatrixVariable m = (AplMatrixVariable) a;
					return m.f_modulus_r ( this );
				default:
					throw new AplInterpreterError.InvalidArguments ( "Arguments " + a.get_variableclass().to_string() + " specified to the '+' function are invalid." );
			}
		}
		
		public AplVariable? f_subtract_u ( ) throws AplInterpreterError
		{
			return AplNumberVariable.FromNumber ( (-1)*_val);
		}
	}
}
