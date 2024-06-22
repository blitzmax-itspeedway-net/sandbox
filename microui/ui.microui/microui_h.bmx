
Const MU_VERSION:String = "2.01"

Const MU_COMMANDLIST_SIZE:Int = (256 * 1024)
Const MU_ROOTLIST_SIZE:Int = 32
Const MU_CONTAINERSTACK_SIZE:Int = 32
Const MU_CLIPSTACK_SIZE:Int = 32
Const MU_IDSTACK_SIZE:Int = 32
Const MU_LAYOUTSTACK_SIZE:Int = 16
Const MU_CONTAINERPOOL_SIZE:Int = 48
Const MU_TREENODEPOOL_SIZE:Int = 48
Const MU_MAX_WIDTHS:Int = 16
Const MU_REAL_FMT:String = "%.3g"
Const MU_SLIDER_FMT:String = "%.2f"
Const MU_MAX_FMT:Int = 127

Const MU_CLIP_PART:Int         = 1
Const MU_CLIP_ALL:Int          = 2

' Colours in "SMU_Style.colors[]" array
Const MU_COLOR_TEXT:Int        = 0
Const MU_COLOR_BORDER:Int      = 1
Const MU_COLOR_WINDOWBG:Int    = 2
Const MU_COLOR_TITLEBG:Int     = 3
Const MU_COLOR_TITLETEXT:Int   = 4
Const MU_COLOR_PANELBG:Int     = 5
Const MU_COLOR_BUTTON:Int      = 6
Const MU_COLOR_BUTTONHOVER:Int = 7
Const MU_COLOR_BUTTONFOCUS:Int = 8
Const MU_COLOR_BASE:Int        = 9
Const MU_COLOR_BASEHOVER:Int   = 10
Const MU_COLOR_BASEFOCUS:Int   = 11
Const MU_COLOR_SCROLLBASE:Int  = 12
Const MU_COLOR_SCROLLTHUMB:Int = 13
Const MU_COLOR_MAX:Int         = 14

Const MU_ICON_CLOSE:Int     = 1
Const MU_ICON_CHECK:Int     = 2
Const MU_ICON_COLLAPSED:Int = 3
Const MU_ICON_EXPANDED:Int  = 4
Const MU_ICON_MAX:Int       = 5

Const MU_RES_ACTIVE:Int      = $0000
Const MU_RES_SUBMIT:Int      = $0001
Const MU_RES_CHANGE:Int      = $0002

Const MU_OPT_ALIGNCENTER:Int = $0000
Const MU_OPT_ALIGNRIGHT:Int  = $0001
Const MU_OPT_NOINTERACT:Int  = $0002
Const MU_OPT_NOFRAME:Int     = $0004
Const MU_OPT_NORESIZE:Int    = $0008
Const MU_OPT_NOSCROLL:Int    = $0010
Const MU_OPT_NOCLOSE:Int     = $0020
Const MU_OPT_NOTITLE:Int     = $0040
Const MU_OPT_HOLDFOCUS:Int   = $0080
Const MU_OPT_AUTOSIZE:Int    = $0100
Const MU_OPT_POPUP:Int       = $0200
Const MU_OPT_CLOSED:Int      = $0400
Const MU_OPT_EXPANDED:Int    = $0800

Const MU_MOUSE_LEFT:Int    = $00
Const MU_MOUSE_RIGHT:Int   = $01
Const MU_MOUSE_MIDDLE:Int  = $02

Const MU_KEY_SHIFT:Int     = $00
Const MU_KEY_CTRL:Int      = $01
Const MU_KEY_ALT:Int       = $02
Const MU_KEY_BACKSPACE:Int = $04
Const MU_KEY_RETURN:Int    = $08

'#define mu_min(a, b)            ((a) < (b) ? (a) : (b))
Function mu_min:Int( a:Int, b:Int )
	If a<b; Return a
	Return b
End Function

'#define mu_max(a, b)            ((a) > (b) ? (a) : (b))
Function mu_max:Int( a:Int, b:Int )
	If a>b; Return a
	Return b
End Function

'#define mu_clamp(x, a, b)       mu_min(b, mu_max(a, x))
Function mu_clamp:Int( x:Int, a:Int, b:Int )
	Return mu_min( b, mu_max( a, x ) )
End Function

'#define expect(x) do {                                               \
'    if (!(x)) {                                                      \
'      fprintf(stderr, "Fatal error: %s:%d: assertion '%s' failed\n", \
'        __FILE__, __LINE__, #x);                                     \
'      abort();                                                       \
'    }                                                                \
'  } while (0)
Function expect( value:Int )
	If Not value; RuntimeError( "Fatal error" )
End Function

'#define push(stk, val) do {                                                 \
'    expect((stk).idx < (int) (sizeof((stk).items) / sizeof(*(stk).items))); \
'    (stk).items[(stk).idx] = (val);                                         \
'    (stk).idx++; /* incremented after incase `val` uses this value */       \
'  } while (0)
' # PLEASE USE stk.push( val )

'#define pop(stk) do {      \
'    expect((stk).idx > 0); \
'    (stk).idx--;           \
'  } while (0)
' # PLEASE USE stk.pop( val )

Type TMU_Font
End Type

