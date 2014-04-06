using GLib;
using Gee;
using scientia.apl;
using scientia.Collections;
/*
 * OpenAPL 2011
 * A Modern open source replacement for APL
 * Released under the GNU Public License. 2011.
 * Author: Shaun Campbell
 * Date: 17 May 2011
 * Version: 1.0
 */

namespace scientia.apl
{
	public class AplInterpreter
	{
		/* Instance Variables */
		private AplInterpreter _parent = null;
		private HashMap<string, AplVariable> _vars = new HashMap<string, AplVariable>();
		private HashMap<string, AplUnaryFunction> _unaryfunctions = new HashMap<string, AplUnaryFunction>();
		private HashMap<string, AplBinaryFunction> _binaryfunctions = new HashMap<string, AplBinaryFunction>();
		private static AplInterpreter _instance;
		
		/* Constant Variables */
		public static AplVariable APL_TRUE = AplNumberVariable.FromNumber ( 1 );
		public static AplVariable APL_FALSE = AplNumberVariable.FromNumber ( 0 );
		
		/***
		 * Get the current primary instance of the interpreter
		 ***/
		public static AplInterpreter get_instance ()
		{
			if ( _instance == null )
				_instance = new AplInterpreter(null);
				
			return _instance;
		}
		
		/***
		 * Spawn a new child instance, with this instance as the parent
		 ***/
		public AplInterpreter spawn_child ()
		{
			return new AplInterpreter( this );
		}
		
		/***
		 * Create an new interpreter intance
		 ***/
		public AplInterpreter ( AplInterpreter? parent )
		{
			_parent = parent;
			_vars.set("TRUE", APL_TRUE);
			_vars.set("FALSE", APL_FALSE);
		}
		
		/***
		 * Interpret an expression
		 ***/
		public AplVariable? interpret_line ( SyntaxTree t ) throws AplInterpreterError
		{
			switch ( t.get_expression_class() )
			{
				case AplExpressionClass.Literal:
					return AplNumberVariable.FromNumber ( double.parse( t.get_value () ) );
				case AplExpressionClass.String:
					return AplStringVariable.FromString ( t.get_value () );
				case AplExpressionClass.Matrix:
					return interpret_matrix ( t );
				case AplExpressionClass.VariableName:
					return interpret_variable ( t.get_value() );
				case AplExpressionClass.BinaryFunction:
					return call_binary_function ( t );
				case AplExpressionClass.NullFunction:
					return call_null_function ( t );
				case AplExpressionClass.Import:
					return call_import_module ( t );
				case AplExpressionClass.UnaryFunction:
					return call_unary_function ( t );
				case AplExpressionClass.VariableDeclaration:
					string s 		= t.get_child ( 0 ).get_value ();
					AplVariable av  = interpret_line ( t.get_child ( 1 ) );
					update_variable ( s, av);
					return null;
				case AplExpressionClass.FunctionDeclaration:
					update_function ( t);
					return null;
				case AplExpressionClass.Let:
					AplInterpreter i = this.spawn_child();
                    i.update_variable ( t.get_child(0).get_value (), interpret_line ( t.get_child(1) ) );
                    return i.interpret_line ( t.get_child ( 2 ));
                case AplExpressionClass.Conditional:
               		AplVariable v = interpret_line ( t.get_child ( 0 ) );
               		bool condition = false;
               		switch ( v.get_variableclass () )
               		{
               			case AplVariableClass.Number:
               				AplNumberVariable condition_ex = (AplNumberVariable) v.f_equal ( _vars["TRUE"] );
               				PrimitiveWrapper<double?> pw = (PrimitiveWrapper<double?>) condition_ex.get_value();
               				double w = pw.get_value();
							condition = (w == 1 );
               				break;
               			case AplVariableClass.Matrix:
               				AplMatrixVariable m = (AplMatrixVariable) v;
               				for (int i = 0; i < m.get_rows(); i++)
               				{
               					for (int j=0; j < m.get_columns(); j++)
               					{
               						AplNumberVariable condition_ex = (AplNumberVariable) m.get_item (i, j ).f_equal ( _vars["TRUE"] );
               						PrimitiveWrapper<double?> pw = (PrimitiveWrapper<double?>) condition_ex.get_value();
               						double w = pw.get_value();
               						condition = (w == 1);
               						if ( w == 0)
               							break;
               					}
               					if (condition == false)
               						break;
               				}
               				break;
               			default:
                            throw new AplInterpreterError.InvalidArguments ( "" );
               		}
               		
               		if ( t.get_child_count () == 2 )
               			return ((condition) ? interpret_line (t.get_child( 1 )) : null);
               		else if ( t.get_child_count () == 3 )
               			return ((condition) ? interpret_line (t.get_child(1)) : interpret_line (t.get_child (2)));
      				else
       					throw new AplInterpreterError.InvalidArguments ( "Invalid argument count" );
				default:
					throw new AplInterpreterError.InvalidExpression ("Unable to interpret expression.");
			}			
		}
		
		/***
		 * Interpret a matrix
		 ***/
		public AplVariable? interpret_matrix ( SyntaxTree t ) throws AplInterpreterError
		{
			DLinkList<AplVariable> matrixentries = new DLinkList<AplVariable>();
			foreach ( SyntaxTree child in t.Children )
			{
				matrixentries.add ( this.interpret_line ( child ) );
			}
			
			return AplMatrixVariable.CreateMatrix ( matrixentries );
		}
		
