' Cut-down GUI components for testing only

Type COLOR
	Const NONE:Int=0
	Const BORDER:Int=1		' Colour of bounds
	Const SURFACE:Int=2		' Colour of outer (Inside margin, includes padding)
	Const FOREGROUND:Int=3	' Forground colour
	Const VARIANT:Int=4		' Variant Color
	Const CURSOR:Int=5		' Cursor Color (Textbox mostly)
	'
	Const length:Int=6
End Type

Struct SAlign
	Field x:Float = ALIGN_CENTRE
	Field y:Float = ALIGN_MIDDLE

	Method New( x:Float, y:Float )
		Self.x = x
		Self.y = y
	End Method
	
End Struct

' Edges of a components
Struct SEdges
	Field T:Int, R:Int, B:Int, L:Int
	
	Method New( n:Int )
		set( n,  n,  n,  n )
	End Method
	
	Method New( TB:Int, LR:Int )
		set( TB, LR, TB, LR )
	End Method
	
	Method New( T:Int, R:Int, B:Int, L:Int )
		set( T,  R,  B,  L )
	End Method

	Method set( T:Int, R:Int, B:Int, L:Int )
		Self.T = T
		Self.R = R
		Self.B = B
		Self.L = L
	End Method
End Struct

' FLAG functions
Type SFlag
	Field flag:Int
	
	Method New( flag:Int )
		Self.flag = flag
	End Method
	
	Method isSet:Int( mask:Int )
		Return ( flag & mask ) = mask
	End Method
	
	Method set( mask:Int )
		flag :| mask
	End Method
	
	Method unset( mask:Int )
		flag = flag & ~mask
	End Method

	Method isZero:Int()
		Return flag = 0
	End Method

	Method toString:String()
		Return Bin( flag )
	End Method
		
End Type

' Cut-down TWidget that we can use for testing
Type TWidget Implements IStyleable

	Private
	
	Field name:String
	Field caption:String
	Field flags:SFlag = New SFlag()
	Field classlist:TSet<String>				' A bit like "class" in CSS
	Field palette:SColor8[COLOR.length]
	
	Field runstyle:Int = True					' Need to apply style?
	Field stylesheet:TStylesheet
	
	Public

	Method flagset:Int( flag:Int )
		Return flags.isset( flag )
	End Method
	
	Method GetClassList:String[]()
		If Not classlist; Return []
		Return classlist.toArray()
	End Method	
	
	Method GetName:String()
		Return name
	End Method

	' Called by parent to achieve two things
	' 1. Distribute a stylesheet if child doesn't have one
	' 2. Inform child it needs to apply the stylesheet
	Method restyle( style:TStylesheet )
		If Not stylesheet Or stylesheet<> style; stylesheet = style
		stylesheet.apply( Self )
		runstyle = False	' Dont need to re-run until something changes
	End Method
	
	Method setAlignSelf( horz:Float, vert:Float ); End Method
	Method setAlignContent( horz:Float, vert:Float ); End Method

	Method setFlag( flag:Int )
		flags.set( flag )
	End Method

	Method setMargin( edges:SEdges ); End Method
	Method setPadding( edges:SEdges ); End Method
	
	Method setPalette( id:Int, color:SColor8 )
		palette[id] = color
	End Method

	' Sets a stylesheet
	Method setStyle( style:TStylesheet = Null )
		If Not style; style = New TStylesheet()
		If Not stylesheet Or style<>stylesheet
			stylesheet = style
			runstyle = True
		End If
		stylesheet.apply( Self )
	End Method

	Method unsetFlag( flag:Int )
		flags.unset( flag )
	End Method
End Type

Type TLabel Extends TWidget
	
	Method New( caption:String )
		name="MyLabel"
		Self.caption = caption
		setPalette( COLOR.SURFACE, New SColor8( $00007f ) )
	End Method
	
End Type