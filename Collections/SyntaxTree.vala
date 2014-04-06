using GLib;
using scientia.apl;
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
	public class SyntaxTree : GLib.Object
	{
		/* Instance Variables */
		private DLinkList<SyntaxTree> _children = new DLinkList<SyntaxTree>();
		private AplExpressionClass 	  _class;
		private string _value;

		/***
		 * Create a new SyntaxTree object, with a given class and value
		 ***/
		public SyntaxTree ( AplExpressionClass c, string s )
		{
			_value = s;
			_class = c;
		}
		
		/***
		 * Get the value stored with this tree node
		 ***/
		public string get_value()
		{
			return _value;
		}

		/***
		 * Get the class associated with this node
		 ***/
		public AplExpressionClass get_expression_class()
		{
			return _class;
		}

		/***
		 * Set the value stored with this tree node 
		 ***/
		public void set_value (string val)
		{
			_value = val;
		}

		/***
		 * Set the expression class associated with this node
		 ***/
		public void set_expression_class ( AplExpressionClass c )
		{
			_class = c;
		}

		/***
		 * Add a child node with a given class and string
		 ***/
		public void add_child (AplExpressionClass c, string val)
		{
			SyntaxTree child = new SyntaxTree(c, val);
			_children.add(child);
		}

		/***
		 * Attach an existing tree node as a child node to this one
		 ***/
		public void add_child_tree ( SyntaxTree val )
		{
			_children.add(val);
		}

		/***
		 * return child indexed by i
		 ***/
		public SyntaxTree get_child ( int i )
		{
			return _children.get_item ( i );
		}

		/***
		 * get the number of child nodes
		 ***/
		public int get_child_count ( )
		{
			return _children.size();
		}

		/***
		 * Return a list of children nodes
		 ***/
		public DLinkList<SyntaxTree> Children
		{
			get { return _children; }
		}

		/***
		 * Print out the tree, useful for debugging
		 ***/
		public string to_string()
		{
			StringBuilder sb = new StringBuilder();
			sb.append("| ");
			sb.append(this._value);
			sb.append("\n");
			
			foreach (SyntaxTree c in this._children)
				sb.append (c.to_string_child(2));

			return sb.str;
		}

		/***
		 * Recursive print out of the tree, called by to_string()
		 ***/
		private string to_string_child(int level)
		{
			StringBuilder sb = new StringBuilder();
			sb.append("|");
			for (int i = 0; i < level; i++)
				sb.append("-");
			sb.append(" ");
			sb.append(this._value);
			sb.append("\n");
	
			foreach (SyntaxTree c in this._children)
				sb.append(c.to_string_child(level+1));

			return sb.str;
		}


	}
}
