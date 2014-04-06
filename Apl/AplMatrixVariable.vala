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
	public class AplMatrixVariable : AplVariable, GLib.Object
	{
		delegate AplMatrixVariable binary_call ( AplVariable a );
		delegate AplMatrixVariable unary_call ();
		
		private DLinkList<DLinkList<AplVariable>> _values = new DLinkList<DLinkList<AplVariable>>();
		private int _cols = 0;
		
		public static AplMatrixVariable CreateMatrix ( DLinkList<AplVariable> items ) throws AplInterpreterError
		{
			AplMatrixVariable a = new AplMatrixVariable ( items , items.size() );
			return a;			
		}
		
		public static AplMatrixVariable CreateMatrixS ( DLinkList<AplVariable> items, int size ) throws AplInterpreterError
		{
			AplMatrixVariable a = new AplMatrixVariable ( items , size );
			return a;			
		}
			
		private AplMatrixVariable ( DLinkList<AplVariable> items, int cols ) throws AplInterpreterError
		{
			if (items.size() % cols != 0)
                throw new AplInterpreterError.MatrixSizeInvalid("Invalid Matrix size: All rows and columns of a matrix must be the same size");
                
            _cols = cols;
            DLinkList<AplVariable> curRow = new DLinkList<AplVariable>();
            
            foreach(AplVariable v in items)
            {
                curRow.add ( v );
                if (curRow.size() == cols)
                {
                    _values.add( curRow );
                    curRow = new DLinkList<AplVariable>();
                }
            }
            if (curRow.size() != 0)
                _values.add(curRow);	
		}
		
		public ulong size ( )
		{
			ulong s = 0;
			for ( int i = 0; i < this._values.size(); i++ )
				for ( int j = 0; j < _values.get_item(i).size(); j++)
					s += this.get_item (i, j).size ();
			return s;
		}
		
		public bool equals ( AplVariable b )
		{
			if ( b.get_variableclass() == this.get_variableclass() )
			{
				AplMatrixVariable m = (AplMatrixVariable) b;
				
				for ( int i = 0; i < this._values.size(); i++ )
				{
					for ( int j = 0; j < _values.get_item( i ).size(); j++ )
					{
						if ( !this.get_item ( i , j ).equals ( m.get_item ( i , j ) ) )
							return false;
					}
				}
				return true;
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
				return false;
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
				return false;
			} 
			else
			{
				return false;
			}		
		}
		
		public int get_columns ()
		{
			return _cols;
		}
		
		public int get_rows ()
		{
					return _values.size();
		}
		
		public Object get_value ()
		{
			return _values;
		}
		
		public void set_value (Object o)
		{
			_values = (DLinkList<DLinkList<AplVariable>>) o;
		}
		
		public AplVariableClass get_variableclass ()
		{
			return AplVariableClass.Matrix;
		}
		
		public AplVariable get_item ( int row, int column)
		{
			DLinkList<AplVariable> rowd = _values.get_item ( row );
			return rowd.get_item ( column );
		}
		
		public string to_string ()
		{
        	StringBuilder sb = new StringBuilder();
            foreach (DLinkList<AplVariable> row in _values)
            {
                sb.append("[");
                StringBuilder cb = new StringBuilder();
                foreach (AplVariable col in row)
                {
                    cb.append(col.to_string() + " ");
                }
                string rowstring = cb.str;
                sb.append(rowstring);
                sb.append("]\n");
            }
            return sb.str;
		}
		/* insert here actual operations */
		
		public AplVariable? f_add (AplVariable a) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					switch (a.get_variableclass ())
					{
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable) a;
							if (( this.get_rows() != m.get_rows()) || 
								(this.get_columns() != m.get_columns()))
									throw new AplInterpreterError.MatrixSizeInvalid("");
							items.add ( this.get_item ( i, j ).f_add ( m.get_item (i , j) ) );
							break;
						default:
							items.add ( this.get_item ( i, j ).f_add ( a ) );
							break;
					}
				}
			}
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );							
		}
		
		public AplVariable? f_subtract (AplVariable a) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					switch (a.get_variableclass ())
					{
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable) a;
							if (( this.get_rows() != m.get_rows()) || 
								(this.get_columns() != m.get_columns()))
									throw new AplInterpreterError.MatrixSizeInvalid("");
							items.add ( this.get_item ( i, j ).f_subtract ( m.get_item (i , j) ) );
							break;
						default:
							items.add ( this.get_item ( i, j ).f_subtract ( a ) );
							break;
					}
				}		
			}
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );							
		}
		
		public AplVariable? f_subtract_r ( AplVariable a) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					items.add ( a.f_subtract ( this.get_item ( i, j ) ));
				}
			}	
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );									
		}

		public AplVariable? f_multiply (AplVariable a) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					switch (a.get_variableclass ())
					{
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable) a;
							if (( this.get_rows() != m.get_rows()) || 
								(this.get_columns() != m.get_columns()))
									throw new AplInterpreterError.MatrixSizeInvalid("");
							items.add ( this.get_item ( i, j ).f_multiply ( m.get_item (i , j) ) );
							break;
						default:
							items.add ( this.get_item ( i, j ).f_multiply ( a ) );
							break;
					}
				}		
			}
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );							
		}
		
		public AplVariable? f_multiply_r ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					items.add ( a.f_multiply ( this.get_item ( i, j ) ));
				}
			}	
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );
		}		
		
		public AplVariable? f_divide ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					switch (a.get_variableclass ())
					{
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable) a;
							if (( this.get_rows() != m.get_rows()) || 
								(this.get_columns() != m.get_columns()))
									throw new AplInterpreterError.MatrixSizeInvalid("");
							items.add ( this.get_item ( i, j ).f_divide ( m.get_item (i , j) ) );
							break;
						default:
							items.add ( this.get_item ( i, j ).f_divide ( a ) );
							break;
					}
				}		
			}
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );							
		}
		
		public AplVariable? f_divide_r ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					items.add ( a.f_divide ( this.get_item ( i, j ) ));
				}
			}	
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );
		}			

		public AplVariable? f_equal_r ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					items.add ( a.f_equal ( this.get_item ( i, j ) ));
				}
			}	
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );
		}
		
		public AplVariable? f_equal ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					switch (a.get_variableclass ())
					{
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable) a;
							if (( this.get_rows() != m.get_rows()) || 
								(this.get_columns() != m.get_columns()))
									throw new AplInterpreterError.MatrixSizeInvalid("");
							items.add ( this.get_item ( i, j ).f_equal ( m.get_item (i , j) ) );
							break;
						default:
							items.add ( this.get_item ( i, j ).f_equal ( a ) );
							break;
					}
				}		
			}
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );							
		}

		public AplVariable? f_lessthan ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					switch (a.get_variableclass ())
					{
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable) a;
							if (( this.get_rows() != m.get_rows()) || 
								(this.get_columns() != m.get_columns()))
									throw new AplInterpreterError.MatrixSizeInvalid("");
							items.add ( this.get_item ( i, j ).f_lessthan ( m.get_item (i , j) ) );
							break;
						default:
							items.add ( this.get_item ( i, j ).f_lessthan ( a ) );
							break;
					}
				}		
			}
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );							
		}
		
		public AplVariable? f_lessthan_r ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					items.add ( a.f_lessthan ( this.get_item ( i, j ) ));
				}
			}	
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );
		}		
		public AplVariable? f_gtthan ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					switch (a.get_variableclass ())
					{
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable) a;
							if (( this.get_rows() != m.get_rows()) || 
								(this.get_columns() != m.get_columns()))
									throw new AplInterpreterError.MatrixSizeInvalid("");
							items.add ( this.get_item ( i, j ).f_gtthan ( m.get_item (i , j) ) );
							break;
						default:
							items.add ( this.get_item ( i, j ).f_gtthan ( a ) );
							break;
					}
				}		
			}
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );							
		}

		public AplVariable? f_gtthan_r ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					items.add ( a.f_gtthan ( this.get_item ( i, j ) ));
				}
			}	
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );
		}
		public AplVariable? f_modulus ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					switch (a.get_variableclass ())
					{
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable) a;
							if (( this.get_rows() != m.get_rows()) || 
								(this.get_columns() != m.get_columns()))
									throw new AplInterpreterError.MatrixSizeInvalid("");
							items.add ( this.get_item ( i, j ).f_modulus ( m.get_item (i , j) ) );
							break;
						default:
							items.add ( this.get_item ( i, j ).f_modulus ( a ) );
							break;
					}
				}		
			}
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );							
		}
		
		public AplVariable? f_modulus_r ( AplVariable a ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					items.add ( a.f_modulus ( this.get_item ( i, j ) ));
				}
			}	
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );
		}
		
		public AplVariable? f_subtract_u ( ) throws AplInterpreterError
		{
			DLinkList<AplVariable> items = new DLinkList<AplVariable>();
			for ( int i = 0; i < this.get_rows(); i++ )
			{
				for ( int j = 0; j < this.get_columns(); j++ )
				{
					items.add ( this.get_item ( i, j ).f_subtract_u () );
				}
			}	
			return AplMatrixVariable.CreateMatrixS ( items, this.get_columns() );
		}			
	}
}