' This stack is UNPROTECTED
Type TMU_Stack<T>
	Field idx:Int = 0
	Field items:T[]
	
	Method New( n:Int )
		items = New T[n]
	End Method
	
	Method push( n:T )
		items[idx] = n
		idx :+ 1
	End Method
	
	Method pop:T()
		idx :- 1
		Return items[idx+1]
	End Method
	
End Type

Struct SMU_Vec2
	Field x:Int, y:Int
	
	Method New( x:Int, y:Int )
		Self.x = x
		Self.y = y
	End Method
End Struct

Struct SMU_Rect
	Field x:Int, y:Int, w:Int, h:Int
	
	Method New( x:Int, y:Int, w:Int, h:Int )
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
	End Method
End Struct

Struct SMU_PoolItem
	Field id:ULong
	Field last_update:Int
End Struct

Type TCommand
EndType

Type TMU_BaseCommand Extends TCommand
	Field size:Int
EndType

Type TMU_JumpCommand Extends TCommand
	Field base:TMU_BaseCommand
	Field dst()
EndType

Type TMU_ClipCommand Extends TCommand
	Field base:TMU_BaseCommand
	Field rect:SMU_Rect
EndType

Type TMU_RectCommand Extends TCommand
	Field base:TMU_BaseCommand
	Field rect:SMU_Rect
	Field color:SColor8
EndType

Type TMU_TextCommand Extends TCommand
 	Field base:TMU_BaseCommand
	Field font:TMU_Font
	Field pos:SMU_Vec2
	Field color:SColor8
	Field str:String
EndType

Type TMU_IconCommand Extends TCommand
	Field base:TMU_BaseCommand
	Field rect:SMU_Rect
	Field id:Int
	Field color:SColor8
EndType

Struct SMU_Style
	Field font:TMU_Font
	Field size:SVec2D
	Field padding:Int
	Field spacing:Int
	Field indent:Int
	Field title_height:Int
	Field scrollbar_size:Int
	Field thumb_size:Int
	Field colors:SColor8[MU_COLOR_MAX]
EndStruct

Type TMU_Context
	' callbacks
	Field text_width(font:TMU_Font, str:String Var, Len:Int)
	Field text_height:Int( font:TMU_Font )
	Field draw_frame( ctx:TMU_Context, rect:SMU_Rect, colorid:Int)
	' core state
	Field style:SMU_Style
	Field hover:ULong
	Field focus:ULong
	Field last_id:ULong
	Field last_rect:SMU_Rect
	Field last_zindex:Int
	Field updated_focus:Int
	Field frame:Int = 1
	Field hover_root:TMU_Container
	Field next_hover_root:TMU_Container
	Field scroll_target:TMU_Container
	Field number_edit_buf:String[MU_MAX_FMT]
	Field number_edit:ULong
	' stacks
	Field command_list:TMU_stack<Byte> = New TMU_stack<Byte>(0)	'(MU_COMMANDLIST_SIZE)
	Field root_list:TMU_stack<TMU_Container> = New TMU_stack<TMU_Container>(MU_ROOTLIST_SIZE) 
	Field container_stack:TMU_stack<TMU_Container> = New TMU_stack<TMU_Container>(MU_CONTAINERSTACK_SIZE)
	Field clip_stack:TMU_stack<SMU_Rect> = New TMU_stack<SMU_Rect>(MU_CLIPSTACK_SIZE)
	Field id_stack:TMU_stack<ULong> = New TMU_stack<ULong>(MU_IDSTACK_SIZE)
	Field layout_stack:TMU_stack<SMU_Layout> = New TMU_stack<SMU_Layout>(MU_LAYOUTSTACK_SIZE)
	' retained state pools
	Field container_pool:SMU_PoolItem[MU_CONTAINERPOOL_SIZE]
	Field containers:TMU_Container[MU_CONTAINERPOOL_SIZE]
	Field treenode_pool:SMU_PoolItem[MU_TREENODEPOOL_SIZE]
	' Input state
	Field mouse_pos:SMU_Vec2
	Field last_mouse_pos:SMU_Vec2
	Field mouse_delta:SMU_Vec2
	Field scroll_delta:SMU_Vec2
	Field mouse_down:Int
	Field mouse_pressed:Int
	Field key_down:Int
	Field key_pressed:Int
	Field input_text:String
End Type

' A Type is used eher instead of a Struct because we need to check for null
Type TMU_Container
	Field head:TCommand
	Field tail:TCommand
	Field rect:SMU_Rect
	Field body:SMU_Rect
	Field content_size:SMU_Vec2
	Field scroll:SMU_Vec2
	Field zindex:Int
	Field open:Int
	
	' Reset the container to zero
	Method memset:TMU_Container()
		head = Null
		tail = Null
		rect = New SMU_Rect()
		body = New SMU_Rect()
		content_size = New SMU_Vec2()
		scroll = New SMU_Vec2()
		zindex = 0
		open = 0
		Return Self
	End Method
EndType

Struct SMU_Layout
	Field body:SMU_Rect
	Field Next_:SMU_Rect
	Field position:SMU_Vec2
	Field size:SMU_Vec2
	Field Maximum:SMU_Vec2
	Field widths:Int[MU_MAX_WIDTHS]
	Field items:Int
	Field item_index:Int
	Field next_row:Int
	Field next_type:Int
	Field indent:Int
EndStruct
