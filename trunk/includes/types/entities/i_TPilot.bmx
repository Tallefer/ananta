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

' -----------------------------------------------------------------
' TPilot is a generic intelligent entity, human or AI
' -----------------------------------------------------------------
Type TPilot Abstract
	Field _name:String									' The name of the pilot
	Field _controlledShip:TShip					' The ship the pilot is controlling
	Field _health:Int												
	Field _money:Long
	
	Method Kill() Abstract
	
	Method SetControlledShip(sh:TShip)
		_controlledShip = sh
	End Method
	
	Method GetControlledShip:TShip() 
		Return _controlledShip
	End Method
	
EndType

' ------------------------------------
' TPlayer represents a human pilot
' ------------------------------------
Type TPlayer Extends TPilot

	Method Kill() 
		SetControlledShip(Null) 
		'game over?
	End Method

	' GetInput handles the keyboard and joystick input for the ship
	' (redo this using event handler)
	Method GetInput()
		If _controlledShip Then
		' ship controls
		
			If KeyDown(KEY_UP) _controlledShip.SetThrottle(1) 
			If KeyDown(KEY_DOWN) _controlledShip.SetThrottle(- 1) 
			If KeyDown(KEY_RIGHT) _controlledShip.SetController(1) 
			If KeyDown(KEY_LEFT) _controlledShip.SetController(- 1) 	
			If KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL) Then _controlledShip._TriggerDown = True
			If Not KeyDown(KEY_LCONTROL) And Not KeyDown(KEY_RCONTROL) Then _controlledShip._TriggerDown = False
			' relase controls if keyboard keys are released
			If Not KeyDown(KEY_UP) And Not KeyDown(KEY_DOWN) 		_controlledShip.SetThrottle(0)
			If Not KeyDown(KEY_RIGHT) And Not KeyDown(KEY_LEFT) _controlledShip.SetController(0) 

			If KeyHit(KEY_J) Then
				ToggleBoolean(_controlledShip._isJumpDriveOn) 
			End If
		EndIf
		
		' misc controls
		If KeyDown(KEY_F1) Then
			viewport.ShowInstructions()
		End If
		
		If KeyHit(KEY_G) Then viewport.GetStarMap().ToggleVisibility()
		
		If Not KeyDown(KEY_LSHIFT) And ..
			Not KeyDown(KEY_RSHIFT) And ..
			Not KeyDown(KEY_RALT) And ..
			Not KeyDown(KEY_LALT) Then
				If KeyDown(KEY_Z) Then viewport.ZoomIn() 
				If KeyDown(KEY_X) Then viewport.ZoomOut() 
		EndIf
		
		If KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT) Then
			If KeyDown(KEY_Z) Then viewport.GetSystemMap().ZoomIn() 
			If KeyDown(KEY_X) Then viewport.GetSystemMap().ZoomOut() 
			
		EndIf
		
		' starmap scrolling
		If viewport.GetStarMap().isVisible Then
			Local multiplier:Int = 1
			If KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT) Then 
				multiplier = 10		' with shift multiply the scroll speed by 10
			EndIf
			If KeyDown(KEY_A) Then viewport.GetStarMap().scrollX(- 1 * multiplier)  	' scroll left
			If KeyDown(KEY_D) Then viewport.GetStarMap().scrollX(1 * multiplier)  		' scroll right
			If KeyDown(KEY_S) Then viewport.GetStarMap().scrollY(1 * multiplier) 		' scroll down
			If KeyDown(KEY_W) Then viewport.GetStarMap().scrollY(- 1 * multiplier) 		' scroll up
			If KeyDown(KEY_C) Then viewport.GetStarMap()._isPersistent = False; viewport.GetStarMap().ZoomIn() 	' zoom in starmap
			If KeyDown(KEY_V) Then viewport.GetStarMap()._isPersistent = False; viewport.GetStarMap().ZoomOut() 	' zoom out starmap
		End If
		
		' alt modifiers
		If KeyDown(KEY_LALT) Or KeyDown(KEY_RALT) Then
			If KeyDown(KEY_ENTER) Then TViewport.ToggleFullScreen() 
			If KeyDown(KEY_Z) Then viewport.ResetZoomFactor() 
			If KeyDown(KEY_X) Then viewport.GetSystemMap().ResetZoomFactor() 
			If KeyDown(KEY_C) Then viewport.GetStarMap().Center() 	' center the starmap with shift-c
		End If
		
		If Not KeyDown(KEY_Z) And Not KeyDown(KEY_X) Then
			viewport.StopZoom() 
			viewport.GetSystemMap().StopZoom() 
		EndIf
		
		If Not viewport.GetStarMap()._isPersistent AND Not KeyDown(KEY_C) And Not KeyDown(KEY_V) Then
			viewport.GetStarMap()._isPersistent = TRUE
			viewport.GetStarMap().StopZoom() 
			viewport.GetStarMap().Update()
		EndIf
	EndMethod
	
	Function Create:TPlayer(name:String)
		Local pl:TPlayer = New TPlayer
		pl._name = name
		Return pl
	EndFunction			
