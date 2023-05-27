'# VERSION 1.00 BY N, http://www.blitzbasic.com/codearcs/codearcs.php?code=1653
'# VERSION 1.10



Rem
bbdoc: Gadget base type
End Rem
Type IGadget Abstract
Field _freed:Int = 0
Field gad:TGadget
Field _children:TList = New TList
Field _parent:IGadget
Field _link:TLink
	
Rem
bbdoc: OnAction event handler
End Rem
Field OnActionHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnEnter event handler
End Rem
Field OnEnterHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnLeave event handler
End Rem
Field OnLeaveHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnKeyUp event handler
End Rem
Field OnKeyUpHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnKeyDown event handler
End Rem
Field OnKeyDownHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnKeyChar event handler
End Rem
Field OnKeyCharHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnMouseWheel event handler
End Rem
Field OnMouseWheelHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnMouseUp event handler
End Rem
Field OnMouseUpHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnMouseDown event handler
End Rem
Field OnMouseDownHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnMouseMove event handler
End Rem
Field OnMouseMoveHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnPaint event handler
End Rem
Field OnPaintHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnHotKeyHit event handler
End Rem
Field OnHotKeyHitHandler(sender:IGadget, event:TEvent)
	
Rem
bbdoc: OnInit event handler
End Rem
	'event should always be null for OnInitHandler
Field OnInitHandler(sender:IGadget, event:TEvent)	

Rem
bbdoc: AddChild method
returns: TLink
End Rem
	Method AddChild:TLink(c:IGadget, x:Int, y:Int, w:Int, h:Int)
		Return _children.AddLast(c)
	End Method
	
Rem
bbdoc: GetParentingTGadget method
returns: TGadget
End Rem
	Method GetParentingTGadget:TGadget()
		Return gad
	End Method
	
Rem
bbdoc: Get wrapped TGadget
returns: TGadget
End Rem
	Method GetTGadget:TGadget()
		Return gad
	End Method
	
Rem
bbdoc: Init method
returns: TGadget
End Rem
	Method Init:TGadget(parent:IGadget, x:Int, y:Int, w:Int, h:Int)
		If _freed Then Return Null
		_parent = parent
		If _parent Then _link = _parent.AddChild(Self, x, y, w, h)
		Local par:TGadget = Null
		If _parent Then par = _parent.GetParentingTGadget()
		Return par
	End Method
	
Rem
bbdoc: OnInit event handler method
End Rem
	Method OnInit(evt:TEvent)
		If OnInitHandler Then OnInitHandler Self, evt
	End Method
	
Rem
bbdoc: OnAction event handler method
End Rem
	Method OnAction(evt:TEvent)
		If OnActionHandler Then OnActionHandler Self, evt
	End Method
	
Rem
bbdoc: OnEnter event handler method
End Rem
	Method OnEnter(evt:TEvent)
		If OnEnterHandler Then OnEnterHandler Self, evt
	End Method
	
Rem
bbdoc: OnLeave event handler method
End Rem
	Method OnLeave(evt:TEvent)
		If OnLeaveHandler Then OnLeaveHandler Self, evt
	End Method
	
Rem
bbdoc: OnKeyDown event handler method
End Rem
	Method OnKeyDown(evt:TEvent)
		If OnKeyDownHandler Then OnKeyDownHandler Self, evt
	End Method
	
Rem
bbdoc: OnKeyUp event handler method
End Rem
	Method OnKeyUp(evt:TEvent)
		If OnKeyUpHandler Then OnKeyUpHandler Self, evt
	End Method
	
Rem
bbdoc: OnKeyChar event handler method
End Rem
	Method OnKeyChar(evt:TEvent)
		If OnKeyCharHandler Then OnKeyCharHandler Self, evt
	End Method
	
Rem
bbdoc: OnMouseWheel event handler method
End Rem
	Method OnMouseWheel(evt:TEvent)
		If OnMouseWheelHandler Then OnMouseWheelHandler Self, evt
	End Method
	
Rem
bbdoc: OnMouseDown event handler method
End Rem
	Method OnMouseDown(evt:TEvent)
		If OnMouseDownHandler Then OnMouseDownHandler Self, evt
	End Method
	
Rem
bbdoc: OnMouseUp event handler method
End Rem
	Method OnMouseUp(evt:TEvent)
		If OnMouseUpHandler Then OnMouseUpHandler Self, evt
	End Method
	
Rem
bbdoc: OnMouseMove event handler method
End Rem
	Method OnMouseMove(evt:TEvent)
		If OnMouseMoveHandler Then OnMouseMoveHandler Self, evt
	End Method
	
Rem
bbdoc: OnHotkeyHit event handler method
End Rem
	Method OnHotkeyHit(evt:TEvent)
		If OnHotKeyHitHandler Then OnHotKeyHitHandler Self, evt
	End Method
	
Rem
bbdoc: OnPaint event handler method
End Rem
	Method OnPaint(evt:TEvent)
		If OnPaintHandler Then OnPaintHandler Self, evt
	End Method
	
Rem
bbdoc: New method
End Rem
	Method New()
		AddHook EmitEventHook, _gadUpdate, Self
	End Method
	
Rem
bbdoc: Delete method
End Rem
	Method Delete()
		Free
	End Method
	
Rem
bbdoc: Free method
End Rem
	Method Free()
		If _freed Then Return
		RemoveHook EmitEventHook, _gadUpdate, Self
		For Local i:IGadget = EachIn _children
			i.Free
		Next
		gad.Free
		gad = Null
		OnActionHandler = Null
		OnEnterHandler = Null
		OnLeaveHandler = Null
		OnKeyUpHandler = Null
		OnKeyDownHandler = Null
		OnKeyCharHandler = Null
		OnMouseWheelHandler = Null
		OnMouseUpHandler = Null
		OnMouseDownHandler = Null
		OnMouseMoveHandler = Null
		OnPaintHandler = Null
		OnHotKeyHitHandler = Null
		OnInitHandler = Null
		_freed = True
	End Method
	
Rem
bbdoc: GetState method
returns: Int
End Rem
	Method GetState:Int()
		Return gad.State()
	End Method
	
	' Layout
