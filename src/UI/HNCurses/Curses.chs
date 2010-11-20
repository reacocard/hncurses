{-# LANGUAGE ForeignFunctionInterface #-}

module UI.HNCurses.Curses (
    -- base
    initScr,
    endWin,
    stdScr,
    screenSize,
    raw,
    cbreak,
    echo,
    wTimeout,
    nl,
    keypad,
    getYX,
    getBegYX,
    getMaxYX,

    -- input
    wGetCh,
    wGetNStr,

    -- output
    beep,
    flash,
    wErase,
    wClear,
    wMove,
    wAddCh,
    wAddNStr,
    wRefresh,
    wNoOutRefresh,
    doUpdate,
    wVLine,
    wHLine,

    -- windows
    newWin,
    delWin,
    mvWin,
    box,
    wBorder,

    -- color
    hasColors,
    startColor,
    canChangeColor,
    colorPairs

    ) where


import Control.Exception
import Foreign.Marshal.Alloc( alloca )
import Foreign.Marshal.Utils( fromBool, toBool )
import Foreign.C.Types
import Foreign.C.String( peekCString, withCString )
import Foreign.Ptr( Ptr )
import System.IO.Unsafe( unsafePerformIO )

-- c2hs doesn't like stdbool, use ncurses' implementation instead
#define NCURSES_ENABLE_STDBOOL_H 0

#include "ncurses.h"
#include "cbits.h"


ckErr :: CInt -> IO ()
ckErr i = if i == -1 then throw (userError "Curses returned ERR") else return ()

-- data definitions

type ChType = {#type chtype#}

{#pointer *WINDOW as Window#}


-- BASE

{#fun initscr as initScr
    {} -> `Window' id#}

{#fun endwin as endWin
    {} -> `()' ckErr*-#}

{#fun get_stdscr as getStdScr
    {} -> `Window' id#}
stdScr :: Window
stdScr = unsafePerformIO getStdScr

{#fun get_cols as getCols
    {} -> `Int' fromIntegral#}
{#fun get_lines as getLines
    {} -> `Int' fromIntegral#}
screenSize :: IO (Int, Int)
screenSize = do
    cols <- getCols
    rows <- getLines
    return (rows, cols)

{#fun raw as enableRaw
    {} -> `()' ckErr*-#}
{#fun noraw as disableRaw
    {} -> `()' ckErr*-#}
raw :: Bool -> IO ()
raw enable = if enable then enableRaw else disableRaw

{#fun cbreak as enableCbreak
    {} -> `()' ckErr*-#}
{#fun nocbreak as disableCbreak
    {} -> `()' ckErr*-#}
cbreak :: Bool -> IO ()
cbreak enable = if enable then enableCbreak else disableCbreak

{#fun echo as enableEcho
    {} -> `()' ckErr*-#}
{#fun noecho as disableEcho
    {} -> `()' ckErr*-#}
echo :: Bool -> IO ()
echo enable = if enable then enableEcho else disableEcho

{#fun wtimeout as wTimeout
    {id `Window', fromIntegral `Int'} -> `()' id-#}

{#fun nl as enableNl
    {} -> `()' ckErr*-#}
{#fun nonl as disableNl
    {} -> `()' ckErr*-#}
nl :: Bool -> IO ()
nl enable = if enable then enableNl else disableNl

{#fun keypad as keypad
    {id `Window', fromBool `Bool'} -> `()' ckErr*-#}

{#fun getcury as getCurY
    {id `Window'} -> `Int' fromIntegral#}

{#fun getcurx as getCurX
    {id `Window'} -> `Int' fromIntegral#}

getYX :: Window -> IO (Int, Int)
getYX win = do
    y <- getCurY win
    x <- getCurX win
    return (y, x)

{#fun getbegy as getBegY
    {id `Window'} -> `Int' fromIntegral#}
{#fun getbegx as getBegX
    {id `Window'} -> `Int' fromIntegral#}
getBegYX :: Window -> IO (Int, Int)
getBegYX win = do
    y <- getBegY win
    x <- getBegX win
    return (y, x)

{#fun getmaxy as getMaxY
    {id `Window'} -> `Int' fromIntegral#}
{#fun getmaxx as getMaxX
    {id `Window'} -> `Int' fromIntegral#}
getMaxYX :: Window -> IO (Int, Int)
getMaxYX win = do
    y <- getMaxY win
    x <- getMaxX win
    return (y, x)

-- INPUT

{#fun wgetch as wGetCh
    {id `Window'} -> `CInt' id#}

{#fun wgetnstr as wGetNStr
    {id `Window', alloca- `String' peekCString*, fromIntegral `Int'} -> `()' ckErr*-#}

-- OUTPUT

{#fun beep as beep
    {} -> `()' ckErr*-#}

{#fun flash as flash
    {} -> `()' ckErr*-#}

{#fun werase as wErase
    {id `Window'} -> `()' ckErr*-#}

{#fun wclear as wClear
    {id `Window'} -> `()' ckErr*-#}

{#fun wmove as wMove
    {id `Window', fromIntegral `Int', fromIntegral `Int'} -> `()' ckErr*-#}

{#fun waddch as wAddCh
    {id `Window', id `ChType'} -> `()' ckErr*-#}

{#fun waddnstr as wAddNStr
    {id `Window', withCString* `String' , fromIntegral `Int'} -> `()' ckErr*-#}

{#fun wrefresh as wRefresh
    {id `Window'} -> `()' ckErr*-#}

{#fun wnoutrefresh as wNoOutRefresh
    {id `Window'} -> `()' ckErr*-#}

{#fun doupdate as doUpdate
    {} -> `()' ckErr*-#}

--  wAttrOn(win, attr)
--  wAttrOff(win, attr)
--  wAttrSet(win, attr)
--  wAttrGet(win, attr)
--  wColorSet(win, pair, opts)
--  wChGAt(win, count, attr, pair, opts)

--{#fun wchgat as wChGAt
--    {id `Window', fromIntegral `Int',   

{#fun wvline as wVLine
    {id `Window', id `ChType', fromIntegral `Int'} -> `()' ckErr*-#}

{#fun whline as wHLine
    {id `Window', id `ChType', fromIntegral `Int'} -> `()' ckErr*-#}

-- WINDOWS

{#fun newwin as newWin
    {fromIntegral `Int', fromIntegral `Int', fromIntegral `Int', fromIntegral `Int'} -> `Window' id#}

{#fun delwin as delWin
    {id `Window'} -> `()' ckErr*-#}

{#fun mvwin as mvWin
    {id `Window', fromIntegral `Int', fromIntegral `Int'} -> `()' ckErr*-#}

-- TODO: use Maybe to allow default chars
{#fun box as box
    {id `Window', id `ChType', id `ChType'} -> `()' ckErr*-#}

-- TODO: use Maybe to allow default chars
{#fun wborder as wBorder
    {id `Window', id `ChType', id `ChType', id `ChType', id `ChType', id `ChType', id `ChType', id `ChType', id `ChType'} -> `()' ckErr*-#}

-- COLOR

{#fun has_colors as hasColors
    {} -> `Bool' toBool#}

{#fun start_color as startColor
    {} -> `()' ckErr*-#}

--  initPair(num, fg, bg)

{#fun can_change_color as canChangeColor
    {} -> `Bool' toBool#}

--  initColor(color, r, g, b)
--  colorContent(color) -> (r, g, b)
--  pairContent(color) -> (fg, bg)

{#fun get_color_pairs as colorPairs
    {} -> `Int' fromIntegral#}

main = do
    initScr
    wGetCh stdScr
    endWin
