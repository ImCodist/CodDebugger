/*

---------- SETTINGS (CREATE) ----------

Edit the variables below to customize the debugger.

*/

spacing = 15; // how far apart each line is
fontMain = "MS Sans Serif"; // the font used for most of the text

// edit the colors used by the debugger
enum debugColors {
	window = c_dkgray,
	windowTop = c_blue,
	contextMenu = c_dkgray,
	contextMenuSelect = c_blue
}

// VARIABLE BOX POSITIONS
// edit the position and size of several boxes

// the "Game Vars" box (fps, real_fps)
enum winGameVar {
	x = 40,
	y = 40,
	width = 240,
	height = -1
}
// the "Global Vars" box (all global variables are shown here)
enum winGlobalVar {
	x = 40,
	y = 110,
	width = 220,
	height = -1
}
// the "Variables" box (all instance variables are shown here)
enum winVar {
	x = 1000,
	y = 40,
	width = 240,
	height = -1
}
// the "Pinned Vars" box (all pinned variables are shown here)
enum pinnedVar {
	x = 780,
	x2 = 1040,
	y = 40,
	width = 200,
	height = -1
}

// The text that is displayed when the context menu is opened
contextMenuOptions = ["Edit", "Delete"] // default
contextMenuOptionsOther = ["Edit Globals"] // not clicking on a object

/*

Everything after this point is just necessary create event variables.
You may not want to change anything below.
Some of this stuff will not be commented, or not commented very well.

*/

version = "v1.0.0"; // the debuggers version number (dont change this lmao)

// both width and height variables
gameWidth = window_get_width();
gameHeight = window_get_height();

// how much to scroll on the x and y when using the mouse wheel
scrollX = 0;
scrollY = 0;

// arrays for each of the boxes
winGameVars[0][1] = 0; // game variable array (var, string)

winGlobalVars[0][1] = 0; // global variable array (var, string)

winVars[0][1] = 0; // instance variable array (var, string)
winVarsB[0][1] = 0; // instance built in variable array (var, string)

pinnedVars[0][2] = 0; // pinned variables array (var, string, id)

// context menu variables
contextMenuOpen = false;
// scale, and position
contextMenuScale = 0;
contextMenuPos[0] = 0; // x
contextMenuPos[1] = 0; // y

// id's for each of the states a instance can be in
selected = undefined;
mouseOver = undefined;
dragging = undefined;

// edit mode variables
// global mode is for when editing global variables
editMode = false;
globalMode = false;

// input ui variables
input = 0;
inputUIScale = 0;
openedInput = 0;

// if the font is a string, use the web font stuff
// * i just put this here for people who wanna use the gms font resource
// * use the font resource, its better
if (is_string(fontMain))
	fontMain = font_add(fontMain, 12, false, false, 32, 128);

// FUNCTIONS

// update each array to reflect on the current instance
function updateVars() {
	// game vars
	winGameVars[0][0] = fps; winGameVars[0][1] = "FPS";
	winGameVars[1][0] = fps_real; winGameVars[1][1] = "REAL FPS";
	
	// global vars
	var vars = variable_instance_get_names(global);
	var varLeng = array_length(vars);

	for (var i = 0; i < varLeng; ++i) {
		winGlobalVars[i][0] = variable_global_get(vars[i]);
		winGlobalVars[i][1] = vars[i];
	}
	
	// pinned vars
	if (array_length(pinnedVars) != 0) {
		for (var i = 0; i < array_length(pinnedVars); ++i) {
			var val = "undefined";
			if (pinnedVars[i][2] = "g") val = variable_global_get(pinnedVars[i][1]);
			else val = variable_instance_get(pinnedVars[i][2], pinnedVars[i][1]);
			
			pinnedVars[i][0] = val;
		}
	}
}
// call the function at the beginning of the game just to be safe
updateVars();

// draws an outline around the selected object
function drawOutline(_id, _color) {
	with (_id) {
		draw_set_color(other._color);
		
		var _xNew = x - sprite_xoffset;
		var _yNew = y - sprite_yoffset;
		draw_rectangle(_xNew, _yNew, _xNew + sprite_width, _yNew + sprite_height, true);
		
		draw_set_color(c_white);
	}
}

// allow the use of decimals and negative numbers in the input system
// * string_digits just... doesnt do this
// * its annoying i hate it i hate it i hate it
function string_digits_decimal(_str) {
	var finalStr = string_digits(_str);
	var pos = string_pos(".", _str);
	var posNeg = string_pos("-", _str);
	
	if (pos != 0) finalStr = string_insert(".", finalStr, pos);
	if (posNeg != 0) finalStr = string_insert("-", finalStr, posNeg);
	
	return finalStr;
}