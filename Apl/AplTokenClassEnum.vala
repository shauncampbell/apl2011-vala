namespace scientia.apl
{
	/***
	 * Enum describing various types of AplTokens
	 ***/
	public enum AplTokenClass
	{
		EOF, Literal, String, WhiteSpace, VariableName, 
        VariableDeclaration, LeftBracket, RightBracket,  LeftSquareBracket,
		LeftCurlyBracket, RightCurlyBracket,
        RightSquareBracket, Comma, Operator, If, Then, 
        Else, Let, ImportDeclaration, As, In, FunctionName, FunctionDeclaration, FunctionReturn
	}
}