Rem
bbdoc: Layout method
End Rem
	Method Layout(l:Int, r:Int, t:Int, b:Int)
		If _freed Then Return
		gad.SetLayout l, r, t, b
	End Method
	
	' parenting
Rem
bbdoc: GetParent method
returns: IGadget
End Rem
	Method GetParent:IGadget()
		If _freed Then Return Null
		Return _parent
	End Method
	
Rem
bbdoc: GetChild method
returns: IGadget
End Rem
	Method GetChild:IGadget(idx:Int)
		If _freed Then Return Null
		Return IGadget(_children.ValueAtIndex(idx))
	End Method
	
Rem
bbdoc: Set gadget extra data
End Rem
	Method SetExtra(extra:Object) 
		If _freed Then Return
		gad.extra = extra
	End Method
	
Rem
bbdoc: Get gadget extra data
returns: Object
End Rem
	Method GetExtra:Object()
		If _freed Then Return Null
		Return gad.extra
	End Method
	
Rem
bbdoc: SetPosition method
End Rem
	Method SetPosition(x:Int, y:Int)
		If _freed Then Return
		gad.SetShape x, y, gad.width, gad.height
	End Method
	
Rem
bbdoc: SetSize method
End Rem
	Method SetSize(w:Int, h:Int)
		If _freed Then Return
		gad.SetShape gad.xpos, gad.ypos, w, h
	End Method
	
Rem
bbdoc: GetPosition method
End Rem
	Method GetPosition(x:Int Var, y:Int Var)
		If _freed Then Return
		x = gad.xpos
		y = gad.ypos
	End Method
	
Rem
bbdoc: GetSize method
End Rem
	Method GetSize(x:Int Var, y:Int Var)
		If _freed Then Return
		x = gad.width
		y = gad.height
	End Method
	
Rem
bbdoc: GetX method
returns: Int
End Rem
	Method GetX:Int()
		If _freed Then Return 0
		Local x:Int
		Local y:Int
		GetPosition x, y
		Return x
	End Method
	
Rem
bbdoc: GetY method
returns: Int
End Rem
	Method GetY:Int()
		If _freed Then Return 0
		Local x:Int
		Local y:Int
		GetPosition x, y
		Return y
	End Method
	
Rem
bbdoc: GetWidth method
returns: Int
End Rem
	Method GetWidth:Int()
		If _freed Then Return 0
		Local x:Int
		Local y:Int
		GetSize x, y
		Return x
	End Method
	
Rem
bbdoc: GetHeight method
returns: Int
End Rem
	Method GetHeight:Int()
		If _freed Then Return 0
		Local x:Int
		Local y:Int
		GetSize x, y
		Return y
	End Method
	
Rem
bbdoc: Disable method
End Rem
	Method Disable()
		If _freed Then Return
		gad.SetEnabled False
	End Method
	
Rem
bbdoc: Enable method
End Rem
	Method Enable()
		If _freed Then Return
		gad.SetEnabled True
	End Method
	
Rem
bbdoc: Hide method
End Rem
	Method Hide()
		If _freed Then Return
		gad.SetShow False
	End Method
	
Rem
bbdoc: Show method
End Rem
	Method Show()
		If _freed Then Return
		gad.SetShow True
	End Method
	
Rem
bbdoc: Activate method
End Rem
	Method Activate(cmd:Int)
		If _freed Then Return
		gad.Activate cmd
	End Method
	
Rem
bbdoc: Focus method
End Rem
	Method Focus()
		If _freed Then Return
		Activate ACTIVATE_FOCUS
	End Method
	
Rem
bbdoc: Redraw method
End Rem
	Method Redraw()
		If _freed Then Return
		Activate ACTIVATE_REDRAW
	End Method
	
Rem
bbdoc: SetAlpha method
End Rem
	Method SetAlpha(a:Float)
		If _freed Then Return
		gad.SetAlpha a
	End Method
	
Rem
bbdoc: SetTextColor method
End Rem
	Method SetTextColor(r:Int, g:Int, b:Int)
		If _freed Then Return
		gad.SetTextColor r, g, b
	End Method
	
Rem
bbdoc: SetBackColor method
End Rem
	Method SetBackColor(r:Int, g:Int, b:Int)
		If _freed
			Return
		End If
		gad.SetColor r, g, b
	End Method
	
	' Font
Rem
bbdoc: SetFont method
End Rem
	Method SetFont(font:TGuiFont)
		If _freed
			Return
		End If
		gad.SetFont font
	End Method
	
Rem
bbdoc: SetCaption method
End Rem
	Method SetCaption(text:String)
		If _freed
			Return
		End If
		gad.SetText text
	End Method
	
	' Text
Rem
bbdoc: GetText method
returns: String
End Rem
	Method GetText:String()
		If _freed
			Return ""
		End If
		Return gad.GetText()
	End Method
	
Rem
bbdoc: SetText method
End Rem
	Method SetText(t:String)
		If _freed
			Return
		End If
		gad.SetText t
	End Method
	
End Type

Rem
bbdoc: Desktop gadget type
End Rem
Type IDesktop Extends IGadget
Rem
bbdoc: New method
End Rem
	Method New()
		gad = Desktop()
	End Method
	
End Type

Rem
bbdoc: Window gadget type
End Rem
Type IWindow Extends IGadget
Rem
bbdoc: rootMenu field
End Rem
	Field rootMenu:IMenu
	
Rem
bbdoc: OnFocus event handler
End Rem
	Field OnFocusHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: OnClose event handler
End Rem
	Field OnCloseHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: OnMove event handler
End Rem
	Field OnMoveHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: OnResize event handler
End Rem
	Field OnResizeHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: OnDragDrop event handler
End Rem
	Field OnDragDropHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: OnFocus event handler method
End Rem
	Method OnFocus(evt:TEvent)
		If OnFocusHandler
			OnFocusHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: OnClose event handler method
End Rem
	Method OnClose(evt:TEvent)
		If OnCloseHandler
			OnCloseHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: OnMove event handler method
End Rem
	Method OnMove(evt:TEvent)
		If OnMoveHandler
			OnMoveHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: OnResize event handler method
End Rem
	Method OnResize(evt:TEvent)
		If OnResizeHandler
			OnResizeHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: OnDragDrop event handler method
