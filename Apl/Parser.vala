using GLib;
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
	public class AplParser : GLib.Object
	{
		/* Instance Variables */
		private DLinkList<Token<string>> _tokens;
		private int _pos;

		/***
		 * Create a new parser object from a list of tokens
		 ***/
        public AplParser(DLinkList<Token<string>> tokens)
        {
            _tokens = tokens;
        }

		/***
		 * Parse the tokens into an abstract syntax tree
		 ***/
        public SyntaxTree get_expression() throws AplParseError
        {
			/* Using the current token ( token at position _pos )
			 * The function switches on the token type and then performs
			 * Some kind of check to see what proceeds the given token
			 * Based on that decision the correct get_X is invoked
			 */

            switch ( _tokens.get_item( _pos ).get_tokenclass() )
			{
				case AplTokenClass.Literal:
					if ( ( _tokens.size() - _pos ) == 1 )
						return get_atomic_expression ();
					else
						return get_binary_function ();

				case AplTokenClass.String:
					if ( ( _tokens.size() - _pos ) == 1 )
						return get_atomic_expression ();
					else
						return get_binary_function ();
	
				case AplTokenClass.LeftSquareBracket:
					/* Brackets are a little awkward, because we have to first loop to
					 * the end of the bracketed expression before we can determine what comes next
					 */
					int initialPos = _pos;
					while ( _pos < _tokens.size () && ( _tokens.get_item ( _pos ).get_tokenclass() != AplTokenClass.RightSquareBracket ))
						_pos++;
				
					if ( _pos < _tokens.size () )
					{
						_pos = initialPos;
						return get_binary_function ();
					}
					_pos = initialPos;
					return get_atomic_expression ();
				
				case AplTokenClass.LeftBracket:
					int j = _pos;
					int leftbrackets = 0;
					while ( j < _tokens.size() )
					{
						if (_tokens.get_item (j).get_tokenclass() == AplTokenClass.RightBracket && leftbrackets == 1)
							break;
						else if ( _tokens.get_item (j).get_tokenclass() == AplTokenClass.RightBracket)
							leftbrackets--;
						else if ( _tokens.get_item (j).get_tokenclass() == AplTokenClass.LeftBracket)
							leftbrackets++;
						j++;
					}
					if (leftbrackets > 1)
						throw new AplParseError.UNTERMINATED_PARENTHESIS(get_error_msg ( _pos, "An unterminated parenthesis was detected") );
					
					j++;
					if ( j == _tokens.size() )
					{
						return get_precedence_expression ();
					}
					else
					{
						return get_binary_function ();
					}

				case AplTokenClass.FunctionName:
					if ( ( _tokens.size() - _pos ) > 1 )
						return get_unary_function ();
					else
						return get_null_function ();

				case AplTokenClass.VariableName:
					if ( ( _tokens.size() - _pos ) == 1 )
						return get_atomic_expression ();
					else
						return get_binary_function ();

				case AplTokenClass.Let:
					return get_let_expression ();

				case AplTokenClass.If:
					return get_conditional_expression ();
					
				case AplTokenClass.VariableDeclaration:
					return get_variable_declaration ();
					
				case AplTokenClass.Operator:
					return get_operator_expression ();
				
				case AplTokenClass.FunctionDeclaration:
					return get_function_declaration ();
					
				case AplTokenClass.ImportDeclaration:
					return get_import_declaration ();
			}
			throw new AplParseError.INVALID_SYNTAX ("Unable to parse given expression.");
		}

		public SyntaxTree get_import_declaration () throws AplParseError
		{
			// skip the "import" token
			_pos++;
			SyntaxTree path = new SyntaxTree ( AplExpressionClass.String, _tokens.get_item (_pos++).get_content() );
			SyntaxTree t = new SyntaxTree ( AplExpressionClass.Import, "import" );
			t.add_child_tree ( path );
			return t;
		}
		/***
		 * Parse an atomic expression
		 ***/
		public SyntaxTree get_atomic_expression () throws AplParseError
		{
			switch ( _tokens.get_item( _pos ).get_tokenclass() )
			{
				case AplTokenClass.Literal:
					return new SyntaxTree ( AplExpressionClass.Literal, _tokens.get_item ( _pos++ ).get_content() );
				case AplTokenClass.String:
					return new SyntaxTree ( AplExpressionClass.String, _tokens.get_item ( _pos++ ).get_content() );
				case AplTokenClass.LeftSquareBracket:
					return get_matrix_expression ();
				case AplTokenClass.LeftBracket:
					return get_precedence_expression ();
				case AplTokenClass.VariableName:
					return get_variable_name ();
			}
			throw new AplParseError.INVALID_SYNTAX ( get_error_msg ( _pos, "Unable to parse given atomic expression." ) );
		}
		
		public SyntaxTree get_variable_name () throws AplParseError
		{
			return new SyntaxTree (AplExpressionClass.VariableName, _tokens.get_item (_pos++).get_content());
		}

		/***
		 * Parse a precedence expression
		 ***/
		public SyntaxTree get_precedence_expression () throws AplParseError
		{
			DLinkList<Token<string>> newTokens = new DLinkList<Token<string>>();
			int posInit = ++_pos;
			int leftBracks = 0;
			while  ( posInit < _tokens.size() )
			{
				if ( _tokens.get_item(posInit).get_tokenclass () == AplTokenClass.RightBracket && leftBracks == 0 )
					break;
				else if ( _tokens.get_item(posInit).get_tokenclass () == AplTokenClass.RightBracket )
					leftBracks--;
				else if ( _tokens.get_item(posInit).get_tokenclass () == AplTokenClass.LeftBracket )
					leftBracks++;
				
				newTokens.add ( _tokens.get_item (posInit) );
				posInit++;
			}
			
			if (leftBracks > 0)
				throw new AplParseError.UNTERMINATED_PARENTHESIS ( get_error_msg ( _pos, "An unterminated parenthesis was detected") );
            _pos = ++posInit;
			AplParser p = new AplParser(newTokens);
			return p.get_expression();
		}

		/***
		 * Parse a matrix expression
		 ***/
		public SyntaxTree get_matrix_expression () throws AplParseError
		{
			SyntaxTree new_matrix = new SyntaxTree ( AplExpressionClass.Matrix, "matrix" );
			_pos++;
			while ( _pos < _tokens.size () && (_tokens.get_item ( _pos ).get_tokenclass() != AplTokenClass.RightSquareBracket ) )
			{
				new_matrix.add_child_tree ( get_atomic_expression () );
			}
			_pos++;
			return new_matrix;
		}

		/***
		 * Parse a binary function expression
		 ***/
		public SyntaxTree get_binary_function () throws AplParseError
		{
			if ( ( _tokens.size() - _pos ) < 3 )
				throw new AplParseError.INVALID_SYNTAX ( get_error_msg ( _pos, "A Binary function must have exactly two arguments" ) );
			
			SyntaxTree tree_left = get_atomic_expression ();
			SyntaxTree tree_main = new SyntaxTree ( AplExpressionClass.BinaryFunction, _tokens.get_item ( _pos++ ).get_content() );
			
			//	If a square bracket has wrongly been detected as a function
			//	Then exit now and return the atomic value only
			if ( tree_main.get_value () == "]" )
				return tree_left;

			SyntaxTree tree_right = get_expression ();

			//	If this function is the product of an operator then this must be evaluated
			if ( tree_right.get_expression_class() == AplExpressionClass.Operator )
			{
				SyntaxTree tree_o 		 = new SyntaxTree ( AplExpressionClass.Operator, tree_right.get_value () );
				SyntaxTree tree_o_fleft  = new SyntaxTree ( AplExpressionClass.OperatorFunctionArgument, tree_main.get_value () ); 
				SyntaxTree t = tree_right.get_child ( 0 );				
				SyntaxTree tree_o_fright = new SyntaxTree ( AplExpressionClass.OperatorFunctionArgument, t.get_value () );
				SyntaxTree tree_o_vleft  = tree_left;
				SyntaxTree tree_o_vright =  t.get_child ( 0 );
				
				tree_o.add_child_tree ( tree_o_fleft);
				tree_o.add_child_tree ( tree_o_fright);
				tree_o.add_child_tree ( tree_o_vleft);
				tree_o.add_child_tree ( tree_o_vright);
			
				return tree_o;
			}

			tree_main.add_child_tree ( tree_left );
			tree_main.add_child_tree ( tree_right );
			
			return tree_main;
		}
		/***
		 * Parse a unary function expression
		 ***/		
		public SyntaxTree get_unary_function () throws AplParseError
		{
			if ( ( _tokens.size() - _pos ) < 2 )
				throw new AplParseError.INVALID_SYNTAX ( get_error_msg ( _pos, "A Binary function must have exactly two arguments" ) );
			
			SyntaxTree tree_main = new SyntaxTree ( AplExpressionClass.UnaryFunction, _tokens.get_item ( _pos++ ).get_content() );
			SyntaxTree tree_right = get_expression ();

			tree_main.add_child_tree ( tree_right );

			return tree_main;
		}
		
		public SyntaxTree get_null_function () throws AplParseError
		{
			SyntaxTree tree = new SyntaxTree ( AplExpressionClass.NullFunction, _tokens.get_item ( _pos++ ).get_content () );
			return tree;
		}
		
		/***
		 * Parse an operator expression
		 ***/
		public SyntaxTree get_operator_expression () throws AplParseError
		{
			if ( ( _tokens.size() - _pos ) < 3 )
				throw new AplParseError.INVALID_SYNTAX ( get_error_msg ( _pos, "A Unary function must have at least one argument") );
			
			SyntaxTree tree_main = new SyntaxTree ( AplExpressionClass.Operator, _tokens.get_item ( _pos++ ).get_content () );
			SyntaxTree tree_right = get_unary_function ();
			
			tree_main.add_child_tree ( tree_right );
			return tree_main;			
		}
		
		public SyntaxTree get_variable_declaration () throws AplParseError
		{
			if ( ( _tokens.size() - _pos ) < 4 )
				throw new AplParseError.INVALID_SYNTAX ( "Invalid usage of 'variable'. \nUsage: variable <variable name> as <expression>." );
			_pos++;
            SyntaxTree varName = get_variable_name();
            if ( _tokens.get_item( _pos ).get_tokenclass() != AplTokenClass.As )
            	throw new AplParseError.INVALID_SYNTAX ( get_error_msg ( _pos, "Specified variable name is invalid") );
            _pos++;
            SyntaxTree expr = get_expression();

            SyntaxTree b = new SyntaxTree(AplExpressionClass.VariableDeclaration, "variable");
            b.add_child_tree (varName);
            b.add_child_tree (expr);
            
            return b;
		}
		
		public SyntaxTree get_function_declaration () throws AplParseError
		{
			string usage = "Invalid usage of 'function'. \nUsage: function <function name> <variable1> [<variable2>] as <expression>";
			
            if ((_tokens.size() - _pos) < 4)
                throw new AplParseError.INVALID_SYNTAX ( usage );
                
            SyntaxTree b = new SyntaxTree(AplExpressionClass.FunctionDeclaration, "function");
            _pos++;
            //	Check that the function has a name
            if ( _tokens.get_item (_pos).get_tokenclass () != AplTokenClass.FunctionName )
            	throw new AplParseError.INVALID_SYNTAX ( get_error_msg ( _pos, "Invalid function name specified" ));
          
            SyntaxTree funcName = get_null_function();
            b.add_child_tree (funcName);
            
            //	Check that there is at least one argument specified
            if (_tokens.get_item (_pos).get_tokenclass () != AplTokenClass.VariableName)
            	throw new AplParseError.INVALID_SYNTAX( get_error_msg ( _pos, "At least one variable name was expected here") );
            	
            SyntaxTree var1 = get_variable_name();
            b.add_child_tree (var1);

          	//	If the next token is a variable name then this is a binary function 
            if (_tokens.get_item (_pos).get_tokenclass () == AplTokenClass.VariableName)
            {
            	SyntaxTree var2 = get_variable_name();
            	b.add_child_tree ( var2 );
            } 
            
            //	If the As token is missing, then throw an error
            if (_tokens.get_item (_pos).get_tokenclass() != AplTokenClass.As )
            {
            	throw new AplParseError.INVALID_SYNTAX ( get_error_msg (_pos, usage) );
            }
            
            _pos++;
            SyntaxTree expr = get_expression();
            b.add_child_tree(expr);
            return b;		
		}
		
		public string get_error_msg ( int token, string msg )
		{
			StringBuilder sb = new StringBuilder ();
			sb.append ( "Parse Error: %s.\n Error Occurred at Token %d\n ^".printf ( msg, token ) );
			for (int i = token; i < _tokens.size(); i++)
				sb.append ( "%s ".printf ( _tokens.get_item ( i ).get_content() ) );	
			return sb.str;
		}
	
		public SyntaxTree get_let_expression () throws AplParseError
		{
			if ( ( _tokens.size() - _pos ) < 6 )
				throw new AplParseError.INVALID_SYNTAX ( "Invalid usage of 'let'. \nUsage: let <variable> as <value> in <expression>" );
		
			_pos++; // skip the let token
			SyntaxTree variable_name = get_variable_name ();
			if ( _tokens.get_item ( _pos ).get_tokenclass() != AplTokenClass.As )
				throw new AplParseError.INVALID_SYNTAX ( get_error_msg ( _pos, "Specified variable name is not valid" ));
			_pos++; // skip the as token
			SyntaxTree variable_value = get_atomic_expression ();
			if ( _tokens.get_item ( _pos ).get_tokenclass() != AplTokenClass.In )
				throw new AplParseError.INVALID_SYNTAX ( get_error_msg ( _pos, "Specified value is not valid" ) );
			_pos++; // skip the in token
			SyntaxTree expression = get_expression ();

			SyntaxTree main = new SyntaxTree ( AplExpressionClass.Let, "let" );
			main.add_child_tree ( variable_name );
			main.add_child_tree ( variable_value );
			main.add_child_tree ( expression );

			return main;
		}		
		
		/***
		 * Parse a conditional expression
		 ***/
		public SyntaxTree get_conditional_expression () throws AplParseError
		{
            SyntaxTree b;

            //  Calculate the If condition expression
            DLinkList<Token> newTokens = new DLinkList<Token>();
            _pos++;
            while ( _pos < _tokens.size () )
            {
                Token t = _tokens.get_item( _pos++ );
                if (t.get_tokenclass() != AplTokenClass.Then)
                    newTokens.add ( t );
                else
                    break;
            }
            AplParser p = new AplParser(newTokens);
            SyntaxTree ifcondition = p.get_expression ();
            //  Calculate the then expression
            newTokens = new DLinkList<Token>();
          //  _position++;
            while ( _pos < _tokens.size() )
            {
                Token t = _tokens.get_item( _pos++ );
                if (t.get_tokenclass() != AplTokenClass.Else)
                    newTokens.add ( t );
                else
                    break;
            }
            AplParser q = new AplParser(newTokens);
            SyntaxTree thenExpression = q.get_expression ();
            //  Check if we have an else expression
            if ( _pos < _tokens.size() )
            {
                b = new SyntaxTree(AplExpressionClass.Conditional, "conditional");
                newTokens = new DLinkList<Token>();
                while (_pos < _tokens.size() )
                {
                    Token t = _tokens.get_item (_pos++);
                    newTokens.add(t);
                }
                AplParser r = new AplParser(newTokens);
                SyntaxTree elseCondition = r.get_expression ();
                b.add_child_tree (ifcondition);
                b.add_child_tree (thenExpression);
                b.add_child_tree (elseCondition);
            }
            else
            {
                b = new SyntaxTree(AplExpressionClass.Conditional, "ifthenexpression");
                b.add_child_tree (ifcondition);
                b.add_child_tree (thenExpression);
            }
            
            return b;
		}
	}
}
