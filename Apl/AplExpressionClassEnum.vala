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
	/***
	 * Enum describing various types of AplExpressions
	 ***/
	public enum AplExpressionClass
	{
		Literal, String, Matrix, BinaryFunction, UnaryFunction, NullFunction, VariableName, Operator, OperatorFunctionArgument,
		Let, Conditional, VariableDeclaration, FunctionDeclaration, Import
	}
}
