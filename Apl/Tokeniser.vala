using GLib;
using Gee;
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
	public class AplTokeniser : Iterator<Token<string>>, Iterable<Token<string>>, GLib.Object
	{
		/* Instance Variables */
		private string 	_line;
		private int 	_pos = 0;
		private AplTokenClass	_nextClass;
		private Token<string>	_nextToken;

		/***
		 * Create a new AplTokeniser from a string
		 ***/
		public AplTokeniser (string line)
		{
			this._line = line;
		}

		/***
		 * Check if there are more tokens to come
		 ***/
		public bool has_next ()
		{
			return (_nextClass != AplTokenClass.EOF);
		}

		/***
		 * Get the next token in the iteration
		 ***/
		public new Token<string> get ()
		{
			Token<string> t = new Token<string>( _nextClass, _nextToken.get_content ());		
			return t;
		}

		/***
		 * Move to the next token in the string
		 ***/
		public bool next ()
		{
            if (_pos < _line.length)
                next_node();
            else
                _nextClass = AplTokenClass.EOF;
            return ( _nextClass != AplTokenClass.EOF );
		}

		/***
		 * Move to the first token in the string
 		 ***/
		public bool first()
		{
			_pos = 0;
			next_node ();
			return ( _nextClass != AplTokenClass.EOF);
		}

		/***
		 * Read all tokens into a list
		 ***/
		public DLinkList<Token<string>> read_all ()
		{
			DLinkList<Token<string>> tokens = new DLinkList<Token<string>> ();
			foreach (Token<string> t in this)
			{
				if (t.get_tokenclass() != AplTokenClass.WhiteSpace)
					tokens.add ( t );
			}

			return tokens;
		}
		
		/***
		 * Not used but required to satisfy implementation of Iterable interface
		 ***/
		public void remove ()
		{
			//	Does absolutely nothing
		}

		/***
		 * Internally set the read pointer to the next token
		 ***/
		private void next_node ()
		{
			char c = this._line[_pos];
			StringBuilder sb = new StringBuilder();
			if (c.isupper())
			{
				read_uppercase_string(sb, c);
			}
			else if (c.islower())
			{
				read_lowercase_string(sb, c);
			}
			else if (c.ispunct() && c == '"')
			{
				read_enclosed_string(sb, c);
			}
			else if (c.ispunct())
			{
				read_symbol(sb, c);
			}
			else if (c.isdigit())
			{
				read_numeric_value (sb, c);
			}
			else if (c.isspace())
			{
				read_whitespace(sb, c);
			}
		}

		/* Utility Methods */

		/***
		 * Read an uppercase string as one token
		 ***/
		private void read_uppercase_string (StringBuilder sb, char c)
		{
			//	Continue building a string until a non-uppercase letter is encountered
			while (c.isupper() && this._pos < this._line.length)
			{
				sb.append (c.to_string());
				c = this._line[++this._pos];
			}

			this._nextClass = AplTokenClass.VariableName;
			this._nextToken = new Token<string>(_nextClass, sb.str);
		}

		/***
		 * Read a lowercase string as one token
		 ***/
		private void read_lowercase_string (StringBuilder sb, char c)
		{
			//	Continue building a string until a non-lowercase letter is encountered
			while (c.islower() && this._pos < this._line.length)
			{
				sb.append (c.to_string());
				c = this._line[++this._pos];
			}

			//	Check for keywords
			string s = sb.str;			
			if (s == "if")
				this._nextClass = AplTokenClass.If;
			else if (s == "then")
				this._nextClass = AplTokenClass.Then;
			else if (s == "else")
				this._nextClass = AplTokenClass.Else;
			else if (s == "let")
				this._nextClass = AplTokenClass.Let;
			else if (s == "as")
				this._nextClass = AplTokenClass.As;
			else if (s == "in")
				this._nextClass = AplTokenClass.In;
			else if (s == "function")
				this._nextClass = AplTokenClass.FunctionDeclaration;
			else if (s == "variable")
				this._nextClass = AplTokenClass.VariableDeclaration;
			else if (s == "return")
				this._nextClass = AplTokenClass.FunctionReturn;
			else if (s == "import")
				this._nextClass = AplTokenClass.ImportDeclaration;
			else
				this._nextClass = AplTokenClass.FunctionName;

			this._nextToken = new Token<string>(_nextClass, sb.str);
		}
		/***
		 * Read whitespace as one token
		 ***/
		private void read_whitespace (StringBuilder sb, char c)
		{
			while (c.isspace() && this._pos < this._line.length)
			{
				sb.append (c.to_string());
				c = this._line[++this._pos];
			}
			this._nextClass = AplTokenClass.WhiteSpace;
			this._nextToken = new Token<string>(_nextClass, sb.str);
		}

		/***
		 * Read a string enclosed by quotation marks as one token
		 ***/
		private void read_enclosed_string (StringBuilder sb, char c)
		{
            c = this._line[++_pos];

            while (c != '"' && this._pos < this._line.length)
            {
                sb.append(c.to_string());
                c = this._line[++_pos];
            }

            c = _line[_pos++];
            this._nextClass = AplTokenClass.String;
            this._nextToken = new Token<string>(_nextClass, sb.str);
		}		

		/***
		 * Read a number including decimal point as one token
		 ***/
		private void read_numeric_value (StringBuilder sb, char c)
		{
			while ((c.isdigit() || c == '.') && this._pos < this._line.length)
			{
				sb.append (c.to_string());
				c = this._line[++this._pos];
			}

			this._nextClass = AplTokenClass.Literal;
			this._nextToken = new Token<string>(_nextClass, sb.str);
		}

		/***
		 * Read a symbol character as one token
		 ***/
		public void read_symbol (StringBuilder sb, char c)
		{
			if (c == '(')
				_nextClass = AplTokenClass.LeftBracket;
			else if (c == ')')
				_nextClass = AplTokenClass.RightBracket;
			else if (c == '[')
				_nextClass = AplTokenClass.LeftSquareBracket;
			else if (c == ']')
				_nextClass = AplTokenClass.RightSquareBracket;
			else if (c == '{')
				_nextClass = AplTokenClass.LeftCurlyBracket;
			else if (c == '}')
				_nextClass = AplTokenClass.RightCurlyBracket;
			else if (c == '.')
				_nextClass = AplTokenClass.Operator;
			else if (c == '\\')
				_nextClass = AplTokenClass.Operator;
			else if (c == '|')
				_nextClass = AplTokenClass.FunctionName;
			else if (c == ',')
				_nextClass = AplTokenClass.Operator;
			else if (c == '@')
				_nextClass = AplTokenClass.Operator;
			else if (c == '+')
				_nextClass = AplTokenClass.FunctionName;
			else if (c == '-')
				_nextClass = AplTokenClass.FunctionName;
			else if (c == '*')
				_nextClass = AplTokenClass.FunctionName;
			else if (c == '/')
				_nextClass = AplTokenClass.Operator;
			else
                _nextClass = AplTokenClass.FunctionName;

			this._pos++;
			_nextToken = new Token<string>(this._nextClass, c.to_string());
		}

		/*	Iterable interface */

		/***
		 * Return the type of object held by this list
		 ***/
		public Type element_type
		{
			get { return typeof(Token<string>); }
		}

		/***
		 * Return an iterator so that foreach may be used
		 ***/
		public Iterator<Token<string>> iterator()
		{
			return this;
		}
	}
}