End Rem
	Method OnDragDrop(evt:TEvent)
		If OnDragDropHandler
			OnDragDropHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: Free method
End Rem
	Method Free()
		If _freed
			Return
		End If
		For Local i:IGadget = EachIn rootMenu._children
			i.Free
		Next
		rootMenu._children.Clear
		rootMenu._children = Null
		rootMenu._parent = Null
		rootMenu.gad = Null
		rootMenu = Null
		OnFocusHandler = Null
		OnCloseHandler = Null
		OnMoveHandler = Null
		OnResizeHandler = Null
		OnDragDropHandler = Null
		Super.Free
	End Method
	
Rem
bbdoc: Create method
End Rem
	Method Create:IWindow(parent:IGadget, x:Int, y:Int, w:Int, h:Int, caption:String, titlebar:Int = 1, sizable:Int = 1, menu:Int = 1, statusbar:Int = 1, hidden:Int = 1, dragdrop:Int = 0, tool:Int = 0)
		If _freed
			Return Null
		End If
		Local f:Int = WINDOW_CLIENTCOORDS
		
		If (titlebar > 0)
			f :| WINDOW_TITLEBAR
		End If
		If (sizable > 0)
			f :| WINDOW_RESIZABLE
		End If
		If (menu > 0)
			f :| WINDOW_MENU
		End If
		If (statusbar > 0)
			f :| WINDOW_STATUS
		End If
		If (hidden > 0)
			f :| WINDOW_HIDDEN
		End If
		If (dragdrop > 0)
			f :| WINDOW_ACCEPTFILES
		End If
		If (tool > 0)
			f :| WINDOW_TOOL
		End If
		gad = CreateWindow(caption, x, y, w, h, Init(parent, x, y, w, h), f)
		rootMenu = New IMenu
		rootMenu.gad = gad.GetMenu()
		rootMenu._parent = Self
		OnInit Null
	Return Self
	End Method
	
Rem
bbdoc: AddMenu method
returns: IMenu
End Rem
	Method AddMenu:IMenu(caption:String, tag:Int, hotkey:Int = 0, modifier:Int = 0)
		If _freed
			Return Null
		End If
		Local menu:IMenu = New IMenu
		
		menu.Create rootMenu, caption, tag, hotkey, modifier
		Return menu
	End Method
	
Rem
bbdoc: UpdateMenu method
End Rem
	Method UpdateMenu()
		If _freed
			Return
		End If
		gad.UpdateMenu
	End Method
	
Rem
bbdoc: Maximized method
returns: Int
End Rem
	Method Maximized:Int()
		If _freed
			Return 0
		End If
		Return (GetState() & STATE_MAXIMIZED)
	End Method
	
Rem
bbdoc: Maximize method
End Rem
	Method Maximize()
		If _freed
			Return
		End If
		Activate ACTIVATE_MAXIMIZE
	End Method
	
Rem
bbdoc: Minimized method
returns: Int
End Rem
	Method Minimized:Int()
		If _freed
			Return 0
		End If
		Return (GetState() & STATE_MINIMIZED)
	End Method
	
Rem
bbdoc: Minimize method
End Rem
	Method Minimize()
		If _freed
			Return
		End If
		Activate ACTIVATE_MINIMIZE
	End Method
	
Rem
bbdoc: Restore method
End Rem
	Method Restore()
		If _freed
			Return
		End If
		Activate ACTIVATE_RESTORE
	End Method
	
Rem
bbdoc: SetMinimumSize method
End Rem
	Method SetMinimumSize(w:Int, h:Int)
		If _freed
			Return
		End If
		gad.SetMinimumSize w, h
	End Method
	
Rem
bbdoc: SetStatusText method
End Rem
	Method SetStatusText(text:String)
		If _freed
			Return
		End If
		gad.SetStatusText text
	End Method
	
End Type

Rem
bbdoc: Button gadget type
End Rem
Type IButton Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, caption:String, type_:Int=BUTTON_NORMAL)
		If _freed
			Return
		End If
		Local f:Int = (BUTTON_PUSH | type_)
		
		gad = CreateButton(caption, x, y, w, h, Init(parent, x, y, w, h), f)
		OnInit Null
	End Method
	
End Type

Const BUTTON_NORMAL:Int = 0

Rem
bbdoc: Checkbox gadget type
End Rem
Type ICheckbox Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, caption:String, checked:Int = False)
		If _freed
			Return
		End If
		Local f:Int = BUTTON_CHECKBOX
		
		gad = CreateButton(caption, x, y, w, h, Init(parent, x, y, w, h), f)
		If (checked > 0)
			Check
		End If
		OnInit Null
	End Method
	
Rem
bbdoc: chk field
End Rem
	Field chk:Int = 0
	
Rem
bbdoc: Check method
End Rem
	Method Check()
		If _freed
			Return
		End If
		gad.SetSelected True
		chk = True
	End Method
	
Rem
bbdoc: Uncheck method
End Rem
	Method Uncheck()
		If _freed
			Return
		End If
		gad.SetSelected False
		chk = False
	End Method
	
Rem
bbdoc: Checked method
returns: Int
End Rem
	Method Checked:Int()
		If _freed
			Return - 1
		End If
		Return chk
	End Method
	
End Type

Rem
bbdoc: A checkbutton is a button that functions as a checkbox. It may not be available on all platforms.
End Rem
Type ICheckButton Extends ICheckbox
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, caption:String, checked:Int = False)
		If _freed
			Return
		End If
		Local f:Int = BUTTON_CHECKBOX | BUTTON_PUSH
		
		gad = CreateButton(caption, x, y, w, h, Init(parent, x, y, w, h), f)
		If (checked > 0)
			Check
		End If
		OnInit Null
	End Method
	
End Type

Rem
bbdoc: RadioGroup gadget type
End Rem
Type IRadioGroup
	
	Global list:TList = New TList
	
	Field _link:TLink
	
Rem
bbdoc: Group id field
End Rem
	Field group:Int
	
Rem
bbdoc: List of radioboxes
End Rem
	Field tickers:TList = New TList
	
	Method New()
		_link = list.AddLast(Self)
	End Method
	