		/***
		 * Assign a variable a new value
		 ***/
		public void update_variable ( string key, AplVariable v )
		{
			_vars.set ( key, v );
		}
		
		/***
		 * Create a new User Defined Function
		 ***/
		public void update_function ( SyntaxTree t )
		{
			if ( t.get_child_count () == 4 )
			{
				string funcName = t.get_child ( 0 ).get_value();
				string arg1 = t.get_child ( 1 ).get_value();
				string arg2 = t.get_child ( 2 ).get_value();
				SyntaxTree expression = t.get_child ( 3 );
				AplBinaryFunction bf = new AplBinaryFunction ( expression, arg1, arg2 );
				_binaryfunctions.set ( funcName, bf );
			}
			else
			{
				string funcName = t.get_child ( 0 ).get_value();
				string arg1 = t.get_child ( 1 ).get_value();
				SyntaxTree expression = t.get_child ( 2 );
				AplUnaryFunction uf = new AplUnaryFunction ( expression, arg1 );
				_unaryfunctions.set ( funcName, uf );		
				stdout.printf ( funcName );		
			}
		}
		/***
		 * Interpret a variable
		 ***/
		public AplVariable? interpret_variable ( string t ) throws AplInterpreterError
		{
			if ( _vars.has_key ( t ) )
			{
				return _vars.get ( t );
			}
			else
			{
				if ( this._parent != null )
					return this._parent.interpret_variable ( t );
				throw new AplInterpreterError.NonExistantVariable ( "The variable '%s' cannot be used before it has been defined".printf ( t ) );
			}
		}		
		
		public AplVariable? call_unary_function ( SyntaxTree t ) throws AplInterpreterError
		{
			string funcName = t.get_value ();
			AplVariable c1 = interpret_line ( t.get_child ( 0 ) );
			if ( funcName == "-" )
				return c1.f_subtract_u ();
			else if (_unaryfunctions.has_key ( funcName ) )
				return _unaryfunctions[funcName].get_value ( this.spawn_child(), c1 );
			else
				throw new AplInterpreterError.FunctionNotDefined ( "The function '%s' cannot be used before it has been defined".printf ( funcName ) );
		}
		
		/***
		 * Call a binary function
		 ***/
		public AplVariable? call_binary_function ( SyntaxTree t ) throws AplInterpreterError
		{
			string funcName = t.get_value ();
			AplVariable c1 = interpret_line ( t.get_child ( 0 ) );
			AplVariable c2 = interpret_line ( t.get_child ( 1 ) );
			if (funcName == "+")
				return c1.f_add ( c2 );
			else if (funcName == "-")
				return c1.f_subtract ( c2 );
			else if (funcName == "x")
				return c1.f_multiply ( c2 );
			else if (funcName == "%")
				return c1.f_divide ( c2 );
			else if (funcName == "mod")
				return c1.f_modulus ( c2 );
			else if (funcName == "=")
				return c1.f_equal ( c2 );
			else if (funcName == ">")
				return c1.f_gtthan ( c2 );
			else if (funcName == "<")
				return c1.f_lessthan ( c2 );
			else if ( _binaryfunctions.has_key ( funcName ) )
				return _binaryfunctions[funcName].get_value ( this.spawn_child(), c1, c2 );
			else
				throw new AplInterpreterError.FunctionNotDefined ( "The function '%s' cannot be used before it has been defined".printf ( funcName ) );
		}
		
		/***
		 * Call a null function
		 ***/
		public AplVariable? call_null_function ( SyntaxTree t ) throws AplInterpreterError
		{
			string funcname = t.get_value();
			if (funcname == "who")
			{
				StringBuilder sb = new StringBuilder();
				sb.append ( "Name\t\tType\t\t\tSize\n");
				foreach (string a in _vars.keys)
				{
					string vc ="";
					switch ( _vars[a].get_variableclass())
					{
						case AplVariableClass.Number:
							vc = "Number\t";
							break;
						case AplVariableClass.String:
							vc = "String\t";
							break;
						case AplVariableClass.Matrix:
							AplMatrixVariable m = (AplMatrixVariable)_vars[a];
							vc = "Matrix (%d x %d)".printf (m.get_rows (),m.get_columns() ) ;
							break;
					}
					sb.append( "%s\t\t%s\t\t%lu\n".printf( a, vc, _vars[a].size() ) );
				}
				return AplStringVariable.FromString ( sb.str );
			}
			throw new AplInterpreterError.FunctionNotDefined ( "The function '%s' cannot be used before it has been defined".printf ( funcname ) );
		}
		
		public AplVariable? call_import_module ( SyntaxTree t ) throws AplInterpreterError
		{
			try
			{
			
				var file = File.new_for_path ( t.get_child ( 0 ). get_value() );	
				if (!file.query_exists ()) 
				{
			    	throw new AplInterpreterError.FileNonExistant ( "File '%s' doesn't exist.\n".printf(file.get_path ()));
				}
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var dis = new DataInputStream (file.read ());
				string line;
				// Read lines until end of file (null) is reached
				while ((line = dis.read_line (null)) != null) 
				{
					AplTokeniser tokeniser = new AplTokeniser ( line );
					AplParser parser = new AplParser ( tokeniser.read_all () );
					interpret_line ( parser.get_expression() );
				}
			}
			catch (GLib.Error ex)
			{
				throw new AplInterpreterError.FileNonExistant ( ex.message );
			}
			return AplStringVariable.FromString("");
		}
	}
}
