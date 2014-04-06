namespace scientia.apl
{
	public errordomain AplTokenisationError
	{
		IndexOutOfRange
	}

	public errordomain AplParseError
	{
		INVALID_SYNTAX, UNTERMINATED_PARENTHESIS
	}
	
	public errordomain AplInterpreterError
	{
		MatrixSizeInvalid, InvalidArguments, InvalidExpression, NonExistantVariable, FileNonExistant, FunctionNotDefined
	}
}