Rem
bbdoc: Remove a radiobox from its group, deleting group if empty.
End Rem
	Method Remove(gad:IRadiobox)
		gad._glink.Remove
		gad._glink = Null
		If (tickers.Count() = 0)
			_link.Remove
			_link = Null
			tickers = Null
		End If
	End Method
	
End Type

Rem
bbdoc: Radiobox gadget type
End Rem
Type IRadiobox Extends IGadget
Rem
bbdoc: The group this belongs to
End Rem
	Field group:IRadioGroup
	
	Field _glink:TLink
	
Rem
bbdoc: Checked of not
End Rem
	Field chk:Int = 0
	
Rem
bbdoc: Free method
End Rem
	Method Free()
		If _freed
			Return
		End If
		group.Remove Self
		Super.Free
	End Method
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, caption:String, groupid:Int, ticked:Int = False)
		If _freed
			Return
		End If
		Local f:Int = BUTTON_RADIO
		
		gad = CreateButton(caption, x, y, w, h, Init(parent, x, y, w, h), f)
		Local g:IRadioGroup = Null
		
		For Local i:IRadioGroup = EachIn IRadioGroup.list
			If (i.group = groupid)
				g = i
				Exit
			End If
		Next
		If Not g
			g = New IRadioGroup
			g.group = groupid
		End If
		group = g
		_glink = g.tickers.AddLast(Self)
		OnInit Null
	End Method
	
Rem
bbdoc: Check method
End Rem
	Method Check()
		If _freed
			Return
		End If
		gad.SetSelected True
		chk = True
		For Local i:IRadiobox = EachIn group.tickers
			If (i <> Self)
				i.Uncheck
			End If
		Next
	End Method
	
Rem
bbdoc: Uncheck method
End Rem
	Method Uncheck()
		If _freed
			Return
		End If
		gad.SetSelected False
		chk = False
	End Method
	
Rem
bbdoc: Checked method
returns: Int
End Rem
	Method Checked:Int()
		If _freed
			Return - 1
		End If
		Return chk
	End Method
	
Rem
bbdoc: OnAction event handler method
End Rem
	Method OnAction(evt:TEvent)
		Check
		Super.OnAction evt
	End Method
	
End Type

Rem
bbdoc: A radiobutton is a button functioning as a radio box. It may not be available on all platforms.
End Rem
Type IRadioButton Extends IRadiobox
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, caption:String, groupid:Int, ticked:Int = False)
		If _freed
			Return
		End If
		Local f:Int = BUTTON_RADIO | BUTTON_PUSH
		
		gad = CreateButton(caption, x, y, w, h, Init(parent, x, y, w, h), f)
		Local g:IRadioGroup = Null
		
		For Local i:IRadioGroup = EachIn IRadioGroup.list
			If (i.group = groupid)
				g = i
				Exit
			End If
		Next
		If Not g
			g = New IRadioGroup
			g.group = groupid
		End If
		group = g
		_glink = g.tickers.AddLast(Self)
		OnInit Null
	End Method
	
End Type

Rem
bbdoc: Canvas gadget type
End Rem
Type ICanvas Extends IGadget
Rem
bbdoc: Graphics object
End Rem
	Field gfx:TGraphics
	
Rem
bbdoc: Create method
End Rem
	Method Create:ICanvas(parent:IGadget, x:Int, y:Int, w:Int, h:Int, border:Int = 0)
		If _freed
			Return Null
		End If
		Local f:Int = ((border > 0) * PANEL_BORDER)
		
		gad = CreateCanvas(x, y, w, h, Init(parent, x, y, w, h), f)
		gfx = gad.CanvasGraphics()
		OnInit Null
		Return Self
	End Method
	
End Type

Rem
bbdoc: Panel gadget type
End Rem
Type IPanel Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, border:Int = 0, moveEvent:Int = 0)
		If _freed
			Return
		End If
		Local f:Int = (((border > 0) * PANEL_BORDER) | ((moveEvent > 0) * PANEL_ACTIVE))
		
		gad = CreatePanel(x, y, w, h, Init(parent, x, y, w, h), f, "")
		OnInit Null
	End Method
	
Rem
bbdoc: SetPixmap method
End Rem
	Method SetPixmap(pix:TPixmap, flags:Int)
		If _freed
			Return
		End If
		gad.SetPixmap pix, flags
	End Method
	
End Type

Rem
bbdoc: Groupbox gadget type
End Rem
Type IGroupbox Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, caption:String, moveEvent:Int = 0)
		If _freed
			Return
		End If
		Local f:Int = (PANEL_GROUP | ((moveEvent > 0) * PANEL_ACTIVE))
		
		gad = CreatePanel(x, y, w, h, Init(parent, x, y, w, h), f, caption)
		OnInit Null
	End Method
	
End Type

Rem
bbdoc: ComboBox gadget type
End Rem
Type IComboBox Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, editable:Int = 0)
		If _freed
			Return
		End If
		Local f:Int = ((editable > 0) * COMBOBOX_EDITABLE)
		
		gad = CreateComboBox(x, y, w, h, Init(parent, x, y, w, h), f)
		OnInit Null
	End Method
	
Rem
bbdoc: SelectedItem method
returns: Int
End Rem
	Method SelectedItem:Int()
		If _freed
			Return 0
		End If
		Return gad.SelectedItem()
	End Method
	
Rem
bbdoc: SelectItem method
End Rem
	Method SelectItem(idx:Int)
		If _freed
			Return
		End If
		gad.SelectItem idx, 1
	End Method
	
Rem
bbdoc: AddItem method
returns: Int
End Rem
	Method AddItem:Int(caption:String, icon:Int = - 1, isDefault:Int = 0, tip:String = "", extra:Object = Null)
		If _freed
			Return 0
		End If
		AddGadgetItem gad, caption, ((isDefault > 0) * GADGETITEM_DEFAULT), icon, tip, extra
		Return (gad.ItemCount() - 1)
	End Method
	
Rem
bbdoc: RemoveItem method
End Rem
	Method RemoveItem(idx:Int)
		If _freed
			Return
		End If
	RemoveGadgetItem gad, idx
	End Method
	
Rem
bbdoc: GetItemCaption method
returns: String
End Rem
	Method GetItemCaption:String(idx:Int)
		If _freed
			Return ""
		End If
		Return GadgetItemText(gad, idx)
	End Method
	
