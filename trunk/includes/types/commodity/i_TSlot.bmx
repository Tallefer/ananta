' TSlot is a special "container" in a ship hull that holds other ship parts. 
' Slots are created when a new ship (hull) is created.
' See i_TCommodity_TShippart.bmx
Type TSlot Final
	Field _id:String
	Field _slottype:String		' type of the slot (rotthruster, thruster, engine, equipment)
	Field _volume:Float			' volume of the slot in m^3
	Field _L_components:TList			' list to hold all ship components in this slot
	Field _location:String		' the location of the slot (internal, external). Internal takes less damage.
	Field _exposedDir:String		' NULL if the slot is not exposed to space, otherwise dir = left, right, nose or tail)
								' Thrusters and engines need to have exposure! Also, weapons in the future need exposure.
								' Exposed slots take even more damage than external!
	
	Method isEngine:Int() 
		If _slottype = "engine" Then Return True
		Return False
	End Method
	Method isThruster:Int() 
		If _slottype = "thruster" Then Return True
		Return False
	End Method
	Method isRotThruster:Int() 
		If _slottype = "rotthruster" Then Return True
		Return False
	End Method
	Method isEquipment:Int() 
		If _slottype = "equipment" Then Return True
		Return False
	End Method
																
	Method GetComponentList:TList() 
		Return _L_components
	End Method
	
	Method GetID:String()
		Return _id
	End Method
	
	Method getSlotType:String() 
		Return _slottype
	End Method
	
	Method GetVolume:Float()
		Return _volume
	End Method

	Method GetLocation:String()
		Return _location
	End Method

	Method GetExposedDir:String()
		Return _exposedDir
	End Method

	Method SetVolume(fl:float)
		_volume = fl
	End Method

	Method SetLocation(fl:String)
		_location = fl
	End Method

	Method SetExposedDir(fl:String)
		_exposedDir = fl
	End Method
	
	Method SetSlotType(st:String) 
		_SlotType = st
	End Method
	
	Method RemoveComponent:Int(comp:TComponent) 
		' return if the component is not loaded in this slot	
		If Not _L_components.Contains(comp) Then
			If G_debug Then Print "TSlot.RemoveComponent failed: The component is not loaded in this slot!"
			Return Null
		EndIf
		
		_L_components.remove(comp) 
		comp.AssignSlot(Null)  	' tell the component it's no longer installed
		Return True ' success
	End Method
	
	Method AddComponent:Int(comp:TComponent) 
		If not _slotType Then
			' return if the type for this slot has not been defined
			Print "TSlot.AddComponent ERROR: No slot type defined!"
			Return Null
		EndIf
		
		' Check if the component is already installed in some slot...
		If Not comp.GetSlot() = Null Then
			If G_debug Then Print "TSlot.AddComponent failed: The component is already installed in a slot!"
			Return Null
		EndIf
		
		' Check if this slot is of correct type...
		Local compType:String = comp.getType() 
		If compType = "engine" and ..
			(_slotType = "engine" or _slotType = "rotthruster" or _slotType = "thruster") Then
			_L_components.AddLast(comp)  ' add the component to the slot
			comp.assignSlot(Self)  		 ' tell the component that it's installed in this slot
			Return True
		EndIf
		
		' trying to install something that doesn't fit in this slot
		If G_debug Then Print "Component " + compType + " does not fit in slot " + _slotType
		Return Null
	End Method
	
	Function Create:TSlot(idString:String)
		Local s:TSlot = New TSlot						' create an instance
		s._id = idString									' give an ID
		s._L_components = New TList
		Return s										' return the pointer to this specific object instance
	EndFunction									
EndType