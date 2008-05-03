rem
This file is part of Ananta.

    Ananta is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Ananta is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Ananta.  If not, see <http://www.gnu.org/licenses/>.


Copyright 2007, 2008 Jussi Pakkanen
endrem

' TSystem represents a star system
Type TSystem Final
	Global g_L_Systems:TList					' a list to hold all Systems
	Global _g_ActiveSystem:TSystem				' the System the player is in
	Field _name:String							' Name of the System
	Field _sectorX:Int, _sectorY:Int			' coordinates of the sector this system is in (0 - 7192)
	Field _x:Int,_y:Int							' System's x-y-coordinates in the sector map (0 - 256)
	Field _size:Float = 5						' size of the central star (for starmap blip size)
	Field _type:Int								' type of the central star
	Field _multiple:Int							' multiple star status for the system
	Field _mainStar:TStar
	
	Field _L_SpaceObjects:TList					' a list to hold all TSpaceObjects in this System

	Method DrawAllInSystem(vp:TViewport)
		If Not _L_SpaceObjects Return							' Exit if a body list doesn't exist
		For Local obj:TSpaceObject = EachIn _L_SpaceObjects	' Iterate through each drawable object in the System
			obj.DrawBody(vp)     							' Calls the DrawBody method of each drawable object in the System
			If vp.GetSystemMap() And obj.showsOnMap() Then	' draw a minimap blip if minimap is defined for the viewport
				vp.GetSystemMap().AddSystemMapBlip(obj)
			End If
			obj._updated = False	' optimization to clear updated status during the drawing cycle
		Next
	EndMethod

	Method AddSpaceObject(obj:TSpaceObject)
		If Not _L_SpaceObjects Then _L_SpaceObjects = CreateList()	' create a list if necessary
		'obj.SetSystem(self)  ' crash with abstract objects!
		obj._system = self
		_L_SpaceObjects.AddLast obj
	EndMethod

	Method RemoveSpaceObject(obj:TSpaceObject) 
		If Not _L_SpaceObjects Then Return
		obj._system = null
		_L_SpaceObjects.Remove(obj) 
	EndMethod

	' placeholder method for procedural planet generation
	Method Populate()
		
	End Method
	
	Method SetAsActive()
		_g_ActiveSystem = self
	End Method
	
	Method GetX:Int()
		Return _x
	End Method
	
	Method GetY:Int()
		Return _y
	End Method
	
	Method GetSize:Int()
		Return _size
	End Method
	
	' returns the main star of the system
	Method GetMainStar:TStar()
		Return self._mainStar
	End Method

	' returns the system that is currently "active"
	Function GetActiveSystem:TSystem()
		Return _g_ActiveSystem
	End Function
	
	Function Create:TSystem(sectX:Int, sectY:Int,x:Int,y:Int,name:String,typ:Int,mult:Int)
		Local se:TSystem = New TSystem								' create an instance of the System
		se._name = name	
		se._sectorX = sectX
		se._sectorY = sectY
		se._x = x	; se._y = y	
		se._type = typ
		se._multiple = mult
		If Not g_L_Systems Then g_L_Systems = CreateList()	' create a list to hold the Systems (if not already created)
		g_L_Systems.AddLast se							' add the newly created System to the end of the list
		Return se										' return the pointer to this specific object instance
	EndFunction
EndType