Rem
bbdoc: GetItemExtra method
returns: Object
End Rem
	Method GetItemExtra:Object(idx:Int)
		If _freed
			Return Null
		End If
		Return GadgetItemExtra(gad, idx)
	End Method
	
End Type

Rem
bbdoc: HTMLView gadget type
End Rem
Type IHTMLView Extends IGadget
Rem
bbdoc: OnLoaded event handler
End Rem
	Field OnLoadedHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, nonav:Int = 0, noctx:Int = 0)
		If _freed
			Return
		End If
		Local f:Int = 0
		
		If (nonav > 0)
			f :| HTMLVIEW_NONAVIGATE
		End If
		If (noctx > 0)
			f :| HTMLVIEW_NOCONTEXTMENU
		End If
		gad = CreateHTMLView(x, y, w, h, Init(parent, x, y, w, h), f)
		OnInit Null
	End Method
	
Rem
bbdoc: GetURL method
returns: String
End Rem
	Method GetURL:String()
		If _freed
			Return ""
		End If
		Return gad.GetText()
	End Method
	
Rem
bbdoc: SetURL method
End Rem
	Method SetURL(url:String)
		If _freed
			Return
		End If
		gad.SetText url
	End Method
	
Rem
bbdoc: Back method
End Rem
	Method Back()
		If _freed
			Return
		End If
		Activate ACTIVATE_BACK
	End Method
	
Rem
bbdoc: Forward method
End Rem
	Method Forward()
		If _freed
			Return
		End If
		Activate ACTIVATE_FORWARD
	End Method
	
Rem
bbdoc: RunScript method
returns: String
End Rem
	Method RunScript:String(script:String)
		If _freed
			Return ""
		End If
		Return gad.Run(script)
	End Method
	
Rem
bbdoc: OnLoaded method
End Rem
	Method OnLoaded(evt:TEvent)
		If OnLoadedHandler
			OnLoadedHandler Self, evt
		End If
	End Method
	
End Type

Rem
bbdoc: Label gadget type
End Rem
Type ILabel Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, text:String, frameType:Int=LABEL_NOFRAME, align:Int=LABEL_LEFT)
		If _freed
			Return
		End If
		Local f:Int = (frameType | align)
		
		If (text = "--")
			f :| LABEL_SEPARATOR
		End If
		gad = CreateLabel(text, x, y, w, h, Init(parent, x, y, w, h), f)
		OnInit Null
	End Method
	
End Type

Const LABEL_NOFRAME:Int = 0

Rem
bbdoc: ListBox gadget type
End Rem
Type IListBox Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int)
		If _freed
			Return
		End If
		Local f:Int = 0
		
		gad = CreateListBox(x, y, w, h, Init(parent, x, y, w, h), f)
		OnInit Null
	End Method
	
Rem
bbdoc: AddItem method
returns: Int
End Rem
	Method AddItem:Int(caption:String, icon:Int = - 1, isDefault:Int = 0, tip:String = "", extra:Object = Null)
		If _freed
			Return 0
		End If
		AddGadgetItem gad, caption, ((isDefault > 0) * GADGETITEM_DEFAULT), icon, tip, extra
		Return (gad.ItemCount() - 1)
	End Method
	
Rem
bbdoc: SelectItem method
End Rem
	Method SelectItem(idx:Int)
		If _freed
			Return
		End If
		gad.SelectItem idx, 1
	End Method
	
Rem
bbdoc: RemoveItem method
End Rem
	Method RemoveItem(idx:Int)
		If _freed
			Return
		End If
	RemoveGadgetItem gad, idx
	End Method
	
Rem
bbdoc: SelectedItem method
returns: Int
End Rem
	Method SelectedItem:Int()
		If _freed
			Return 0
		End If
		Return gad.SelectedItem()
	End Method
	
Rem
bbdoc: SelectedItems method
returns: 
End Rem
	Method SelectedItems:Int[]()
		If _freed
			Return Null
		End If
		Return gad.SelectedItems()
	End Method
	
Rem
bbdoc: GetItemCaption method
returns: String
End Rem
	Method GetItemCaption:String(idx:Int)
		If _freed
			Return ""
		End If
		Return GadgetItemText(gad, idx)
	End Method
	
Rem
bbdoc: GetItemExtra method
returns: Object
End Rem
	Method GetItemExtra:Object(idx:Int)
		If _freed
			Return Null
		End If
		Return GadgetItemExtra(gad, idx)
	End Method
	
End Type

Rem
bbdoc: Menu gadget type
End Rem
Type IMenu Extends IGadget
Rem
bbdoc: OnSelect event handler
End Rem
	Field OnSelectHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: id field
End Rem
	Field id:Int
	
Rem
bbdoc: chk field
End Rem
	Field chk:Int = 0
	
Rem
bbdoc: Free method
End Rem
	Method Free()
		If _freed
			Return
		End If
		OnSelectHandler = Null
		Super.Free
	End Method
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, caption:String, tag:Int, hotkey:Int = 0, modifier:Int = 0)
		If _freed
			Return
		End If
		gad = CreateMenu(caption, tag, Init(parent, 0, 0, 0, 0), hotkey, modifier)
		id = tag
		OnInit Null
	End Method
	
Rem
bbdoc: AddMenu method
returns: IMenu
End Rem
	Method AddMenu:IMenu(caption:String, tag:Int, hotkey:Int = 0, modifier:Int = 0)
		If _freed
			Return Null
		End If
		Local menu:IMenu = New IMenu
		
		menu.Create Self, caption, tag, hotkey, modifier
		Return menu
	End Method
	
Rem
bbdoc: OnSelect event handler method
End Rem
	Method OnSelect(evt:TEvent)
		If OnSelectHandler
			OnSelectHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: Popup method
End Rem
	Method Popup(on:IGadget)
		If _freed
			Return
		End If
		on.gad.PopupMenu gad
	End Method
	
Rem
bbdoc: Check method
End Rem
	Method Check()
		If _freed
			Return
		End If
		gad.SetSelected True
		chk = True
	End Method
	
Rem
bbdoc: Uncheck method
End Rem
	Method Uncheck()
		If _freed
			Return
		End If
		gad.SetSelected False
		chk = False
	End Method
	
