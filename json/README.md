# JSON FOR BLITZMAX
An alternative JSON include file for BlitzMaxNG

** NO WARRANTY ** NO GUARANTEE **

STATUS: Experimental

## JSON SUPPORT:
https://www.json.org/json-en.html
* Array: Issues
* Number: Partial
* Object:  Issue with embedded objects
* String: -OK-
* Symbols {}[],:  -OK-
* Whitespace:   -OK-
* "true": OK
* "false": OK
* "Null": OK
* Escaped characters - NOT IMPLEMENTED
* Hexcodes - NOT IMPLEMENTED

## IMPLEMENTATION
* Array:    Array of JNode
* Object:   TMap of JNode
* Number:   JNode
* String:   JNode
* "false":  JNode
* "null":   JNode
* "true":   JNode

* Empty Content ("") - OK (Parsed as "{}")
* Comments: No, not part of specification
* Parse() - A Bit buggy, especially with Arrays!
* Stringify() - OK
* Numbers:
    Integer: Positive and Negative
    Float: OK
    Precision: NOT IMPLEMENTED

## USAGE:
```
include "json.bmx"

const message:string = "{~qid~q:1,~qjsonrpc~q:~q2.0~q,~qmethod~q:~qshutdown~q}"

local J:JNode = JSON.parse( message )

local methd:string = J["method"].tostring()

print "METHOD: "+methd
```

## JSON Functions

Function JSON.Parse:JNode( <string> )

Function JSON.Stringify:String( <JNode> )

## JNode Methods

Method Stringify:String()

Method Operator []:JNode

Method toString:String()

method toInt:int()

method toFloat:float()

method transpose:object( <type-string> )
- Not implemented

method iterator()
- Not Implemented
