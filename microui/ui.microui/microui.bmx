Rem
ORIGINAL MICROUI.C COPYRIGHT NOTICE

** Copyright (c) 2020 rxi
**
** Permission is hereby granted, free of charge, To any person obtaining a copy
** of this software And associated documentation files (the "Software"), To
** deal in the Software without restriction, including without limitation the
** rights To use, copy, modify, merge, publish, distribute, sublicense, And/Or
** sell copies of the Software, And To permit persons To whom the Software is
** furnished To do so, subject To the following conditions:
**
** The above copyright notice And this permission notice shall be included in
** all copies Or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS Or
** IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES OF MERCHANTABILITY,
** FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS Or COPYRIGHT HOLDERS BE LIABLE For ANY CLAIM, DAMAGES Or OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT Or OTHERWISE, ARISING
** FROM, OUT OF Or IN CONNECTION WITH THE SOFTWARE Or THE USE Or OTHER DEALINGS
** IN THE SOFTWARE.

CONVERTED TO BLITZMAX BY SI DUNFORD, JUNE 2024
* Enums replaced with constants
* Struct names prefixed with "S"
* Replaced Struct mu_Color with SColor8
* Replaced mu_id with ULong (instead of UInt)
* Replaced Struct mu_command with TCommand
* Replaced Struct mu_BaseCommand with Type extending TCommand
* Replaced Struct mu_JumpCommand with Type extending TCommand
* Replaced Struct mu_ClipCommand with Type extending TCommand
* Replaced Struct mu_RectCommand with Type extending TCommand
* Replaced Struct mu_TextCommand with Type extending TCommand
* Replaced Struct mu_IconCommand with Type extending TCommand
* Replaced Struct mu_Container with Type (because we need to check for NULL)
* Replaced Struct mu_Context with a Type due to Struct pointer forwarding.. (Weird issue)
* Re-wrote #define mu_stack as Generic-based Type
* Re-wrote #define mu_min as a function
* Re-wrote #define mu_max as a function
* Re-wrote #define mu_clamp as a function
* Re-wrote hash() because I couldn't get the pointer thinsg to work!
* Created iif.bmx library
* Removed argument size from mu_get_id() and hash()
* Added mu_Container.memset() to replace memset(cnt)
* Replaced expect() with assert()
muFont
End Rem

Import math.vector

Include "microui_h.bmx"
Include "iif.bmx"

Rem
#define unused(x) ((void) (x))

#define expect(x) do {                                               \
    If (!(x)) {                                                      \
      fprintf(stderr, "Fatal error: %s:%d: assertion '%s' failed\n", \
        __FILE__, __LINE__, #x);                                     \
      abort();                                                       \
    }                                                                \
  } While (0)

#define push(stk, val) do {                                                 \
    expect((stk).idx < (Int) (SizeOf((stk).items) / SizeOf(*(stk).items))); \
    (stk).items[(stk).idx] = (val);                                         \
    (stk).idx++; /* incremented after incase `val` uses this value */       \
  } While (0)

#define pop(stk) do {      \
    expect((stk).idx > 0); \
    (stk).idx--;           \
  } While (0)


static mu_Rect unclipped_rect = { 0, 0, 0x1000000, 0x1000000 };

EndRem

' Define the default style
Global default_style:SMU_Style = New SMU_Style()
default_style.font = Null
default_style.size = New SVec2D( 68, 10 )
default_style.padding = 5
default_style.spacing = 4
default_style.indent = 24
default_style.title_height = 24
default_style.scrollbar_size = 12
default_style.thumb_size = 8
default_style.colors = [ ..
	New SColor8( 230, 230, 230, 255 ), .. ' MU_COLOR_TEXT
	New SColor8(  25,  25,  25, 255 ), .. ' MU_COLOR_BORDER
	New SColor8(  50,  50,  50, 255 ), .. ' MU_COLOR_WINDOWBG
	New SColor8(  25,  25,  25, 255 ), .. ' MU_COLOR_TITLEBG
	New SColor8( 240, 240, 240, 255 ), .. ' MU_COLOR_TITLETEXT
	New SColor8(   0,   0,   0,   0 ), .. ' MU_COLOR_PANELBG
	New SColor8(  75,  75,  75, 255 ), .. ' MU_COLOR_BUTTON
	New SColor8(  95,  95,  95, 255 ), .. ' MU_COLOR_BUTTONHOVER
	New SColor8( 115, 115, 115, 255 ), .. ' MU_COLOR_BcontextUTTONFOCUS
	New SColor8(  30,  30,  30, 255 ), .. ' MU_COLOR_BASE
	New SColor8(  35,  35,  35, 255 ), .. ' MU_COLOR_BASEHOVER
	New SColor8(  40,  40,  40, 255 ), .. ' MU_COLOR_BASEFOCUS
	New SColor8(  43,  43,  43, 255 ), .. ' MU_COLOR_SCROLLBASE
	New SColor8(  30,  30,  30, 255 )  .. ' MU_COLOR_SCROLLTHUMB
	]

Function mu_vec2:SMU_Vec2( x:Int, y:Int )
DebugStop
Rem
  mu_Vec2 res;
  res.x = x; res.y = y;
  Return res;
EndRem
EndFunction


Function mu_rect:SMU_Rect( x:Int, y:Int, w:Int, h:Int )
  'mu_Rect res;
  'res.x = x; res.y = y; res.w = w; res.h = h;
  Return New SMU_rect( x, y, w, h )
EndFunction

Function mu_color:SColor8( r:Int, g:Int, b:Int, a:Int)
  Return New SColor8( r,g,b,a )
EndFunction

Function expand_rect:SMU_Rect( rect:SMU_Rect, n:Int )
DebugStop
Rem
  Return mu_rect(rect.x - n, rect.y - n, rect.w + n * 2, rect.h + n * 2);
EndRem
EndFunction

Function intersect_rects:SMU_Rect( r1:SMU_Rect, r2:SMU_Rect )
DebugStop
Rem
  Int x1 = mu_max(r1.x, r2.x);
  Int y1 = mu_max(r1.y, r2.y);
  Int x2 = mu_min(r1.x + r1.w, r2.x + r2.w);
  Int y2 = mu_min(r1.y + r1.h, r2.y + r2.h);
  If (x2 < x1) { x2 = x1; }
  If (y2 < y1) { y2 = y1; }
  Return mu_rect(x1, y1, x2 - x1, y2 - y1);
EndRem
EndFunction

Function rect_overlaps_vec2:Int( r:SMU_Rect, p:SMU_Vec2 )
DebugStop
Rem
  Return p.x >= r.x && p.x < r.x + r.w && p.y >= r.y && p.y < r.y + r.h;
EndRem
EndFunction