Rem
bbdoc: Checked method
returns: Int
End Rem
	Method Checked:Int()
		If _freed
			Return - 1
		End If
		Return chk
	End Method
	
End Type

Rem
bbdoc: ProgressBar gadget type
End Rem
Type IProgressBar Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int)
		If _freed
			Return
		End If
		gad = CreateProgBar(x, y, w, h, Init(parent, x, y, w, h), 0)
		OnInit Null
	End Method
	
Rem
bbdoc: SetValue method
End Rem
	Method SetValue(progress:Float)
		If _freed
			Return
		End If
		gad.SetValue progress
	End Method
	
End Type

Rem
bbdoc: Slider gadget type
End Rem
Type ISlider Extends IGadget
Rem
bbdoc: SetRange method
End Rem
	Method SetRange(min_:Int, max_:Int)
		If _freed
			Return
		End If
		gad.SetRange min_, max_
	End Method
	
Rem
bbdoc: SetValue method
End Rem
	Method SetValue(value:Int)
		If _freed
			Return
		End If
		gad.SetProp value
	End Method
	
Rem
bbdoc: GetValue method
returns: Int
End Rem
	Method GetValue:Int()
		If _freed
			Return 0
		End If
		Return gad.GetProp()
	End Method
	
End Type

Rem
bbdoc: Scrollbar gadget type
End Rem
Type IScrollbar Extends ISlider
	Const _flags:Int = SLIDER_SCROLLBAR
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, vertical:Int = 0, range_min:Int = 1, range_max:Int = 10)
		If _freed
			Return
		End If
		Local f:Int = SLIDER_HORIZONTAL
		
		If (vertical > 0)
			f = SLIDER_VERTICAL
		End If
		f :| _flags
		gad = CreateSlider(x, y, w, h, Init(parent, x, y, w, h), f)
		SetRange range_min, range_max
		OnInit Null
	End Method
	
End Type

Rem
bbdoc: Tracker gadget type
End Rem
Type ITracker Extends ISlider
	Const _flags:Int = SLIDER_TRACKBAR
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, vertical:Int = 0, range_min:Int = 1, range_max:Int = 10)
		If _freed
			Return
		End If
		Local f:Int = SLIDER_HORIZONTAL
		
		If (vertical > 0)
			f = SLIDER_VERTICAL
		End If
		f :| _flags
		gad = CreateSlider(x, y, w, h, Init(parent, x, y, w, h), f)
		SetRange range_min, range_max
		OnInit Null
	End Method
	
End Type

Rem
bbdoc: Stepper gadget type
End Rem
Type IStepper Extends ISlider
	Const _flags:Int = SLIDER_STEPPER
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, vertical:Int = 0, range_min:Int = 1, range_max:Int = 10)
		If _freed
			Return
		End If
		Local f:Int = SLIDER_HORIZONTAL
		
		If (vertical > 0)
			f = SLIDER_VERTICAL
		End If
		f :| _flags
		gad = CreateSlider(x, y, w, h, Init(parent, x, y, w, h), f)
		SetRange range_min, range_max
		OnInit Null
	End Method
	
End Type

Rem
bbdoc: TabStrip gadget type
End Rem
Type ITabStrip Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int)
		If _freed
			Return
		End If
		gad = CreateTabber(x, y, w, h, Init(parent, x, y, w, h), 0)
		OnInit Null
	End Method
	
Rem
bbdoc: AddPage method
returns: Int
End Rem
	Method AddPage:Int(caption:String, icon:Int = - 1, tip:String = "", extra:Object = Null)
		If _freed
			Return - 1
		End If
		AddGadgetItem gad, caption, False, icon, tip, extra
		Return (gad.ItemCount() - 1)
	End Method
	
Rem
bbdoc: RemovePage method
End Rem
	Method RemovePage(idx:Int)
	RemoveGadgetItem gad, idx
	End Method
	
Rem
bbdoc: SelectPage method
End Rem
	Method SelectPage(page:Int)
		If _freed
			Return
		End If
		gad.SelectItem page, 1
	End Method
	
Rem
bbdoc: SelectedPage method
returns: Int
End Rem
	Method SelectedPage:Int()
		If _freed
			Return 0
		End If
		Return gad.SelectedItem()
	End Method
	
End Type

Rem
bbdoc: TextBox gadget type
End Rem
Type ITextBox Extends IGadget
	Field _area:Int = 0
	
Rem
bbdoc: OnMenu event handler
End Rem
	Field OnMenuHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: Free method
End Rem
	Method Free()
		If _freed
			Return
		End If
		OnMenuHandler = Null
		Super.Free
	End Method
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, text:String = "", multiline:Int = 0, readonly:Int = 0, wordwrap:Int = 0, password:Int = 0)
		If _freed
			Return
		End If
		Local par:TGadget = Init(parent, x, y, w, h)
		
		Local f:Int = 0
		
		If (multiline > 0)
			_area = True
			If (readonly > 0)
				f :| TEXTAREA_READONLY
			End If
			If (wordwrap > 0)
				f :| TEXTAREA_WORDWRAP
			End If
			gad = CreateTextArea(x, y, w, h, par, f)
			If (password > 0)
				f :| TEXTFIELD_PASSWORD
			End If
			gad = CreateTextField(x, y, w, h, par, f)
		End If
		OnInit Null
	End Method
	
Rem
bbdoc: OnMenu event handler method
End Rem
	Method OnMenu(evt:TEvent)
		If OnMenuHandler
			OnMenuHandler Self, evt
		End If
	End Method
	
	Field _fbuf:String = ""
	
	Field _lock:Int = 0
	
Rem
bbdoc: SelectText method
returns: String
End Rem
	Method SelectText:String(from:Int = 0, length:Int = - 1, selectLines:Int = 0)
		If _freed
			Return ""
		End If
		If _area
			Local f:Int = TEXTAREA_CHARS
			
			If (selectLines > 0)
				f = TEXTAREA_LINES
			End If
			If (length = - 1)
				length = TEXTAREA_ALL
			End If
			Return gad.AreaText(from, length, f)
			Local s:String
			
			If Not _lock
				s = gad.GetText()
				s = _fbuf
			End If
			If (((length = - 1) Or (length = s.length)) And (from = 0))
				Return s
			End If
			If (length = - 1)
				length = (s.length - from)
			End If
			Return s[from..(from + length)]
		End If
	End Method
	
