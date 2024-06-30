# TYPEGUI

** WARNING **

This is experimental and is not fit for production
Use at your own risk

Please let me know if you find any bugs, extend, add or improve this code.

# FEATURES

| FEATURE | TYPE-GUI | INSPECTOR | MANUAL |
|---------|----------|-----------|--------|
| LABEL   | Method-based rendering | Composition-based widgets | Not implemented |
| BUTTON  | Method-based rendering, Bug in multi-button | Not implemented  | Not implemented |
| TEXTBOX | Method-based rendering | Not implemented  | Not implemented |

* Create gui from a type - EXPERIMENTAL
* Create object inspector - EXPERIMENTAL
* Load/Save GUI - NOT IMPLEMENTED
* Manual GUI creation - NOT IMPLEMENTED

# KNOWN BUGS
* Type-GUI multi-Buttons do not work
* Metadata attributes need to be standardised 

# METADATA ATTRIBUTES

| TAG       | DEFAULT    | STATE       | DESCRIPTION |
|-----------|------------|-------------|---|
| label=    | Field name | ACTIVE      | Text to display instead of field name |
| length=   | n/a        | ACTIVE      | Length of edit field |
| options=  | n/a        | n/a         | Options used in radio button group |
| disable   | 1 = True   | ACTIVE      | Disables a widget |
| readonly  | 1 = True   | ACTIVE      | Field cannto be edited |
| length=   | n/a        | ACTIVE      | Length of edit field |
| separator | 1 =        | ACTIVE      | Displays a horizontal line |
| ignore    | 1 = True   | n/a         | To ignore a field in Type-GUI; do not add provide any metadata to ignore |

# METADATA DATATYPES

| TAG       | BMX-TYPE | STATE       | DESCRIPTION |
|-----------|----------|-------------|---|
| textbox   | String   | DEPRECIATED | Use type= | 
| password  | String   | DEPRECIATED | Use type= |
| radio=    | Int      | DEPRECIATED | Use type= | Options found in meta options=
| checkbox  | Int      | DEPRECIATED | Use type= |
| button    | String   | DEPRECIATED | Display a button. Caption is taken from string value |
| button    | String[] | DEPRECIATED | Display a set of buttons. Caption is taken from string values |

| TAG              | BMX-TYPE | VALUE      | STATE  | DESCRIPTION |
|------------------|----------|------------|---| |
| type="textbox"   | String   | Text       | n/a | | 
| type="password"  | String   | Text       | n/a |  |
| type="radio"     | Int      | Option     | n/a | |
| type="checkbox"  | Int      | True/False | n/a | |
| type="separator" |          | n/a        | n/a | Displays a horizontal line |
| type="button"    | String   | Caption    | n/a | Display a button. Caption is taken from string value |
| type="button"    | String[] | Caption    | n/a | Display buttons. Captions taken from string values |
| type="slider"    | Int      | Position   | n/a | |

# EXAMPLES

** Creating a GUI from a type **
<example required>

** Inspecting an object
<example required>

** Manual GUI **
<example required>

# LIMITATIONS

* Reflection cannot deal with fields of the following types
    - Struct
    - Enum
    - Interface

* Global fields are currently not included in the field list
    (There is also a known bug in obtaining metadata from a global field)

* Fields of super types are not evaluated

* The following widgets are supported:

    LABEL       Inspector