Function draw_frame( ctx:TMU_Context, rect:SMU_Rect Var, colorid:Int )
DebugStop
Rem
  mu_draw_rect(ctx, rect, ctx.style.colors[colorid]);
  If (colorid == MU_COLOR_SCROLLBASE  ||
      colorid == MU_COLOR_SCROLLTHUMB ||
      colorid == MU_COLOR_TITLEBG) { Return; }
  /* draw border */
  If (ctx.style.colors[MU_COLOR_BORDER].a) {
    mu_draw_box(ctx, expand_rect(rect, 1), ctx.style.colors[MU_COLOR_BORDER]);
  }
EndRem
EndFunction


Function mu_init( ctx:TMU_Context )
DebugStop
  'memset(ctx, 0, SizeOf(*ctx));
  ctx.draw_frame = draw_frame
  ctx.style = default_style
  'ctx.style = &ctx._style
EndFunction


Function mu_begin( ctx:TMU_Context )
DebugStop
Rem
  assert(ctx.text_width && ctx.text_height);
  ctx.command_list.idx = 0;
  ctx.root_list.idx = 0;
  ctx.scroll_target = Null;
  ctx.hover_root = ctx.next_hover_root;
  ctx.next_hover_root = Null;
  ctx.mouse_delta.x = ctx.mouse_pos.x - ctx.last_mouse_pos.x;
  ctx.mouse_delta.y = ctx.mouse_pos.y - ctx.last_mouse_pos.y;
  ctx.frame++;
EndRem
EndFunction


Function compare_zindex:Int( a:Int Var, b:Int Var )
DebugStop
Rem
  Return (*(mu_Container**) a).zindex - (*(mu_Container**) b).zindex;
EndRem
EndFunction


Function mu_end( ctx:TMU_Context )
DebugStop
Rem
  Int i, n;
  /* check stacks */
  assert(ctx.container_stack.idx == 0);
  assert(ctx.clip_stack.idx      == 0);
  assert(ctx.id_stack.idx        == 0);
  assert(ctx.layout_stack.idx    == 0);

  /* handle scroll Input */
  If (ctx.scroll_target) {
    ctx.scroll_target.scroll.x += ctx.scroll_delta.x;
    ctx.scroll_target.scroll.y += ctx.scroll_delta.y;
  }

  /* unset focus If focus id was Not touched this frame */
  If (!ctx.updated_focus) { ctx.focus = 0; }
  ctx.updated_focus = 0;

  /* bring hover root To front If mouse was pressed */
  If (ctx.mouse_pressed && ctx.next_hover_root &&
      ctx.next_hover_root.zindex < ctx.last_zindex &&
      ctx.next_hover_root.zindex >= 0
  ) {
    mu_bring_to_front(ctx, ctx.next_hover_root);
  }

  /* reset Input state */
  ctx.key_pressed = 0;
  ctx.input_text[0] = '\0';
  ctx.mouse_pressed = 0;
  ctx.scroll_delta = mu_vec2(0, 0);
  ctx.last_mouse_pos = ctx.mouse_pos;

  /* sort root containers by zindex */
  n = ctx.root_list.idx;
  qsort(ctx.root_list.items, n, SizeOf(mu_Container*), compare_zindex);

  /* set root container jump commands */
  For (i = 0; i < n; i++) {
    cnt:TMU_Container var = ctx.root_list.items[i];
    /* If this is the first container Then make the first command jump To it.
    ** otherwise set the previous container's tail to jump to this one */
    If (i == 0) {
      mu_Command *cmd = (mu_Command*) ctx.command_list.items;
      cmd.jump.dst = (char*) cnt.head + SizeOf(mu_JumpCommand);
    } Else {
      mu_Container *prev = ctx.root_list.items[i - 1];
      prev.tail.jump.dst = (char*) cnt.head + SizeOf(mu_JumpCommand);
    }
    /* make the last container's tail jump to the end of command list */
    If (i == n - 1) {
      cnt.tail.jump.dst = ctx.command_list.items + ctx.command_list.idx;
    }
  }
EndRem
EndFunction

Function mu_set_focus( ctx:TMU_Context, id:ULong )
DebugStop
Rem
  ctx.focus = id;
  ctx.updated_focus = 1;
EndRem
EndFunction

' 32bit fnv-1a hash
Const HASH_INITIAL:Long = 2166136261

Function hash( hash:ULong Var, data:String )
	Local ascii:Byte
    hash = 0
    For Local i:Int = 0 Until Len( data )
        ascii = data[i]
        hash  = ((hash Shl 5) - hash) + ascii
        hash  = hash & hash
    Next
End Function

' Get the ID of a context
Function mu_get_id:ULong( ctx:TMU_Context, data:String )
	Local idx:Int = ctx.id_stack.idx
	Local res:ULong 
	If( idx > 0 )
		res = ctx.id_stack.items[idx - 1]
	Else
		res = HASH_INITIAL
	End If
	hash( res, data)
	ctx.last_id = res
	Return res
EndFunction

Function mu_push_id( ctx:TMU_Context, data:Byte Ptr, size:Int )
DebugStop
Rem
  push(ctx.id_stack, mu_get_id(ctx, data, size));
EndRem
EndFunction


Function mu_pop_id( ctx:TMU_Context )
DebugStop
Rem
  pop(ctx.id_stack);
EndRem
EndFunction


Function mu_push_clip_rect( ctx:TMU_Context, rect:SMU_Rect )
DebugStop
Rem
  mu_Rect last = mu_get_clip_rect(ctx);
  push(ctx.clip_stack, intersect_rects(rect, last));
EndRem
EndFunction

Function mu_pop_clip_rect( ctx:TMU_Context )
DebugStop
Rem
  pop(ctx.clip_stack);
EndRem
EndFunction

Function mu_get_clip_rect:SMU_Rect( ctx:TMU_Context )
DebugStop
Rem
  assert(ctx.clip_stack.idx > 0);
  Return ctx.clip_stack.items[ctx.clip_stack.idx - 1];
EndRem
EndFunction

Function mu_check_clip:Int( ctx:TMU_Context, r:SMU_Rect)
DebugStop
Rem
  mu_Rect cr = mu_get_clip_rect(ctx);
  If (r.x > cr.x + cr.w || r.x + r.w < cr.x ||
      r.y > cr.y + cr.h || r.y + r.h < cr.y   ) { Return MU_CLIP_ALL; }
  If (r.x >= cr.x && r.x + r.w <= cr.x + cr.w &&
      r.y >= cr.y && r.y + r.h <= cr.y + cr.h ) { Return 0; }
  Return MU_CLIP_PART;
EndRem
EndFunction

Function push_layout( ctx:TMU_Context, body:SMU_Rect, scroll:SMU_Vec2 )
DebugStop
Rem
  mu_Layout layout;
  Int width = 0;
  memset(&layout, 0, SizeOf(layout));
  layout.body = mu_rect(body.x - scroll.x, body.y - scroll.y, body.w, body.h);
  layout.Max = mu_vec2(-0x1000000, -0x1000000);
  push(ctx.layout_stack, layout);
  mu_layout_row(ctx, 1, &width, 0);
