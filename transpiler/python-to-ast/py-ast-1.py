import ast  
 
tree = ast.parse("def foo():\n\tprint('Hello!')\n\tprint('again')")
pretty = str( ast.dump(tree) )

pretty = pretty.replace( "(","(\n" )
print( "PRETTY:")
print( pretty)


# Creating AST  
code = ast.parse("print('Welcome To PythonPool')")  
print(code)  
# Printing AST
print(ast.dump(code,indent=4))
# Executing AST
exec(compile(code, filename="", mode="exec"))
