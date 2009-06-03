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

'read the Debug flag state from settings.xml
Global G_debug:Int = XMLGetSingleValue(c_SettingsFile,"settings/debug").ToInt()

' create the screen and initialize the graphics mode
' Make it global so that viewport:TViewport is accessible everywhere
Global G_viewport:TViewport = TViewport.Create()

' The upper left debug info display
Global G_debugWindow:TDebugWindow

' global player instance
Global G_player:TPlayer

' universe is 'global'... huh? ;)
Global G_Universe:TUni

' Global delta timer instance
Global G_delta:TDelta = TDelta.Create(XMLGetSingleValue(c_SettingsFile,  ..
	"settings/graphics/framerate").ToInt(),  ..
	XMLGetSingleValue(c_settingsFile, "settings/graphics/limitframerate").ToInt(),  ..
	XMLGetSingleValue(c_settingsFile, "settings/graphics/maxdelta").ToInt()) 
G_delta.SetTimeCompression(1)

' fixed rate globals
Local frequency:Int = 60 ' times per second
Global G_timestep:Double = 1000 / frequency ' millisecs
Global G_t:Double , G_dt:Double, G_execution_time:Double = 0
Global G_tween:Double
Global G_newTime:Double