EndRem
EndFunction

Function get_layout:SMU_Layout( ctx:TMU_Context )
DebugStop
Rem
  Return &ctx.layout_stack.items[ctx.layout_stack.idx - 1];
EndRem
EndFunction

Function pop_container( ctx:TMU_Context )
DebugStop
Rem
  cnt:TMU_Container Var = mu_get_current_container(ctx);
  mu_Layout *layout = get_layout(ctx);
  cnt.content_size.x = layout.Max.x - layout.body.x;
  cnt.content_size.y = layout.Max.y - layout.body.y;
  /* pop container, layout And id */
  pop(ctx.container_stack);
  pop(ctx.layout_stack);
  mu_pop_id(ctx);
EndRem
EndFunction

Function mu_get_current_container:TMU_Container( ctx:TMU_Context )
DebugStop
Rem
  assert(ctx.container_stack.idx > 0);
  Return ctx.container_stack.items[ ctx.container_stack.idx - 1 ];
EndRem
EndFunction

Function get_container:TMU_Container( ctx:TMU_Context, id:ULong, opt:Int )
DebugStop
Rem
  cnt:TMU_Container Var;
  /* Try To get existing container from pool */
  idx:Int = mu_pool_get(ctx, ctx.container_pool, MU_CONTAINERPOOL_SIZE, id);
  If (idx >= 0) {
    If (ctx.containers[idx].open || ~opt & MU_OPT_CLOSED) {
      mu_pool_update(ctx, ctx.container_pool, idx);
    }
    Return &ctx.containers[idx];
  }
  If (opt & MU_OPT_CLOSED) { Return Null; }
  /* container Not found in pool: init New container */
  idx = mu_pool_init(ctx, ctx.container_pool, MU_CONTAINERPOOL_SIZE, id);
  cnt = &ctx.containers[idx];
  memset(cnt, 0, SizeOf(*cnt));
  cnt.open = 1;
  mu_bring_to_front(ctx, cnt);
  Return cnt;
EndRem
	Local cnt:TMU_Container
	' Try To get existing container from pool
	Local idx:Int = mu_pool_get(ctx, ctx.container_pool, MU_CONTAINERPOOL_SIZE, id)
	If (idx >= 0)
		If (ctx.containers[idx].open Or ~opt & MU_OPT_CLOSED)
			mu_pool_update(ctx, ctx.container_pool, idx)
		EndIf
		Return ctx.containers[idx]
	EndIf
	DebugStop
	If (opt & MU_OPT_CLOSED); Return Null
	' container Not found in pool: init New container
	idx = mu_pool_init(ctx, ctx.container_pool, MU_CONTAINERPOOL_SIZE, id)
	cnt = New ctx.containers[idx]
	cnt.memset()
	'memset(cnt, 0, SizeOf(cnt))
	cnt.open = 1
	mu_bring_to_front(ctx, cnt)
	Return cnt
EndFunction

Function mu_get_container:TMU_Container(ctx:TMU_Context, name:String )
DebugStop
Rem
  id:ULong = mu_get_id(ctx, name, strlen(name));
  Return get_container(ctx, id, 0);
EndRem
EndFunction

Function mu_bring_to_front(ctx:TMU_Context, cnt:TMU_Container Var)
DebugStop
Rem
  cnt.zindex = ++ctx.last_zindex;
EndRem
EndFunction

'============================================================================
' pool
'============================================================================

Function mu_pool_init:Int(ctx:TMU_Context, items:SMU_PoolItem[] Var, Length:Int, id:ULong)
DebugStop

	Local i:Int
	Local n:Int = -1
	Local f:Int = ctx.frame
	
	For Local i:Int = 0 Until Length
		If (items[i].last_update < f)
			f = items[i].last_update
			n = i
		EndIf
	Next
	Expect( n > -1 )
	items[n].id = id
	mu_pool_update(ctx, items, n)
	Return n
EndFunction

Function mu_pool_get:Int(ctx:TMU_Context, items:SMU_PoolItem[] Var, Length:Int, id:ULong)
DebugStop
	Local i:Int
	'unused(ctx);
	For Local i:Int = 0 Until Length
		If (items[i].id = id); Return i
	Next
	Return -1;
EndFunction

Function mu_pool_update(ctx:TMU_Context, items:SMU_PoolItem[] Var, idx:Int)
DebugStop
  items[idx].last_update = ctx.frame
EndFunction

'============================================================================
' Input handlers
'============================================================================

Function mu_input_mousemove(ctx:TMU_Context, x:Int, y:Int )
DebugStop
Rem
  ctx.mouse_pos = mu_vec2(x, y);
EndRem
EndFunction

Function mu_input_mousedown(ctx:TMU_Context, x:Int, y:Int, btn:Int )
DebugStop
Rem
  mu_input_mousemove(ctx, x, y);
  ctx.mouse_down |= btn;
  ctx.mouse_pressed |= btn;
EndRem
EndFunction

Function mu_input_mouseup(ctx:TMU_Context, x:Int, y:Int, btn:Int )
DebugStop
Rem
  mu_input_mousemove(ctx, x, y);
  ctx.mouse_down &= ~btn;
EndRem
EndFunction

Function mu_input_scroll(ctx:TMU_Context, x:Int, y:Int )
DebugStop
Rem
  ctx.scroll_delta.x += x;
  ctx.scroll_delta.y += y;
EndRem
EndFunction

Function mu_input_keydown(ctx:TMU_Context, key:Int)
DebugStop
Rem
  ctx.key_pressed |= key;
  ctx.key_down |= key;
EndRem
EndFunction

Function mu_input_keyup(ctx:TMU_Context, key:Int )
DebugStop
Rem
  ctx.key_down &= ~key;
EndRem
EndFunction

Function mu_input_text(ctx:TMU_Context, Text:String )
DebugStop
Rem
  Int Len = strlen(ctx.input_text);
  Int size = strlen(Text) + 1;
  assert(Len + size <= (Int) SizeOf(ctx.input_text));
  memcpy(ctx.input_text + Len, Text, size);
EndRem
EndFunction

'============================================================================
' commandlist
'============================================================================

Function mu_push_command:TCommand(ctx:TMU_Context, class:Int, size:Int )
DebugStop
Rem
  mu_Command *cmd = (mu_Command*) (ctx.command_list.items + ctx.command_list.idx);
  assert(ctx.command_list.idx + size < MU_COMMANDLIST_SIZE);
  cmd.base.class = class;
  cmd.base.size = size;
  ctx.command_list.idx += size;
  Return cmd;
EndRem
EndFunction

