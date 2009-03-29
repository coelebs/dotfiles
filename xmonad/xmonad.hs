import XMonad
import System.Exit
import XMonad.Hooks.SetWMName

--dzen nessesesity's
import IO
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run
import XMonad.Util.Dzen
import XMonad.Hooks.ManageDocks

--For the Keybindings
import XMonad.Actions.CycleWS
import XMonad.Util.EZConfig
import XMonad.Actions.SinkAll

--Layouts
import XMonad.Layout.HintedGrid
import XMonad.Layout.NoBorders
import XMonad.Layout.HintedTile

--Java issues
import XMonad.Hooks.SetWMName

--For a kind-of dmenu
import XMonad.Prompt
import XMonad.Prompt.Shell

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
        ,workspaces         = ["www","base","code","school","misc"]        
				,normalBorderColor  = "#555b2f"
        ,focusedBorderColor = "#b22222"
      
		-- hooks, layouts
        ,layoutHook         = avoidStruts $ tiled ||| hintedTile XMonad.Layout.HintedTile.Tall ||| Grid False ||| noBorders Full
				,manageHook					= composeAll 		[ className =? "Opera" --> doF(W.shift "opera") ]
				<+> manageDocks
        ,logHook 						= dynamicLogWithPP defaultPP
																{ ppCurrent  				= dzenColor "red" "" . wrap "[" "]" 
																, ppVisible   			= wrap "[" "]^ca()"
																, ppHidden	  			= dzenColor "grey" "" 
																, ppHiddenNoWindows	= dzenColor "grey"  ""
																, ppUrgent    			= dzenColor "red" "" . wrap "^" ""
																, ppLayout    			= dzenColor "grey" "" 
																, ppTitle						= const ""	 
																, ppOutput   				= hPutStrLn h }
					,startupHook			= setWMName "LG3D"
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
		,((mod4Mask,						 xK_space),	shellPrompt defaultXPConfig)
		--Hide dzen
		,((modm, 								 xK_b), 		sendMessage ToggleStruts)
		--Commands
		,((modm,  							 xK_a),			spawn "urxvtc")
		--Toggle mpd
		,((modm,								 xK_p),			spawn "mpc toggle")
		]

		where
			tiled = XMonad.Tall 1 (3/100) (1/2)
			hintedTile = HintedTile 1 (3/100) (1/2) TopLeft
