SuperStrict

' Reconstruction of Type-GUI version 1

Interface IForm
End Interface

Type TForm

	Field parent:IForm
	Field title:String
	Field fields:TList = New TList()	' Widgets in the form
	
	Method New( form:IForm )
		parent = form
		
		' Add type as title (if provided)
		Local t:TTypeId = TTypeId.ForObject( form )
		Local title:String = t.metadata("title")
		If title
			Local label:TWidget = add( "title", New TLabel( title ) )
			label.setclass( "title" )
		End If

		' Add fields in type
		For Local fld:TField = EachIn t.EnumFields()
		
			'Only include fields with metadata
			If Not fld.metadata(); Continue
			
			'Local row:TFormField = New TFormField()
			
			' Create the label
			Local name:String = fld.name()
			Local caption:String = fld.metadata("label")
			If caption = ""; caption = name
			Local label:TWidget = New TLabel(caption+":")

			' Get the field type
			Local widget:TWidget 
			Local metaType:String = fld.metadata("type")
			Local fldtype:String = fld.typeid().name() 
			'DebugStop
			Select fldtype
			Case "Byte"
				widget = New TLabel( fld.getByte( form ) )
			Case "Short"
				widget = New TLabel( fld.getShort( form ) )
			Case "Double"
				widget = New TLabel( fld.getDouble( form ) )
			Case "Float"
				widget = New TLabel( fld.getFloat( form ) )
			Case "Int"
				'widget = New TLabel( fld.getInt( form ) )
				Select metatype
				Case "checkbox"
					Local value:Int = ( fld.getInt( form ) = True )	
					widget = New TCheckbox( name,value )
				Case "radio"
					'DebugStop
					Local opts:String = fld.metadata("options")
					Local options:String[] = opts.split(",")
					If options.length = 0
						Local value:Int = fld.getInt( form )
						widget = New TRadioButton( caption, value ) 
					Else
						' Add a group (panel) of radio buttons
						widget = New TGroup()
						For Local option:Int = 0 Until options.length
							TContainer(widget).add( New TRadioButton( options[option], option ) )
						Next
						Local value:Int = fld.getInt( form )
						widget.setvalue( value )
					End If
				Default
					Local value:Int = fld.getInt( form ) 
					widget = New TTextBox( value, "" )
				EndSelect
			Case "Long"
				widget = New TLabel( fld.getLong( form ) )
			Case "String"
				'DebugStop
				Local value:String = fld.getString( form )
				widget = New TTextBox( value, "" )
			Default
				'DebugStop
				If fld.typeid().extendsType( ArrayTypeId )
					widget = New TLabel( "(array)" )
				ElseIf fld.typeid().extendsType( ObjectTypeId )					
					widget = New TLabel( "(object)" )
				Else
					widget = New TLabel( "(NOT IMPLEMENTED)" )
					DebugLog( "TypeGUI: '" + fld.typeid().name() + "' is Not supported" )
				End If
			End Select

			' Add fields to form grid
			grid.add( "lbl"+name, label )
			grid.add( "fld"+name, widget )
					
			' Save original field object
			widget.fld = fld

			If fld.hasmetadata( "disabled" ); widget.setFlag( FLAG_DISABLED )

		Next
		
		' Add the form event handler
		setHandler( form )
				
	End Method

	Method show()
	End Method

	Method add:TWidget( caption:String, widget:TWidget )
	End Method

'	Method add( fieldtype:String, name:String )
'		fields.addlast( make( fieldtype, name ) )
'		' V0.6
'		If Not children; children = New TList()
'		children.addlast( fld )
'	End Method

End Type

Type TWidget
	Field caption:String
End Type

Type TLabel Extends TWidget
	
	Method New( caption:String )
		Self.caption = caption
	End Method
	
End Type