Function mu_next_command:Int(ctx:TMU_Context, cmd:TCommand )
DebugStop
Rem
  If (*cmd) {
    *cmd = (mu_Command*) (((char*) *cmd) + (*cmd).base.size);
  } Else {
    *cmd = (mu_Command*) ctx.command_list.items;
  }
  While ((char*) *cmd != ctx.command_list.items + ctx.command_list.idx) {
    If ((*cmd).Type != MU_COMMAND_JUMP) { Return 1; }
    *cmd = (*cmd).jump.dst;
  }
  Return 0;
EndRem
EndFunction

Function push_jump:TCommand(ctx:TMU_Context, dst:TCommand)
DebugStop
Rem
  mu_Command *cmd;
  cmd = mu_push_command(ctx, MU_COMMAND_JUMP, SizeOf(mu_JumpCommand));
  cmd.jump.dst = dst;
  Return cmd;
EndRem
EndFunction

Function mu_set_clip(ctx:TMU_Context, rect:SMU_Rect )
DebugStop
Rem
  mu_Command *cmd;
  cmd = mu_push_command(ctx, MU_COMMAND_CLIP, SizeOf(mu_ClipCommand));
  cmd.clip.rect = rect;
EndRem
EndFunction

Function mu_draw_rect(ctx:TMU_Context, rect:SMU_Rect, color:SColor8 )
DebugStop
Rem
  mu_Command *cmd;
  rect = intersect_rects(rect, mu_get_clip_rect(ctx));
  If (rect.w > 0 && rect.h > 0) {
    cmd = mu_push_command(ctx, MU_COMMAND_RECT, SizeOf(mu_RectCommand));
    cmd.rect.rect = rect;
    cmd.rect.color = color;
  }
EndRem
EndFunction

Function mu_draw_box(ctx:TMU_Context, rect:SMU_Rect, color:SColor8 )
DebugStop
Rem
  mu_draw_rect(ctx, mu_rect(rect.x + 1, rect.y, rect.w - 2, 1), color);
  mu_draw_rect(ctx, mu_rect(rect.x + 1, rect.y + rect.h - 1, rect.w - 2, 1), color);
  mu_draw_rect(ctx, mu_rect(rect.x, rect.y, 1, rect.h), color);
  mu_draw_rect(ctx, mu_rect(rect.x + rect.w - 1, rect.y, 1, rect.h), color);
EndRem
EndFunction

Function mu_draw_text(ctx:TMU_Context, font:TMU_Font, str:String, Len:Int, pos:SMU_Vec2, color:SColor8 )
DebugStop
Rem
  mu_Command *cmd;
  mu_Rect rect = mu_rect(
    pos.x, pos.y, ctx.text_width(font, str, Len), ctx.text_height(font));
  Int clipped = mu_check_clip(ctx, rect);
  If (clipped == MU_CLIP_ALL ) { Return; }
  If (clipped == MU_CLIP_PART) { mu_set_clip(ctx, mu_get_clip_rect(ctx)); }
  /* add command */
  If (Len < 0) { Len = strlen(str); }
  cmd = mu_push_command(ctx, MU_COMMAND_TEXT, SizeOf(mu_TextCommand) + Len);
  memcpy(cmd.Text.str, str, Len);
  cmd.Text.str[Len] = '\0';
  cmd.Text.pos = pos;
  cmd.Text.color = color;
  cmd.Text.font = font;
  /* reset clipping If it was set */
  If (clipped) { mu_set_clip(ctx, unclipped_rect); }
EndRem
EndFunction

Function mu_draw_icon(ctx:TMU_Context, id:Int, rect:SMU_Rect, color:SColor8 )
DebugStop
Rem
  mu_Command *cmd;
  /* do clip command If the rect isn't fully contained within the cliprect */
  Int clipped = mu_check_clip(ctx, rect);
  If (clipped == MU_CLIP_ALL ) { Return; }
  If (clipped == MU_CLIP_PART) { mu_set_clip(ctx, mu_get_clip_rect(ctx)); }
  /* do icon command */
  cmd = mu_push_command(ctx, MU_COMMAND_ICON, SizeOf(mu_IconCommand));
  cmd.icon.id = id;
  cmd.icon.rect = rect;
  cmd.icon.color = color;
  /* reset clipping If it was set */
  If (clipped) { mu_set_clip(ctx, unclipped_rect); }
EndRem
EndFunction

'============================================================================
' layout
'============================================================================

'Enum { RELATIVE = 1, ABSOLUTE = 2 };

Function mu_layout_begin_column(ctx:TMU_Context)
DebugStop
Rem
  push_layout(ctx, mu_layout_next(ctx), mu_vec2(0, 0));
EndRem
EndFunction

Function mu_layout_end_column(ctx:TMU_Context)
DebugStop
Rem
  mu_Layout *a, *b;
  b = get_layout(ctx);
  pop(ctx.layout_stack);
  /* inherit position/next_row/Max from child layout If they are greater */
  a = get_layout(ctx);
  a.position.x = mu_max(a.position.x, b.position.x + b.body.x - a.body.x);
  a.next_row = mu_max(a.next_row, b.next_row + b.body.y - a.body.y);
  a.Max.x = mu_max(a.Max.x, b.Max.x);
  a.Max.y = mu_max(a.Max.y, b.Max.y);
EndRem
EndFunction

Function mu_layout_row(ctx:TMU_Context, items:Int, widths:Int[], height:Int)
DebugStop
Rem
  mu_Layout *layout = get_layout(ctx);
  If (widths) {
    assert(items <= MU_MAX_WIDTHS);
    memcpy(layout.widths, widths, items * SizeOf(widths[0]));
  }
  layout.items = items;
  layout.position = mu_vec2(layout.indent, layout.next_row);
  layout.size.y = height;
  layout.item_index = 0;
EndRem
EndFunction

Function mu_layout_width(ctx:TMU_Context, width:Int)
DebugStop
Rem
  get_layout(ctx).size.x = width;
EndRem
EndFunction

Function mu_layout_height(ctx:TMU_Context, height:Int )
DebugStop
Rem
  get_layout(ctx).size.y = height;
EndRem
EndFunction

Function mu_layout_set_next(ctx:TMU_Context, r:SMU_Rect, relative:Int )
DebugStop
Rem
  mu_Layout *layout = get_layout(ctx);
  layout.Next = r;
  layout.next_type = relative ? RELATIVE : ABSOLUTE;
EndRem
EndFunction

