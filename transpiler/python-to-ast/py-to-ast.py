import ast, codecs, json, os, sys
from _ast import AST

def tojson( node ):

    result = dict()
    result[ 'type' ] = node.__class__.__name__
    for attr in dir(node):
        if not attr.startswith( "_" ):
            result[ attr ] = extract( getattr( node, attr ) )
    return result

def extract( element ):
    if element is None:
        return element 
    if isinstance( element, AST ):
        return tojson( element )
    if isinstance( element, (complex) ):
        return str( element ) 
    if isinstance( element, (bytearray, bytes) ):
        try:
            return element.decode( 'utf-8' )
        except Exception as e:
            result = codecs.getencoder( 'hex_codec' )( element )[0]
            return result.decode( 'utf-8' )
    if isinstance( element, (int, float, bool, str) ):
        return element 
    if isinstance( element, (list) ):
        return [extract(n) for n in element]    
    # Thanks to "Joe_H" for this one :)
    if isinstance( element, type(Ellipsis) ):
        return '...'
    raise Exception( "Node '%s:%s' failed", ( element, type( element ) ) )

if __name__ == "__main__":

    #   VALIDATION

    if len(sys.argv) < 2:
        print( "Please provide a filename to parse" )
        os.quit()

    if len( sys.argv ) > 3:
        print( "Invalid arguments" )
        os.quit()

    if not os.path.isfile( sys.argv[1] ):
        print( "File not found" )
        os.quit()

    if sys.version_info.major != 3:
        print( "Python3 required" )
        os.quit()

    #   READ SOURCE

    with open( sys.argv[1], 'r') as file:
        source = file.read()

    #   PARSE TO AST

    print( "Parsing '"+sys.argv[1]+"' ("+str(len(source))+" bytes)" )
    tree = ast.parse( source )

    #   AST TO TEXT

    if len( sys.argv ) == 3 and sys.argv[2] == "--text":
        text = str( ast.dump(tree) )
        filetype = ".txt"
    else:
        text = json.dumps( tojson( tree ), indent=4 )
        filetype = ".json"

    #   WRITE TO FILE

    filename = os.path.splitext(os.path.basename(sys.argv[1]))[0] + filetype
    with open( filename, 'w') as file:
        file.write( text )