Rem
bbdoc: GetText method
returns: String
End Rem
	Method GetText:String()
		If _freed
			Return ""
		End If
		Return SelectText()
	End Method
	
Rem
bbdoc: SetText method
End Rem
	Method SetText(t:String)
		If _freed
			Return
		End If
		ReplaceText t
	End Method
	
Rem
bbdoc: ReplaceText method
End Rem
	Method ReplaceText(t:String, pos:Int = 0, length:Int = - 1, lines:Int = 0)
		If _freed
			Return
		End If
		If _area
			If (length = - 1)
				length = TEXTAREA_ALL
			End If
			If (lines > 0)
				lines = TEXTAREA_LINES
				lines = TEXTAREA_CHARS
			End If
			gad.ReplaceText pos, length, t, lines
			If _lock
				If ((pos = 0) And ((length = - 1) Or (length = _fbuf.length)))
					_fbuf = t
					Return
				End If
				If (length = - 1)
					length = (_fbuf.length - pos)
				End If
				If (pos = _fbuf.length)
					_fbuf :+ t
				Else If ((pos = 0) And (length = 0))
					_fbuf = (t + _fbuf)
				End If
				Local s:String
				
				If ((pos = 0) And ((length = - 1) Or (length = _fbuf.length)))
					s = t
					If (length = - 1)
						length = (_fbuf.length - pos)
					End If
					s = GetText()
					If (pos = _fbuf.length)
						s :+ t
					Else If ((pos = 0) And (length = 0))
						s = (t + s)
					End If
				End If
				gad.SetText s
			End If
		End If
	End Method
	
Rem
bbdoc: GetPos method
returns: Int
End Rem
	Method GetPos:Int(lines:Int = False)
		If _freed
			Return 0
		End If
		If Not _area
			Return 0
		End If
		Local f:Int = TEXTAREA_CHARS
		
		If (lines > 0)
			f = TEXTAREA_LINES
		End If
		Return gad.GetCursorPos(f)
	End Method
	
Rem
bbdoc: Lock method
End Rem
	Method Lock()
		If _freed
			Return
		End If
		_lock :+ 1
		If ((_lock = 1) And _area)
			gad.LockText
		Else If (_lock = 1)
			_fbuf = GetText()
		End If
	End Method
	
Rem
bbdoc: Unlock method
End Rem
	Method Unlock()
		If _freed
			Return
		End If
		Assert (_lock > 0), "Text box not locked"
		_lock :- 1
		If ((_lock = 0) And _area)
			gad.UnlockText
		Else If (_lock = 0)
			SetText _fbuf
		End If
	End Method
	
End Type

Rem
bbdoc: Toolbar gadget type
End Rem
Type IToolbar Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int, source:Object)
		If _freed
			Return
		End If
		gad = CreateToolbar(source, x, y, w, h, Init(parent, x, y, w, h), 0)
		OnInit Null
	End Method
	
Rem
bbdoc: SetTips method
End Rem
	Method SetTips(tips:String[])
		For Local i:Int = 0 To (tips.length - 1)
			SetItem i, "", 0, i, tips[i]
		Next
	End Method
	
Rem
bbdoc: SetItem method
End Rem
	Method SetItem(idx:Int, caption:String, toggle:Int = 0, icon:Int = - 1, tip:String = "", extra:Object = Null)
		ModifyGadgetItem gad, idx, caption, ((toggle > 0) * GADGETITEM_TOGGLE), icon, tip, extra
	End Method
	
Rem
bbdoc: AddItem method
End Rem
	Method AddItem(caption:String, toggle:Int = 0, icon:Int = - 1, tip:String = "", extra:Object = Null)
		If _freed
			Return
		End If
		AddGadgetItem gad, caption, ((toggle > 0) * GADGETITEM_TOGGLE), icon, tip, extra
	End Method
	
Rem
bbdoc: RemoveItem method
End Rem
	Method RemoveItem(idx:Int)
		If _freed
			Return
		End If
	RemoveGadgetItem gad, idx
	End Method
	
Rem
bbdoc: GetItemCaption method
returns: String
End Rem
	Method GetItemCaption:String(idx:Int)
		If _freed
			Return ""
		End If
		Return GadgetItemText(gad, idx)
	End Method
	
Rem
bbdoc: GetItemExtra method
returns: Object
End Rem
	Method GetItemExtra:Object(idx:Int)
		If _freed
			Return Null
		End If
		Return GadgetItemExtra(gad, idx)
	End Method
	
End Type

Rem
bbdoc: TreeView gadget type
End Rem
Type ITreeView Extends IGadget
Rem
bbdoc: OnMenu event handler
End Rem
	Field OnMenuHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: OnSelect event handler
End Rem
	Field OnSelectHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: OnExpand event handler
End Rem
	Field OnExpandHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: OnCollapse event handler
End Rem
	Field OnCollapseHandler(sender:IGadget, e:TEvent)
	
Rem
bbdoc: Root node
End Rem
	Field root:ITreeNode
	
Rem
bbdoc: Free method
End Rem
	Method Free()
		If (_freed = True)
			Return
		End If
		For Local i:IGadget = EachIn root._children
			i.Free
		Next
		root._children.Clear
		root._children = Null
		root._parent = Null
		root.gad = Null
		root = Null
		OnMenuHandler = Null
		OnSelectHandler = Null
		OnExpandHandler = Null
		OnCollapseHandler = Null
		Super.Free
	End Method
	
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, x:Int, y:Int, w:Int, h:Int)
		If _freed
			Return
		End If
		gad = CreateTreeView(x, y, w, h, Init(parent, x, y, w, h), 0)
		root = New ITreeNode
		root._parent = Self
		root.gad = TreeViewRoot(gad)
		OnInit Null
	End Method
	
Rem
bbdoc: AddNode method
returns: ITreeNode
End Rem
	Method AddNode:ITreeNode(text:String, icon:Int = - 1)
		If _freed
			Return Null
		End If
		Local node:ITreeNode = New ITreeNode
		
		node.Create root, text, icon
		Return node
	End Method
	