Function mu_layout_next:SMU_Rect(ctx:TMU_Context)
DebugStop
Rem
  mu_Layout *layout = get_layout(ctx);
  mu_Style *style = ctx.style;
  mu_Rect res;

  If (layout.next_type) {
    /* handle rect set by `mu_layout_set_next` */
    Int Type = layout.next_type;
    layout.next_type = 0;
    res = layout.Next;
    If (Type == ABSOLUTE) { Return (ctx.last_rect = res); }

  } Else {
    /* handle Next row */
    If (layout.item_index == layout.items) {
      mu_layout_row(ctx, layout.items, Null, layout.size.y);
    }

    /* position */
    res.x = layout.position.x;
    res.y = layout.position.y;

    /* size */
    res.w = layout.items > 0 ? layout.widths[layout.item_index] : layout.size.x;
    res.h = layout.size.y;
    If (res.w == 0) { res.w = style.size.x + style.padding * 2; }
    If (res.h == 0) { res.h = style.size.y + style.padding * 2; }
    If (res.w <  0) { res.w += layout.body.w - res.x + 1; }
    If (res.h <  0) { res.h += layout.body.h - res.y + 1; }

    layout.item_index++;
  }

  /* Update position */
  layout.position.x += res.w + style.spacing;
  layout.next_row = mu_max(layout.next_row, res.y + res.h + style.spacing);

  /* Apply body offset */
  res.x += layout.body.x;
  res.y += layout.body.y;

  /* Update Max position */
  layout.Max.x = mu_max(layout.Max.x, res.x + res.w);
  layout.Max.y = mu_max(layout.Max.y, res.y + res.h);

  Return (ctx.last_rect = res);
EndRem
EndFunction

'============================================================================
' controls
'============================================================================

Function in_hover_root:Int(ctx:TMU_Context)
DebugStop
Rem
  Int i = ctx.container_stack.idx;
  While (i--) {
    If (ctx.container_stack.items[i] == ctx.hover_root) { Return 1; }
    /* only root containers have their `head` Field set; stop searching If we've
    ** reached the current root container */
    If (ctx.container_stack.items[i].head) { break; }
  }
  Return 0;
EndRem
EndFunction

Function mu_draw_control_frame(ctx:TMU_Context, id:ULong, rect:SMU_Rect Var, colorid:Int, opt:Int )
	If (opt & MU_OPT_NOFRAME); Return
	'colorid += (ctx.focus == id) ? 2 : (ctx.hover == id) ? 1 : 0;
	colorid :+ iif( ctx.focus = id, 2, iif( ctx.hover = id, 1, 0 ) )
	ctx.draw_frame(ctx, rect, colorid)
EndFunction

Function mu_draw_control_text(ctx:TMU_Context, str:String, rect:SMU_Rect Var, colorid:Int, opt:Int )
DebugStop
Rem
  mu_Vec2 pos;
  mu_Font font = ctx.style.font;
  Int tw = ctx.text_width(font, str, -1);
  mu_push_clip_rect(ctx, rect);
  pos.y = rect.y + (rect.h - ctx.text_height(font)) / 2;
  If (opt & MU_OPT_ALIGNCENTER) {
    pos.x = rect.x + (rect.w - tw) / 2;
  } Else If (opt & MU_OPT_ALIGNRIGHT) {
    pos.x = rect.x + rect.w - tw - ctx.style.padding;
  } Else {
    pos.x = rect.x + ctx.style.padding;
  }
  mu_draw_text(ctx, font, str, -1, pos, ctx.style.colors[colorid]);
  mu_pop_clip_rect(ctx);
EndRem
EndFunction

Function mu_mouse_over:Int(ctx:TMU_Context, rect:SMU_Rect Var)
DebugStop
Rem
  Return rect_overlaps_vec2(rect, ctx.mouse_pos) &&
    rect_overlaps_vec2(mu_get_clip_rect(ctx), ctx.mouse_pos) &&
    in_hover_root(ctx);
EndRem
EndFunction

Function mu_update_control(ctx:TMU_Context, id:ULong, rect:SMU_Rect Var, opt:Int )
DebugStop
Rem
  Int mouseover = mu_mouse_over(ctx, rect);

  If (ctx.focus == id) { ctx.updated_focus = 1; }
  If (opt & MU_OPT_NOINTERACT) { Return; }
  If (mouseover && !ctx.mouse_down) { ctx.hover = id; }

  If (ctx.focus == id) {
    If (ctx.mouse_pressed && !mouseover) { mu_set_focus(ctx, 0); }
    If (!ctx.mouse_down && ~opt & MU_OPT_HOLDFOCUS) { mu_set_focus(ctx, 0); }
  }

  If (ctx.hover == id) {
    If (ctx.mouse_pressed) {
      mu_set_focus(ctx, id);
    } Else If (!mouseover) {
      ctx.hover = 0;
    }
  }
EndRem
EndFunction

Function mu_text(ctx:TMU_Context, Text:String )
DebugStop
Rem
  Const char *start, *End, *p = Text;
  Int width = -1;
  mu_Font font = ctx.style.font;
  mu_Color color = ctx.style.colors[MU_COLOR_TEXT];
  mu_layout_begin_column(ctx);
  mu_layout_row(ctx, 1, &width, ctx.text_height(font));
  do {
    mu_Rect r = mu_layout_next(ctx);
    Int w = 0;
    start = End = p;
    do {
      Const char* word = p;
      While (*p && *p != ' ' && *p != '\n') { p++; }
      w += ctx.text_width(font, word, p - word);
      If (w > r.w && End != start) { break; }
      w += ctx.text_width(font, p, 1);
      End = p++;
    } While (*End && *End != '\n');
    mu_draw_text(ctx, font, start, End - start, mu_vec2(r.x, r.y), color);
    p = End + 1;
  } While (*End);
  mu_layout_end_column(ctx);
EndRem
EndFunction

Function mu_label(ctx:TMU_Context, Text:String )
'  mu_draw_control_text(ctx, Text, mu_layout_next(ctx), MU_COLOR_TEXT, 0);
EndFunction

Function mu_button:Int(ctx:TMU_Context, label:String, icon:Int=0, opt:Int=MU_OPT_ALIGNCENTER)
DebugStop
Rem
  Int res = 0;
  id:ULong = label ? mu_get_id(ctx, label, strlen(label))
                   : mu_get_id(ctx, &icon, SizeOf(icon));
  mu_Rect r = mu_layout_next(ctx);
  mu_update_control(ctx, id, r, opt);
  /* handle click */
  If (ctx.mouse_pressed == MU_MOUSE_LEFT && ctx.focus == id) {
    res |= MU_RES_SUBMIT;
  }
  /* draw */
  mu_draw_control_frame(ctx, id, r, MU_COLOR_BUTTON, opt);
  If (label) { mu_draw_control_text(ctx, label, r, MU_COLOR_TEXT, opt); }
  If (icon) { mu_draw_icon(ctx, icon, r, ctx.style.colors[MU_COLOR_TEXT]); }
  Return res;
EndRem
EndFunction

