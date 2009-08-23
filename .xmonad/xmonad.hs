import XMonad
import System.Exit
import XMonad.Hooks.SetWMName

--dzen nessesesity's
import IO
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run
import XMonad.Hooks.ManageDocks

--For the Keybindings
import XMonad.Actions.CycleWS
import XMonad.Util.EZConfig
import XMonad.Actions.SinkAll

import XMonad.Actions.UpdatePointer

--Layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.HintedTile
import XMonad.Layout.Tabbed
import XMonad.Layout.Combo
import XMonad.Layout.TwoPane
import XMonad.Layout.Named

--Java issues
import XMonad.Hooks.SetWMName

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

modm = mod1Mask
	
main :: IO ()
main = do 
	h <- spawnPipe "dzen2 -fn '-*-terminus-*-*-*-*-12-*-*-*-*-*-*-*' -bg black -fg grey -h 14 -w 350 -ta l "
	xmonad $ defaultConfig
	 {
		 -- simple stuff
        terminal           	= "urxvtc"
        ,focusFollowsMouse  = True
        ,borderWidth        = 1
        ,modMask            = mod1Mask
        ,workspaces         = ["www","base","code","school","torrents","misc"]        
				,normalBorderColor  = "#555b2f"
        ,focusedBorderColor = "#b22222"
      
		-- hooks, layouts
        ,layoutHook         = avoidStruts $ tiled ||| named "HintedTall" (hintedTile XMonad.Layout.HintedTile.Tall) ||| noBorders Full ||| named "Tabbed" (combineTwo (TwoPane 0.03 0.5) (tabbed shrinkText tabConfig) (simpleTabbed))
				,manageHook					= composeAll 		[]	<+> manageDocks
        ,logHook 						= dynamicLogWithPP defaultPP
																{ ppCurrent  				= dzenColor "red" "" . wrap "[" "]" 
																, ppVisible   			= wrap "[" "]^ca()"
																, ppHidden	  			= dzenColor "grey" "" 
																, ppHiddenNoWindows	= dzenColor "grey"  ""
																, ppUrgent    			= dzenColor "red" "" . wrap "^" ""
																, ppLayout    			= dzenColor "grey" "" 
																, ppTitle						= const ""	 
																, ppOutput   				= hPutStrLn h } 
																>> updatePointer Nearest
				,startupHook				= setWMName "LG3D"
		}
		
		`additionalKeys`
		[
		-- Move focus in workspace
 		 ((modm,								xK_Right ), windows W.focusDown)				 
 		,((modm,								xK_Left ), 	windows W.focusUp  )
        -- Moce windows in workspace
		,((modm .|. shiftMask,	xK_Right ), windows W.swapDown  )
		,((modm .|. shiftMask, 	xK_Left ), 	windows W.swapUp    )
		-- Move screenfocus	
	  ,((controlMask,					xK_Right), 	nextScreen)	
		,((controlMask,					xK_Left ), 	prevScreen)
	  -- Move Screenfocus
		,((modm,								xK_u), 			nextScreen)	
		,((modm,           			xK_i), 			prevScreen)
   	-- Move windows across screens	
		,((controlMask .|. shiftMask,		xK_Right), 		shiftNextScreen)
		,((controlMask .|. shiftMask,		xK_Left),  		shiftPrevScreen)
		-- Sink all windows into tiling
		,((modm,								 xK_t), 		sinkAll)
		-- Prompt 
		,((mod4Mask,						 xK_space),	spawn "dmenu_run -b -fn terminus -nb '#252525' -nf '#81902D' -sb '#AE4747'")
		--Hide dzen
		,((modm, 								 xK_b), 		sendMessage ToggleStruts)
		--Commands
		,((modm,  							 xK_a),			spawn "urxvtc -e screen -xRR")
		--Toggle mpd
		,((modm,								 xK_p),			spawn "ncmpcpp toggle")
		]

		where
			tiled = XMonad.Tall 1 (3/100) (1/2)
			hintedTile = HintedTile 1 (3/100) (1/2) TopLeft
			tabConfig = defaultTheme 	{ inactiveBorderColor	= "#555b2f"
																,inactiveColor 				= "#282828"
																,inactiveTextColor 		= "#A4A333"
																,activeBorderColor  	= "#b22222"
																,activeColor 					= "#282828"
																,activeTextColor 			= "#A4A333" }
