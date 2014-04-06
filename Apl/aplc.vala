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
	public class aplc
	{
		private static int cl_flags 		= 0x00;
		private static int cl_flag_compile 	= 0x01;
		private static int cl_flag_express 	= 0x02;
		private static int cl_flag_tree 	= 0x04;
		private static DLinkList<string> params;

		public static int main (string[] args)
		{
			params = new DLinkList<string> ();
			for (int i = 1; i < args.length; i++)
			{
				string s = args[i];
				if ( s[0] == '-' )
				{
					if ( s[1] == 'c' )
						cl_flags |= cl_flag_compile;
					else if ( s[1] == 'e' )
						cl_flags |= cl_flag_express;
					else if ( s[1] == 't' )
						cl_flags |= cl_flag_tree;
				}
				else
				{
					params.add ( s );
				}
				
			}

			try
			{
				if ( ( cl_flags & cl_flag_express ) == cl_flag_express )
					expression_mode ();
				else if ( params.size() == 0 )
					interactive_mode ();
				else
					static_mode ();
			}
			catch (AplParseError e)
			{
				stderr.printf ("An error occurred whilst parsing the line '%s'\n", e.message);
			}
			catch (AplInterpreterError e)
			{
				stderr.printf ("An error occured whilst interpreting the line '%s'\n", e.message);
			}
			catch (GLib.IOError e)
			{
				stderr.printf ( "Unable to open file: '%s' ", e.message );
			}
			catch (GLib.Error e)
			{
				stderr.printf ( "Unable to open file: '%s' ", e.message );
			}
			return 0;
		}
		
		/***
		 * Runs the interpreter to execute one specific expression
		 ***/
		public static void expression_mode () throws AplParseError, AplInterpreterError
		{
				StringBuilder sb = new StringBuilder();
				foreach ( string s in params )
					sb.append ( s );
				
					string l = interpret_line ( sb.str );
					if ( l != "")
						stdout.printf ( "%s\n", l );					
		}

		/***
		 * Run the interpreter to execute the code contained within a file
		 ***/
		public static void static_mode () throws AplParseError, AplInterpreterError, GLib.IOError, GLib.Error
		{
			foreach ( string s in params )
			{
				var file = File.new_for_path ( s );	
 				if (!file.query_exists ()) 
				{
				        stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
				}
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var dis = new DataInputStream (file.read ());
				string line;
				// Read lines until end of file (null) is reached
				while ((line = dis.read_line (null)) != null) 
				{
					string l = interpret_line ( line );
					if ( l != "")
						stdout.printf ( "%s\n", l );					
				}
			}
		}
		
		/***
		 * Interpret one specific line, and output the result to a string
		 ***/
		public static string interpret_line ( string line ) throws AplParseError, AplInterpreterError
		{
			//	Parse the line into tokens
			AplTokeniser 		 tokeniser 	= new AplTokeniser(line);
			DLinkList<Token<string>> tokens 	= tokeniser.read_all ();

			AplParser parser = new AplParser ( tokens );
			SyntaxTree tree = parser.get_expression();
			if ( ( cl_flags & cl_flag_tree ) == cl_flag_tree )
				stdout.printf ( "Execution Tree:\n%s\n",tree.to_string() );
			
			AplInterpreter interpreter = AplInterpreter.get_instance();
			AplVariable v = interpreter.interpret_line ( tree );
			if ( v != null)
				return v.to_string();
			else
				return "";

		}
		
		/***
		 * Enable interactive console mode
		 ***/
		public static void interactive_mode () throws AplParseError, AplInterpreterError
		{
			string? line;
			stdout.printf ("APL2011 v1.0-vala\n");
			stdout.printf ("Compiled: 19-May-2011 at 14:46\n");		
			
			stdout.printf ("> ");		
		    while ((line = stdin.read_line ()) != "exit")
			{
				try
				{
					string l = interpret_line ( line );
					if ( l != "")
						stdout.printf ( "%s\n", l );										
				}
				catch (AplParseError ex)
				{
					stderr.printf ( "%s\n", ex.message );
				}
				catch (AplInterpreterError ex)
				{
					stderr.printf ( "%s\n", ex.message );
				}
				finally
				{
					stdout.printf( "> ");				
				}
			}

		}
	}
}