Function mu_checkbox:Int(ctx:TMU_Context, label:String, state:Int Var)
DebugStop
Rem
  Int res = 0;
  id:ULong = mu_get_id(ctx, &state, SizeOf(state));
  mu_Rect r = mu_layout_next(ctx);
  mu_Rect box = mu_rect(r.x, r.y, r.h, r.h);
  mu_update_control(ctx, id, r, 0);
  /* handle click */
  If (ctx.mouse_pressed == MU_MOUSE_LEFT && ctx.focus == id) {
    res |= MU_RES_CHANGE;
    *state = !*state;
  }
  /* draw */
  mu_draw_control_frame(ctx, id, box, MU_COLOR_BASE, 0);
  If (*state) {
    mu_draw_icon(ctx, MU_ICON_CHECK, box, ctx.style.colors[MU_COLOR_TEXT]);
  }
  r = mu_rect(r.x + box.w, r.y, r.w - box.w, r.h);
  mu_draw_control_text(ctx, label, r, MU_COLOR_TEXT, 0);
  Return res;
EndRem
EndFunction

Function mu_textbox_raw:Int(ctx:TMU_Context, buf:String Var, bufsz:Int, id:ULong, r:SMU_Rect, opt:Int )
DebugStop
Rem
  Int res = 0;
  mu_update_control(ctx, id, r, opt | MU_OPT_HOLDFOCUS);

  If (ctx.focus == id) {
    /* handle Text Input */
    Int Len = strlen(buf);
    Int n = mu_min(bufsz - Len - 1, (Int) strlen(ctx.input_text));
    If (n > 0) {
      memcpy(buf + Len, ctx.input_text, n);
      Len += n;
      buf[Len] = '\0';
      res |= MU_RES_CHANGE;
    }
    /* handle backspace */
    If (ctx.key_pressed & MU_KEY_BACKSPACE && Len > 0) {
      /* skip utf-8 continuation bytes */
      While ((buf[--Len] & 0xc0) == 0x80 && Len > 0);
      buf[Len] = '\0';
      res |= MU_RES_CHANGE;
    }
    /* handle Return */
    If (ctx.key_pressed & MU_KEY_RETURN) {
      mu_set_focus(ctx, 0);
      res |= MU_RES_SUBMIT;
    }
  }

  /* draw */
  mu_draw_control_frame(ctx, id, r, MU_COLOR_BASE, opt);
  If (ctx.focus == id) {
    mu_Color color = ctx.style.colors[MU_COLOR_TEXT];
    mu_Font font = ctx.style.font;
    Int textw = ctx.text_width(font, buf, -1);
    Int texth = ctx.text_height(font);
    Int ofx = r.w - ctx.style.padding - textw - 1;
    Int textx = r.x + mu_min(ofx, ctx.style.padding);
    Int texty = r.y + (r.h - texth) / 2;
    mu_push_clip_rect(ctx, r);
    mu_draw_text(ctx, font, buf, -1, mu_vec2(textx, texty), color);
    mu_draw_rect(ctx, mu_rect(textx + textw, texty, 1, texth), color);
    mu_pop_clip_rect(ctx);
  } Else {
    mu_draw_control_text(ctx, buf, r, MU_COLOR_TEXT, opt);
  }

  Return res;
EndRem
EndFunction

Function number_textbox:Int(ctx:TMU_Context, value:Float Var, r:SMU_Rect, id:ULong)
DebugStop
Rem
  If (ctx.mouse_pressed == MU_MOUSE_LEFT && ctx.key_down & MU_KEY_SHIFT &&
      ctx.hover == id
  ) {
    ctx.number_edit = id;
    sprintf(ctx.number_edit_buf, MU_REAL_FMT, *value);
  }
  If (ctx.number_edit == id) {
    Int res = mu_textbox_raw(
      ctx, ctx.number_edit_buf, SizeOf(ctx.number_edit_buf), id, r, 0);
    If (res & MU_RES_SUBMIT || ctx.focus != id) {
      *value = strtod(ctx.number_edit_buf, Null);
      ctx.number_edit = 0;
    } Else {
      Return 1;
    }
  }
  Return 0;
EndRem
EndFunction

Function mu_textbox:Int(ctx:TMU_Context, buf:Byte Ptr, bufsz:Int, opt:Int=0)
DebugStop
Rem
  id:ULong = mu_get_id(ctx, &buf, SizeOf(buf));
  mu_Rect r = mu_layout_next(ctx);
  Return mu_textbox_raw(ctx, buf, bufsz, id, r, opt);
EndRem
EndFunction

Function mu_slider:Int(ctx:TMU_Context, value:Float Var, low:Float, high:Float, Steps:Float=0.0, fmt:String=MU_SLIDER_FMT, opt:Int=MU_OPT_ALIGNCENTER )
DebugStop
Rem
  char buf[MU_MAX_FMT + 1];
  mu_Rect thumb;
  Int x, w, res = 0;
  mu_Real last = *value, v = last;
  id:ULong = mu_get_id(ctx, &value, SizeOf(value));
  mu_Rect base = mu_layout_next(ctx);

  /* handle Text Input mode */
  If (number_textbox(ctx, &v, base, id)) { Return res; }

  /* handle Normal mode */
  mu_update_control(ctx, id, base, opt);

  /* handle Input */
  If (ctx.focus == id &&
      (ctx.mouse_down | ctx.mouse_pressed) == MU_MOUSE_LEFT)
  {
    v = low + (ctx.mouse_pos.x - base.x) * (high - low) / base.w;
    If (Step) { v = (((v + Step / 2) / Step)) * Step; }
  }
  /* Clamp And store value, Update res */
  *value = v = mu_clamp(v, low, high);
  If (last != v) { res |= MU_RES_CHANGE; }

  /* draw base */
  mu_draw_control_frame(ctx, id, base, MU_COLOR_BASE, opt);
  /* draw thumb */
  w = ctx.style.thumb_size;
  x = (v - low) * (base.w - w) / (high - low);
  thumb = mu_rect(base.x + x, base.y, w, base.h);
  mu_draw_control_frame(ctx, id, thumb, MU_COLOR_BUTTON, opt);
  /* draw Text  */
  sprintf(buf, fmt, v);
  mu_draw_control_text(ctx, buf, base, MU_COLOR_TEXT, opt);

  Return res;
EndRem
EndFunction

Function mu_number:Int(ctx:TMU_Context, value:Float Var, Steps:Float, fmt:String=MU_SLIDER_FMT, opt:Int=MU_OPT_ALIGNCENTER)
DebugStop
Rem
  char buf[MU_MAX_FMT + 1];
  Int res = 0;
  id:ULong = mu_get_id(ctx, &value, SizeOf(value));
  mu_Rect base = mu_layout_next(ctx);
  mu_Real last = *value;

  /* handle Text Input mode */
  If (number_textbox(ctx, value, base, id)) { Return res; }

  /* handle Normal mode */
  mu_update_control(ctx, id, base, opt);

  /* handle Input */
  If (ctx.focus == id && ctx.mouse_down == MU_MOUSE_LEFT) {
    *value += ctx.mouse_delta.x * Step;
  }
  /* set flag If value changed */
  If (*value != last) { res |= MU_RES_CHANGE; }

  /* draw base */
  mu_draw_control_frame(ctx, id, base, MU_COLOR_BASE, opt);
  /* draw Text  */
  sprintf(buf, fmt, *value);
  mu_draw_control_text(ctx, buf, base, MU_COLOR_TEXT, opt);

  Return res;