EndType

' ------------------------------------
' TAIPlayer represents an AI pilot
' ------------------------------------
Type TAIPlayer Extends TPilot
	Global g_L_AIPilots:TList				' a list holding all AI pilots

	Field _flyingSkill:Float					' 0 to 1		 	1 = perfect
	Field _aggressiveness:Float				' 0 to 1			1 = most aggressive
	Field _wimpyness:Float					' 0 to 1			1 = always fleeing, 0 = never fleeing
	Field _accuracy:Float					' 0 to 1			1 = perfect
	Field _destinationObject:TSpaceObject	' The destination for AI. Sector, planet, space station etc
	Field _desiredRotation:Float				' planned rotation
	Field _targetObject:TSpaceObject			' target object (for shooting, pursuing etc)
	

	Method Kill() 
		SetControlledShip(Null) 
		g_L_AIPilots.Remove(Self) 
	End Method

	' "Think" is the main AI routine to be called
	Method Think() 
		If Not _controlledShip Return
		_desiredRotation = DirectionTo(_controlledShip.GetX(), _controlledShip.GetY(), _targetObject.GetX(), _targetObject.GetY()) 
		'_controlledShip.AutoPilotRotation(_desiredRotation) 	' use the ship's autopilot function to rotate the ship as desired
		
		Local tDist:Double = Distance(_controlledShip.GetX(), _controlledShip.GetY(), _targetObject.GetX(), _targetObject.GetY()) 
		Local rotDiff:Float = Abs(_controlledShip.GetRot() - _desiredRotation) 
		If tDist > 1000 Or rotDiff > 15 Then
			RotateTo(_desiredRotation)     	' use the AI logic to manually turn to the desired rotation
			_controlledShip._triggerDown = False
		Else
			RotateTo(_desiredRotation, True)      	' use the AI logic to manually turn to the desired rotation
			_controlledShip._triggerDown = True
		EndIf
	EndMethod

	Method SetTarget(obj:TSpaceObject)
		_targetObject = obj
	End Method
	
	Method RotateTo(heading:Float, aggressiveMode:Int = False) 
		Local diff:Float = GetAngleDiff(_controlledShip.GetRot(),heading)  ' returns degrees between current and desired rotation
		' if we're "close enough" to the desired rotation (take the rot thrust performance into account)...
		If Not aggressiveMode And Abs(diff) < 1 + _controlledShip.GetRotAccel() * G_delta.GetDelta() * 2 Then
			_controlledShip.SetController(0)  	 					'... center the joystick...
			Return  												' ... and return with no further action
		EndIf
		' if diff < 0, the desired rotation is faster to reach by rotating to the right, diff > 0 vice versa
		If diff > 0 Then _controlledShip.SetController(1)  		' rotation thrusters full right
		If diff < 0 Then _controlledShip.SetController(-1) 		' rotation thrusters full left
		If Not aggressiveMode Then	' in "aggressive mode" the AI does not slow down rotation speed before the desired heading has been reached
			' *********** calculates when to stop rotation ******************
			' Calculate the number of degrees it takes for the ship to stop rotating
			' The absolute value of rotational speed (degrees per second):
			Local rotSpd:Float = Abs(_controlledShip.GetRotSpd()) 
			' The number of seconds it takes for the rotation to stop: (time)
			Local SecondsToStop:Float = Abs(rotSpd) / (_controlledShip.GetRotAccel()) 
			' CalcAccelerationDistance:Float(speed:Float,time:Float,acceleration:Float)
			' s = vt + at^2
			Local degreesToStop:Float = CalcAccelerationDistance(rotSpd, secondsToStop, - _controlledShip.GetRotAccel()) 
			' stop rotating if it takes more degrees to stop than the angle difference is
			If degreesToStop >= Abs(diff) Then
				If diff > 0 And _controlledShip.GetRotSpd() > 0 Then _controlledShip.SetController(-1) 		' fire the opposing (left)  rotation thrusters
				If diff < 0 And _controlledShip.GetRotSpd() < 0 Then _controlledShip.SetController(1)  		' fire the opposing (right) rotation thrusters
			EndIf
			' ***************************************************************
		EndIf
		
	EndMethod
	
	Function UpdateAllAI()
		If NOT g_L_AIPilots Return
		For Local ai:TAIPlayer = EachIn g_L_AIPilots
			ai.Think()  ' the main AI routine
		Next
	End Function

	Function Create:TAIPlayer(name:String)
		Local pl:TAIPlayer = New TAIPlayer
		pl._name = name

		If Not g_L_AIPilots Then g_L_AIPilots = CreateList()
		g_L_AIPilots.AddLast pl

		Return pl
	EndFunction
EndType