Rem
bbdoc: OnMenu event handler method
End Rem
	Method OnMenu(evt:TEvent)
		If OnMenuHandler
			OnMenuHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: OnSelect event handler method
End Rem
	Method OnSelect(evt:TEvent)
		If OnSelectHandler
			OnSelectHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: OnExpand event handler method
End Rem
	Method OnExpand(evt:TEvent)
		If OnExpandHandler
			OnExpandHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: OnCollapse event handler method
End Rem
	Method OnCollapse(evt:TEvent)
		If OnCollapseHandler
			OnCollapseHandler Self, evt
		End If
	End Method
	
Rem
bbdoc: Clear method
End Rem
	Method Clear()
		If _freed
			Return
		End If
		For Local i:IGadget = EachIn root._children
			i.Free
		Next
	End Method
	
Rem
bbdoc: GetRoot method
returns: ITreeNode
End Rem
	Method GetRoot:ITreeNode()
		If _freed
			Return Null
		End If
		Return root
	End Method
	
Rem
bbdoc: GetSelected method
returns: ITreeNode
End Rem
	Method GetSelected:ITreeNode()
		If _freed
			Return Null
		End If
		Local sel:TGadget = gad.SelectedNode()
		
		If (sel = Null)
			Return Null
		End If
		Return root.FindByGad(sel)
	End Method
	
End Type

Rem
bbdoc: TreeNode gadget type
End Rem
Type ITreeNode Extends IGadget
Rem
bbdoc: Create method
End Rem
	Method Create(parent:IGadget, text:String, icon:Int = - 1)
		If _freed
			Return
		End If
		gad = AddTreeViewNode(text, Init(parent, 0, 0, 0, 0), icon)
		OnInit Null
	End Method
	
Rem
bbdoc: Clear method
End Rem
	Method Clear()
		If _freed
			Return
		End If
		For Local i:IGadget = EachIn _children
			i.Free
		Next
	End Method
	
Rem
bbdoc: AddNode method
returns: ITreeNode
End Rem
	Method AddNode:ITreeNode(text:String, icon:Int = - 1)
		If _freed
			Return Null
		End If
		Local node:ITreeNode = New ITreeNode
		
		node.Create Self, text, icon
		Return node
	End Method
	
Rem
bbdoc: SelectNode method
End Rem
	Method SelectNode()
		If _freed
			Return
		End If
		gad.Activate ACTIVATE_SELECT
	End Method
	
Rem
bbdoc: Expand method
End Rem
	Method Expand()
		If _freed
			Return
		End If
		gad.Activate ACTIVATE_EXPAND
	End Method
	
Rem
bbdoc: Collapse method
End Rem
	Method Collapse()
		If _freed
			Return
		End If
		gad.Activate ACTIVATE_COLLAPSE
	End Method
	
Rem
bbdoc: FindByGad method
returns: ITreeNode
End Rem
	Method FindByGad:ITreeNode(g:TGadget)
		If _freed
			Return Null
		End If
		If (gad = g)
			Return Self
		End If
		For Local i:ITreeNode = EachIn _children
			Local o:ITreeNode = i.FindByGad(g)
			
			If o
				Return o
			End If
		Next
		Return Null
	End Method
	
End Type

Private

Function _gadUpdate:Object(id:Int, obj:Object, ctx:Object) 
	Local gad:IGadget = IGadget(ctx)
	
	Local evt:TEvent = TEvent(obj)
	
	If (Not gad Or Not evt)
		Return obj
	End If
	Local m:IMenu = IMenu(gad)
	
	If (((evt.id = EVENT_MENUACTION) And (m = Null)) Or (gad.gad = Null))
		Return obj
	End If
	If ((evt.source <> gad.gad) And (m = Null))
		Return obj
	End If
	If gad._freed
		Return obj
	End If
	Select evt.id
	Case EVENT_MOUSEENTER
		gad.OnEnter evt
	Case EVENT_MOUSELEAVE
		gad.OnLeave evt
	Case EVENT_KEYDOWN
		gad.OnKeyDown evt
	Case EVENT_KEYUP
		gad.OnKeyUp evt
	Case EVENT_KEYCHAR
		gad.OnKeyChar evt
	Case EVENT_MOUSEMOVE
		gad.OnMouseMove evt
	Case EVENT_MOUSEWHEEL
		gad.OnMouseWheel evt
	Case EVENT_MOUSEDOWN
		gad.OnMouseDown evt
	Case EVENT_MENUACTION
		If (m.id = evt.data)
			m.OnAction evt
		End If
	Case EVENT_WINDOWMOVE
		If IWindow(gad)
			IWindow(gad).OnMove evt
		End If
	Case EVENT_WINDOWACTIVATE
		If IWindow(gad)
			IWindow(gad).OnFocus evt
		End If
	Case EVENT_WINDOWSIZE
		If IWindow(gad)
			IWindow(gad).OnResize evt
		End If
	Case EVENT_WINDOWACCEPT
		If IWindow(gad)
			IWindow(gad).OnDragDrop evt
		End If
	Case EVENT_WINDOWCLOSE
		If IWindow(gad)
			IWindow(gad).OnClose evt
		End If
	Case EVENT_GADGETOPEN
		If ITreeView(gad)
			ITreeView(gad).OnExpand evt
		End If
	Case EVENT_GADGETCLOSE
		If ITreeView(gad)
			ITreeView(gad).OnCollapse evt
		End If
	Case EVENT_GADGETSELECT
		If ITreeView(gad)
			ITreeView(gad).OnSelect evt
		End If
	Case EVENT_GADGETMENU
		Local txt:ITextBox = ITextBox(gad)
		
		Local tv:ITreeView = ITreeView(gad)
		
		If txt
			txt.OnMenu evt
		Else If tv
			tv.OnMenu evt
		End If
	Case EVENT_GADGETDONE
		If IHTMLView(gad)
			IHTMLView(gad).OnLoaded evt
		End If
	Case EVENT_GADGETACTION
		gad.OnAction evt
	Case EVENT_GADGETPAINT
		gad.OnPaint evt
	End Select
	Return obj
End Function