EndRem
EndFunction

Function header:Int(ctx:TMU_Context, label:String Var, istreenode:Int, opt:Int)
DebugStop
Rem
  mu_Rect r;
  Int active, expanded;
  id:ULong = mu_get_id(ctx, label, strlen(label));
  idx:Int = mu_pool_get(ctx, ctx.treenode_pool, MU_TREENODEPOOL_SIZE, id);
  Int width = -1;
  mu_layout_row(ctx, 1, &width, 0);

  active = (idx >= 0);
  expanded = (opt & MU_OPT_EXPANDED) ? !active : active;
  r = mu_layout_next(ctx);
  mu_update_control(ctx, id, r, 0);

  /* handle click */
  active ^= (ctx.mouse_pressed == MU_MOUSE_LEFT && ctx.focus == id);

  /* Update pool ref */
  If (idx >= 0) {
    If (active) { mu_pool_update(ctx, ctx.treenode_pool, idx); }
           Else { memset(&ctx.treenode_pool[idx], 0, SizeOf(mu_PoolItem)); }
  } Else If (active) {
    mu_pool_init(ctx, ctx.treenode_pool, MU_TREENODEPOOL_SIZE, id);
  }

  /* draw */
  If (istreenode) {
    If (ctx.hover == id) { ctx.draw_frame(ctx, r, MU_COLOR_BUTTONHOVER); }
  } Else {
    mu_draw_control_frame(ctx, id, r, MU_COLOR_BUTTON, 0);
  }
  mu_draw_icon(
    ctx, expanded ? MU_ICON_EXPANDED : MU_ICON_COLLAPSED,
    mu_rect(r.x, r.y, r.h, r.h), ctx.style.colors[MU_COLOR_TEXT]);
  r.x += r.h - ctx.style.padding;
  r.w -= r.h - ctx.style.padding;
  mu_draw_control_text(ctx, label, r, MU_COLOR_TEXT, 0);

  Return expanded ? MU_RES_ACTIVE : 0;
EndRem
EndFunction

Function mu_header:Int(ctx:TMU_Context, label:String Var, opt:Int=0)
'  Return header(ctx, label, 0, opt);
EndFunction

Function mu_begin_treenode:Int(ctx:TMU_Context, label:String Var, opt:Int=0 )
DebugStop
Rem
  Int res = header(ctx, label, 1, opt);
  If (res & MU_RES_ACTIVE) {
    get_layout(ctx).indent += ctx.style.indent;
    push(ctx.id_stack, ctx.last_id);
  }
  Return res;
EndRem
EndFunction

Function mu_end_treenode(ctx:TMU_Context)
'  get_layout(ctx).indent -= ctx.style.indent;
'  mu_pop_id(ctx);
EndFunction

