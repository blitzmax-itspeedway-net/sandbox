
' Create a Button
Function FButton:Int( ctx:GUIContext Var, caption:String, icon:Int=0, options:Int=GUI_ALIGNCENTRE )
	Local result:Int = False
	
	' Get unique id
	DebugStop
	Local id:Int = ctx.getid( iif( caption="", String(icon), caption ) )
	
	Local rect:SRect = ctx.layout.getnext()
	
	' Update component mouse etc...
DebugStop ' Attemt to move control update into context
	Local bg_color:Int
	Local fg_color:Int
	Select ctx.Update( id, rect, options )
	Case 0
		bg_color = PALETTE_SECONDARY
		fg_color = PALETTE_ONSECONDARY
		'
		If ctx.mousereleased And ctx.focus = id; result = True
	Case 1
		bg_color = PALETTE_PRIMARY 
		fg_color = PALETTE_ONPRIMARY
	End Select
DebugStop ' DOES THE ABOVE WORK, DO WE NEED THE BELOW
	' Mouseover colours and mouseclick
	If ctx.mouseover( rect )
		bg_color = PALETTE_SECONDARY
		fg_color = PALETTE_ONSECONDARY
		'
		'If ctx.mousepressed; ctx.focus = id
		If ctx.mousereleased And ctx.focus = id; result = True		
	Else
		bg_color = PALETTE_PRIMARY 
		fg_color = PALETTE_ONPRIMARY
	End If	
		
	' Draw button frame
	ctx.addCommand( New TDrawFrameCommand( rect, bg_color ) )
	' Draw button Caption, Icon or both
	Select True
	Case caption And icon > 0
		ctx.addCommand( New TDrawTextCommand( caption, rect, fg_color, options ) )
'TODO: Icon
	Case caption <> ""
		ctx.addCommand( New TDrawTextCommand( caption, rect, fg_color, options ) )
	Case icon >0
'TODO: Icon
	Default
		' Invalid combination, so just ignore it
		Return False
	End Select
	
	Return result
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
	
End Function

' Create a label
Function FLabel( ctx:GUIContext Var, caption:String, options:Int=GUI_ALIGNLEFT )

	Local rect:SRect '= ctx.layout.getrect()

	ctx.addCommand( New TDrawTextCommand( caption, rect, PALETTE_ONBACKGROUND, options ) )

End Function

Function FTextbox:Int(ctx:TMU_Context, buf:Byte Ptr, bufsz:Int, opt:Int=0)
DebugStop
Rem
  id:ULong = mu_get_id(ctx, &buf, SizeOf(buf));
  mu_Rect r = mu_layout_next(ctx);
  Return mu_textbox_raw(ctx, buf, bufsz, id, r, opt);
EndRem
EndFunction

Function FSlider:Int(ctx:TMU_Context, value:Float Var, low:Float, high:Float, Steps:Float=0.0, fmt:String=MU_SLIDER_FMT, opt:Int=MU_OPT_ALIGNCENTER )
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