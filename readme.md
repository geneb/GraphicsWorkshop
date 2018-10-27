On October 26th, 2018 I purchased the software assets of Full Moon Software.
Full Moon Software used to be known as Crescent Software.  They produced a line
of excellent development libraries for MS-DOS.  The supported environments were
QuickBASIC 4.x, Microsoft Professional Development System v7.x, and Visual 
Basic for DOS.

The idea behind obtaining these products was to release them to the public
domain to ensure that people could still access these things in the future.
While most developers will have no use for these products in a modern 
develoment environment, they still have value as an example of "how it was 
done" back in the heyday of x86 DOS development. 

The software in this repository hasn't been modified from how I received it 
from Ethan Winer, the original author.  While all the source files carry some 
kind of Copyright notice, the software is now in the public domain.

The contents of the installation floppies will be uploaded to the Internet
Archive soon and when the manuals are scanned, they'll be uploaded there
as well.  I'll update this readme file with a link to the manual scan when
it's available.

The original distribution disk files are available here:

http://annex.retroarchive.org/crescent/Gwshop.zip


Gene Buckle, October 27th, 2018

I've attached the text from Full Moon Software's catalog description of 
The Graphics Workshop below.

-------------------------------------------------------------------------------
=============================================================================

THE GRAPHICS WORKSHOP(tm)
=========================

Create Blazing Graphics--With Half the Code
-------------------------------------------

The Graphics Workshop is a comprehensive collection of graphic subroutines for 
use with EGA and VGA displays. Five major components add capabilities not 
present in regular BASIC and also reduce the size of your programs:

     * Low-level graphics primitives that are faster and smaller than their
       BASIC equivalents and include options not available in BASIC alone.

     * Routines for saving and loading full-screen images in .PCX files.

     * Text display routines that accept both foreground and background colors
       and can scale to nearly any size.

     * High-level menu and input routines.

     * Special video effects, including wipes, fades, and exploding images.

A NEW WAY TO HANDLE GRAPHICS

The Graphics Workshop is mainly intended for use with the EGA and VGA screen 
modes; however, some routines are also provided for use with CGA and Hercules 
displays, as noted. One of the reasons the Graphics Workshop routines are so 
much smaller and faster than BASIC's is because they don't have to accommodate 
so many different display memory methods. Also, BASIC requires floating point 
math calculations as part of its handling of VIEW and WINDOW, even when 
plotting a single pixel. In contrast, the Graphics Workshop routines use 
integer arguments exclusively and can reduce the size of your programs by as 
much as 25K. The Graphics Workshop is also ideal for use with our P.D.Q. 
library to add advanced graphics capabilities to programs that need to be as 
small as possible. In all, the Graphics Workshop includes more than 140 
routines, 35 BASIC demonstration programs, two font design systems, a .PCX 
file capture utility, and extensive documentation.

LOW-LEVEL ROUTINES

The Graphics Workshop provides small-code replacements for many of BASIC's 
graphics primitives including CIRCLE, POINT, and LINE (including with box 
fill). SCREEN replacements are also included to avoid the usual overhead 
associated with that command. Unlike regular BASIC, all of the low-level 
routines accept the AND, OR, and XOR style options. This lets you easily add 
rubber-banding and other special effects to your programs.
     Other low-level routines include saving and restoring areas of the 
screen, plotting and reading individual points, coloring selected portions of 
the screen, and scrolling regions up, down, left, or right. The Graphics 
Workshop  low-level routines are designed to operate in all the EGA and VGA 
Screen modes including 256 colors.

HIGH-LEVEL ROUTINES

Many high-level routines are provided for creating pull-down and vertical 
"light bar" menus, as well as horizontal Lotus-style menus. The pull-down and 
vertical menu routines include integrated mouse handling and feature a unique 
polled mode that lets your program continue while waiting for user input.
     Two pull-down menu programs are included, to look and operate just like 
the menus in the BASIC editor and Windows, respectively. The vertical menu 
accommodates nearly any number of choices, and you can control its size and 
placement on the screen. If more items are present than can be displayed, the 
menu scrolls automatically. All of the Graphics Workshop menus are very easy 
to set up and call, using a single string array to define the menu choices. 
All of the menus also save and restore the underlying screen automatically. 
Existing video memory can be optionally used for storing the screen portions. 
This avoids having to create separate arrays for storage, leaving that much 
more memory for your programs.
     The Graphics Workshop also includes a text input routine complete with a 
simulated cursor allowing new text to be added or existing text edited. Both 
insert and overstrike modes are allowed, and the color and length of the input 
field can be controlled. A pop-up "message box" subroutine lets you easily 
place text within any window.

LOADING AND SAVING .PCX FILES

Routines are provided for loading and saving full-screen graphics images using 
the popular .PCX file format. All of the BASIC-supported video modes are 
accommodated including VGA, VGA 256-color, EGA, CGA, and even Hercules 
monochrome. This lets you import high-quality images from all of the popular 
PC paint programs. Because .PCX screens are compressed, you may store images 
using as little memory and disk space as possible.

DISPLAYING TEXT

The Graphics Workshop PRINT replacement is up to ten times faster than 
BASIC's, and it lets you specify both the foreground and background colors. 
Text may be placed vertically at any arbitrary pixel position, which greatly 
simplifies adding legends and titles to your graphics screens. Two complete 
font definition systems are included for designing your own proportional 
character sets and controlling fully their size, placement, and even angle.

SPECIAL EFFECTS

A variety of clever special effects are provided, which you incorporate into 
your own programs. Effects include wipes, fades, slides, and imploding and 
exploding screens. All of the tools you need to design your own effects are 
also included. A complete script-driven slide show program lets you create 
self-running displays using any of the Graphics Workshop special effects.
     A full complement of mouse routines is available to read and set the 
mouse cursor position and define new cursor shapes. Additional routines report 
which buttons are pressed, turn the mouse cursor on and off, and control the 
mouse motion sensitivity.
     Finally, the Graphics Workshop furnishes a sophisticated routine for 
printing the display contents to either an Epson/IBM or compatible dot-matrix 
printer, or an HP LaserJet. Images may be printed from any of the BASIC-
supported video modes, either right side up or sideways. When using a Laser 
printer the image can also be placed anywhere on the page. Colors may be 
optionally translated to hatching patterns automatically. This feature is 
important for distinguishing different portions of a complex graphics screen 
when printed in black and white.

THE FULL MOON PHILOSOPHY

As with all our products, full source code is provided at no additional cost, 
so you can see how the routines were designed and even modify them if you 
want. We genuinely want you to understand how our libraries work and be able 
to learn from them. All of our products are reasonably priced and include free 
technical assistance, but they are licensed for use by only one person using 
one computer at a time. Royalty payments are not required when our routines 
are incorporated into your compiled applications. However, you may not 
distribute our source, object, or library files. If your customers need to 
rebuild your program, they will need their own copy of our product(s).

THE BOTTOM LINE

The Graphics Workshop costs $149 and works with QuickBASIC 4.x, PDS 7.x, and 
VB/DOS. Add $8 for UPS ground shipping to US addresses only (no P.O. boxes); 
Connecticut residents must add 6.0% sales tax or show proof of tax-exempt 
status when ordering. Please call for overnight and foreign shipping costs. We 
accept checks, MasterCard, and VISA. We do accept purchase orders, but they 
must be accompanied by full payment.

Graphics Workshop(tm) is a trademark of Crescent Software, Inc.