Rem
#define scrollbar(ctx, cnt, b, cs, x, y, w, h)                              \
  do {                                                                      \
    /* only add scrollbar If content size is larger than body */            \
    Int maxscroll = cs.y - b.h;                                            \
                                                                            \
    If (maxscroll > 0 && b.h > 0) {                                        \
      mu_Rect base, thumb;                                                  \
      id:ULong = mu_get_id(ctx, "!scrollbar" #y, 11);                       \
                                                                            \
      /* get sizing / positioning */                                        \
      base = *b;                                                            \
      base.x = b.x + b.w;                                                 \
      base.w = ctx.style.scrollbar_size;                                  \
                                                                            \
      /* handle Input */                                                    \
      mu_update_control(ctx, id, base, 0);                                  \
      If (ctx.focus == id && ctx.mouse_down == MU_MOUSE_LEFT) {           \
        cnt.scroll.y += ctx.mouse_delta.y * cs.y / base.h;                \
      }                                                                     \
      /* Clamp scroll To limits */                                          \
      cnt.scroll.y = mu_clamp(cnt.scroll.y, 0, maxscroll);                \
                                                                            \
      /* draw base And thumb */                                             \
      ctx.draw_frame(ctx, base, MU_COLOR_SCROLLBASE);                      \
      thumb = base;                                                         \
      thumb.h = mu_max(ctx.style.thumb_size, base.h * b.h / cs.y);       \
      thumb.y += cnt.scroll.y * (base.h - thumb.h) / maxscroll;            \
      ctx.draw_frame(ctx, thumb, MU_COLOR_SCROLLTHUMB);                    \
                                                                            \
      /* set this as the scroll_target (will get scrolled on mousewheel) */ \
      /* If the mouse is over it */                                         \
      If (mu_mouse_over(ctx, *b)) { ctx.scroll_target = cnt; }             \
    } Else {                                                                \
      cnt.scroll.y = 0;                                                    \
    }                                                                       \
  } While (0)
EndRem

Function scrollbars(ctx:TMU_Context, cnt:TMU_Container Var, body:SMU_Rect Var )
DebugStop
Rem
  Int sz = ctx.style.scrollbar_size;
  mu_Vec2 cs = cnt.content_size;
  cs.x += ctx.style.padding * 2;
  cs.y += ctx.style.padding * 2;
  mu_push_clip_rect(ctx, *body);
  /* resize body To make room For scrollbars */
  If (cs.y > cnt.body.h) { body.w -= sz; }
  If (cs.x > cnt.body.w) { body.h -= sz; }
  /* To Create a horizontal Or vertical scrollbar almost-identical code is
  ** used; only the references To `x|y` `w|h` need To be switched */
  scrollbar(ctx, cnt, body, cs, x, y, w, h);
  scrollbar(ctx, cnt, body, cs, y, x, h, w);
  mu_pop_clip_rect(ctx);
EndRem
EndFunction

Function push_container_body( ctx:TMU_Context, cnt:TMU_Container Var, body:SMU_Rect, opt:Int )
DebugStop
Rem
  If (~opt & MU_OPT_NOSCROLL) { scrollbars(ctx, cnt, &body); }
  push_layout(ctx, expand_rect(body, -ctx.style.padding), cnt.scroll);
  cnt.body = body;
EndRem
EndFunction

Function begin_root_container( ctx:TMU_Context, cnt:TMU_Container Var )
DebugStop
Rem
  push(ctx.container_stack, cnt);
  /* push container To roots list And push head command */
  push(ctx.root_list, cnt);
  cnt.head = push_jump(ctx, Null);
  /* set as hover root If the mouse is overlapping this container And it has a
  ** higher zindex than the current hover root */
  If (rect_overlaps_vec2(cnt.rect, ctx.mouse_pos) &&
      (!ctx.next_hover_root || cnt.zindex > ctx.next_hover_root.zindex)
  ) {
    ctx.next_hover_root = cnt;
  }
  /* clipping is reset here in Case a root-container is made within
  ** another root-containers's begin/end block; this prevents the inner
  ** root-container being clipped To the outer */
  push(ctx.clip_stack, unclipped_rect);
EndRem
EndFunction

Function end_root_container(ctx:TMU_Context)
DebugStop
Rem
  /* push tail 'goto' jump command and set head 'skip' command. the final steps
  ** on initing these are done in mu_end() */
  cnt:TMU_Container var = mu_get_current_container(ctx);
  cnt.tail = push_jump(ctx, Null);
  cnt.head.jump.dst = ctx.command_list.items + ctx.command_list.idx;
  /* pop base clip rect And container */
  mu_pop_clip_rect(ctx);
  pop_container(ctx);
EndRem
EndFunction

Function mu_begin_window:Int(ctx:TMU_Context, title:String, rect:SMU_Rect, opt:Int=0 )
	Local body:SMU_Rect
	Local id:ULong = mu_get_id( ctx, title )
	Local cnt:TMU_Container = get_container(ctx, id, opt)

	If ( Not cnt Or Not cnt.open ); Return 0
	
	ctx.id_stack.push( id )

	If (cnt.rect.w = 0); cnt.rect = rect
	begin_root_container(ctx, cnt)
	' rect = body = cnt.rect
	rect = cnt.rect
	body = cnt.rect

	' draw frame
	If (~opt & MU_OPT_NOFRAME )
		If ctx.draw_frame; ctx.draw_frame(ctx, rect, MU_COLOR_WINDOWBG)
	EndIf

	' do title bar
	If (~opt & MU_OPT_NOTITLE)
		Local tr:SMU_Rect = rect
		tr.h = ctx.style.title_height
		If ctx.draw_frame; ctx.draw_frame(ctx, tr, MU_COLOR_TITLEBG)

		' do title Text
		If (~opt & MU_OPT_NOTITLE)
			Local id:ULong = mu_get_id(ctx, "!title")
			mu_update_control(ctx, id, tr, opt)
			mu_draw_control_text(ctx, title, tr, MU_COLOR_TITLETEXT, opt)
			If (id = ctx.focus And  ctx.mouse_down = MU_MOUSE_LEFT)
				cnt.rect.x :+ ctx.mouse_delta.x
				cnt.rect.y :+ ctx.mouse_delta.y
			EndIf
			body.y :+ tr.h
			body.h :- tr.h
		EndIf

		' do `close` button
		If (~opt & MU_OPT_NOCLOSE)
			Local id:ULong = mu_get_id(ctx, "!close")
			Local r:SMU_Rect = mu_rect(tr.x + tr.w - tr.h, tr.y, tr.h, tr.h)
			tr.w :- r.w
			mu_draw_icon(ctx, MU_ICON_CLOSE, r, ctx.style.colors[MU_COLOR_TITLETEXT])
			mu_update_control(ctx, id, r, opt)
			If (ctx.mouse_pressed = MU_MOUSE_LEFT And id = ctx.focus)
				cnt.open = 0
			EndIf
		EndIf
	EndIf

	push_container_body(ctx, cnt, body, opt)

	' do `resize` handle
	If (~opt & MU_OPT_NORESIZE)
		Local sz:Int = ctx.style.title_height
		Local id:ULong = mu_get_id(ctx, "!resize")
		Local r:SMU_Rect = mu_rect(rect.x + rect.w - sz, rect.y + rect.h - sz, sz, sz)
		mu_update_control(ctx, id, r, opt)
		If (id = ctx.focus And ctx.mouse_down = MU_MOUSE_LEFT)
			cnt.rect.w = mu_max(96, cnt.rect.w + ctx.mouse_delta.x)
			cnt.rect.h = mu_max(64, cnt.rect.h + ctx.mouse_delta.y)
		EndIf
	EndIf

	' resize To content size
	If (opt & MU_OPT_AUTOSIZE)
		Local r:SMU_Rect = get_layout(ctx).body
		cnt.rect.w = cnt.content_size.x + (cnt.rect.w - r.w)
		cnt.rect.h = cnt.content_size.y + (cnt.rect.h - r.h)
	EndIf

	' close If this is a popup window And elsewhere was clicked */
	If (opt & MU_OPT_POPUP And ctx.mouse_pressed And ctx.hover_root <> cnt)
		cnt.open = False
	End If

	mu_push_clip_rect(ctx, cnt.body)
	Return MU_RES_ACTIVE
EndFunction

Function mu_end_window(ctx:TMU_Context)
'  mu_pop_clip_rect(ctx);
'  end_root_container(ctx);
EndFunction

Function mu_open_popup(ctx:TMU_Context, name:String)
'  cnt:TMU_Container var = mu_get_container(ctx, name);
'  /* set as hover root so popup isn't closed in begin_window_ex()  */
'  ctx.hover_root = ctx.next_hover_root = cnt;
'  /* position at mouse cursor, open And bring-To-front */
'  cnt.rect = mu_rect(ctx.mouse_pos.x, ctx.mouse_pos.y, 1, 1);
'  cnt.open = 1;
'  mu_bring_to_front(ctx, cnt);
EndFunction

Function mu_begin_popup:Int(ctx:TMU_Context, name:String )
'  Int opt = MU_OPT_POPUP | MU_OPT_AUTOSIZE | MU_OPT_NORESIZE |
'            MU_OPT_NOSCROLL | MU_OPT_NOTITLE | MU_OPT_CLOSED;
'  Return mu_begin_window_ex(ctx, name, mu_rect(0, 0, 0, 0), opt);
EndFunction

Function mu_end_popup(ctx:TMU_Context)
'  mu_end_window(ctx);
EndFunction

Function mu_begin_panel(ctx:TMU_Context, name:String Var, opt:Int=0)
DebugStop
Rem
  cnt:TMU_Container Var;
  mu_push_id(ctx, name, strlen(name));
  cnt = get_container(ctx, ctx.last_id, opt);
  cnt.rect = mu_layout_next(ctx);
  If (~opt & MU_OPT_NOFRAME) {
    ctx.draw_frame(ctx, cnt.rect, MU_COLOR_PANELBG);
  }
  push(ctx.container_stack, cnt);
  push_container_body(ctx, cnt, cnt.rect, opt);
  mu_push_clip_rect(ctx, cnt.body);
EndRem
End Function

Function mu_end_panel(ctx:TMU_Context)
DebugStop
Rem
  mu_pop_clip_rect(ctx);
  pop_container(ctx);
EndRem
EndFunction
