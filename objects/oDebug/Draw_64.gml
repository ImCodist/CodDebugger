/*

---------- DRAW GUI ----------

This code does most of the drawing for the instance.
It draws the variable boxes, edit mode UI, context menus, input UI, etc...

*/

// set the font to be the default one
draw_set_font(fontMain);

// draw the red bar at the top
draw_set_color(c_red);
draw_rectangle(0, 0, gameWidth, 10, false);
draw_set_color(c_white);

// BASIC BOX CODE

function varBox(_x, _y, _w, _h, title, varArray, type) {
	
	// choose where to start displaying at
	// used for mainly scrolling
	var startAt = clamp(scrollY, 0, array_length(varArray));
	if (type == "donthide") startAt = 0; // if the box should never hide when scrolling
	if (type == "pinned") startAt = 1; // offset the start by one (0 is a blank value)
	
	draw_set_alpha(0.5);
	draw_set_color(debugColors.windowTop);
	
	draw_rectangle(_x, _y, _x + _w, _y + 20, false); // draw the top of the box
	
	draw_set_color(debugColors.window);
	
	// draw the main box
	if (_h < 0) _h = (spacing*(array_length(varArray)-startAt));
	draw_rectangle(_x, _y, _x + _w, ((_y + 35) + _h), false);

	draw_set_color(c_white);
	draw_set_alpha(1);
	
	if (type == "object") title += " (" + object_get_name(selected.object_index) + ")"; // add the name of the object to the title if its the object window
	draw_text(_x, _y, title); // draw the title
	
	// * i need to make this based off the width for easier editing, i just havent felt like doing it tho
	var maxLength = 22; // choose how many characters can be displayed at once to the right
	if (type == "pinned") maxLength = 19; // lower this to 19 cuz the box is smaller
	
	// draw each variable
	// * should probably move some of this stuff out, its a lot of code for a loop
	for (var i = startAt; i < array_length(varArray); ++i) {
		var txt = varArray[i][1] + ": " + string(varArray[i][0]); // decide the text to display
		
		if (scrollX > string_length(txt)) continue; // if the x scroll makes a variable off screen, dont draw it (if this is removed it causes a really weird bug)
		txt = string_copy(txt, scrollX, maxLength); // only use the characters that should be visible
		
		// color the selected variable yellow and append "> " to it when in edit mode
		if (editMode) && (i = startAt) {
			if (type == "object") or ((type == "global") && globalMode) {
				draw_set_color(c_yellow);
				txt = "> " + txt;
			}
		}
		
		// choose the id of the object to use when drawing pinned variables
		var _id = "g";
		if !(globalMode) && (!is_undefined(selected)) _id = selected.id;
		
		// color the text when its pinned
		if (type == "pinned") {
			if !(is_undefined(selected)) && (varArray[i][2] == _id)
				draw_set_color(c_yellow); // yellow = current instance uses the variable
			else if (varArray[i][2] == "g")
				draw_set_color(c_ltgray); // gray = global variable
		}
		
		// draw the variable
		draw_text(_x + 10, _y + (spacing * (i-startAt)) + 25, txt);
		
		draw_set_color(c_white);
	}
}

// INIT EACH OF THE BOXES

// game variables
varBox(winGameVar.x, winGameVar.y, winGameVar.width, winGameVar.height,
"Game Vars", winGameVars, "donthide");
// global variables
varBox(winGlobalVar.x, winGlobalVar.y, winGlobalVar.width, winGlobalVar.height,
"Global Vars", winGlobalVars, "global");

if !(is_undefined(selected)) && (instance_exists(selected)) {
// instance variables
varBox(winVar.x, winVar.y, winVar.width, winVar.height,
"Variables", winVars, "object");

var _y = 600;
var startAt = clamp(scrollY, 0, array_length(winVars));
if (winVar.height < 0) _y = (spacing*(array_length(winVars)-startAt)) + 80;

// built-in variables
varBox(winVar.x, _y, winVar.width, -1,
"Built-In Vars", winVarsB, "donthide");

}

if (array_length(pinnedVars) > 1) {
	
var newX = pinnedVar.x;
if (is_undefined(selected))
	newX = pinnedVar.x2;

// pinned variables
varBox(newX, pinnedVar.y, pinnedVar.width, pinnedVar.height,
"Pinned Vars", pinnedVars, "pinned");

}

// SPRITE PREVIEW
// draws a mini version of the sprite, gives a stationary reference
// * I want to make this resize the sprite, but not stretch it.

if !(is_undefined(selected)) {
	var selectSpr = selected.sprite_index;
	var _x = 1120;
	var _y = 560;
	
	draw_set_alpha(0.6);

	if (selectSpr != -1)
		draw_sprite_stretched(selectSpr, selected.image_index, _x, _y, 150, 150);
	
	draw_set_alpha(1);
}

// EDIT MODE
// all the code that relates to editing a variable

var canEdit = !(is_undefined(selected)) or globalMode; // check if u can go into edit mode

if (editMode) && canEdit && (input == 0) {
	// choose the array to use
	var array = winVars;
	if (globalMode)
		array = winGlobalVars;
	
	draw_set_halign(fa_center);
	
	// find the selected variable
	var startAt = clamp(scrollY, 0, array_length(array) - 1);
	var varName = array[startAt][1];
	var _x = gameWidth / 2;
	
	// choose what the text at the top should show, if its a global variable or not
	var txt = "Edit " + "global." + varName + "?";
	if !(globalMode) 
		txt = "Edit " + varName + " of " + object_get_name(selected.object_index) + "?";
	
	// draw the text, then draw draw hint text
	draw_text_transformed(_x, 50, txt, 1.4, 1.4, 0);
	draw_text(_x, 80, "(Left Click to Confirm)\n(Right Click to exit Edit Mode)");
	
	draw_set_halign(fa_left);
	
	// when the user left clicks, enter the input ui state
	if (mouse_check_button_pressed(mb_left)) {
		// find the value to change
		if !(globalMode)
			var oldVal = variable_instance_get(selected, varName);
		else
			var oldVal = variable_global_get(varName);
		
		keyboard_string = string(oldVal);
		
		// set the type of input to change
		if (is_string(oldVal)) input = 2;
		else if (is_real(oldVal)) input = 1;
		else show_message("This type of value is not currently supported.\nSorry."); // * I will add more types of values, like arrays and such in the future.
		
		openedInput = true;
	}
	
	// exit edit mode
	if (mouse_check_button_pressed(mb_right))
		editMode = false;
}
if !(canEdit) editMode = false

// CONTEXT MENU

// make the menu open smoothly instead of instantly
// * I might remove this.
var lerpTo = 0;
if (contextMenuOpen)
	lerpTo = 1;
contextMenuScale = lerp(contextMenuScale, lerpTo, 0.1);

// decide if the menu should use normal options, or ones when you dont click on anything
var option = contextMenuOptions;
if (selected == undefined)
	option = contextMenuOptionsOther;

// find the position and size of the context menu
var _x = contextMenuPos[0];
var _y = contextMenuPos[1];
var _w = 80;
var _h = (array_length(option)*40);
var _rh = contextMenuScale * _h;
if (_rh < 2) _rh = -1;

if (selected == undefined) && (contextMenuOpen)
	_w = 140;

// all the code that happens when the context menu is open
if (contextMenuOpen) {

	draw_set_color(debugColors.contextMenu);

	draw_rectangle(_x, _y, _x + _w, _y + _rh, false); // draw the background

	draw_set_color(c_white);

	draw_set_alpha(contextMenuScale);

	// find where the mouse is on the screen
	// * I dont think these functions work... because of screen scaling and such
	// * I will need to go back and fix this
	var mx = window_mouse_get_x();
	var my = window_mouse_get_y();
	
	// show each avaliable option
	for (var i = 0; i < array_length(option); ++i) {
		var menuY = _y + (i*40); // find where to draw the option
		
		// check if the mouse is over the option, and do the specified action when clicked
		if (point_in_rectangle(mx, my, _x, menuY, _x + _w, menuY + 30)) {
			draw_set_color(debugColors.contextMenuSelect);
			
			draw_rectangle(_x, menuY, _x + _w, menuY + 39, false); // draw the background for when the option is hovered on
			
			draw_set_color(c_white);
			
			// select the option
			if (mouse_check_button_pressed(mb_left)) {
				contextMenuOpen = false; // close the context menu
				
				switch (i) {
					case 0: // edit
						editMode = true; // change to edit mode
						
						// determine if it should be in global mode or not
						globalMode = false;
						if (selected == undefined)
							globalMode = true;
							
						break;
					case 1: // destroy
						instance_destroy(selected); // destroy the selected instance
						break;
				}
			}
		}
		// if the mouse is clicked anywhere outside the menu, close it
		else if (mouse_check_button_pressed(mb_left))
			contextMenuOpen = false;
		
		draw_text(_x + 10, menuY + 10, option[i]); // draw the option
	}

	draw_set_alpha(1);

}

// INPUT UI

// smoothly move in when the ui is opened
if (input == 0)
	inputUIScale = lerp(inputUIScale, 1, 0.1);
else
	inputUIScale = lerp(inputUIScale, 0, 0.1);

// when the ui is opened
if (input != 0) {
	var inputUIY = (inputUIScale * -10) // find the y position to put the input ui
	
	draw_set_alpha(0.5);
	
	draw_rectangle_color(0, 0, gameWidth, gameHeight, c_gray, c_black, c_black, c_black, false); // draw the sickass background

	draw_set_alpha(1);
	
	// find what type of value the user is editing
	var valueEditing = "Integer";
	if (input = 1) && (floor(real(keyboard_string)) != real(keyboard_string)) valueEditing = "Float";
	if (input = 2) valueEditing = "String";
	
	// if the value is a real value, make sure the only things the user can input are numbers
	if (input = 1) keyboard_string = string_digits_decimal(keyboard_string);
	var finalString = keyboard_string;
	
	draw_set_halign(fa_center);
	
	draw_text_transformed(gameWidth / 2, 180 + inputUIY, "Editing a " + valueEditing, 1.6, 1.6, 0); // draw the text the displays what type of value you are editing
	draw_text_transformed(gameWidth / 2, 220 + inputUIY, "> " + string(finalString) + " <", 3, 3, 0); // draw the current input
	
	draw_text(gameWidth / 2, 400 + inputUIY, "(Enter or Left Click to confirm)\n(Right Click to cancel)"); // draw the hints
	
	draw_set_halign(fa_left);
	
	// make the value selected change to the users input
	if (keyboard_check_pressed(vk_enter)) or (mouse_check_button_pressed(mb_left)) && !(openedInput) {
		// choose the array to use depending on what type of value the user is editing
		var array = winVars;
		if (globalMode) array = winGlobalVars;
		
		// find the selected variable
		var startAt = clamp(scrollY, 0, array_length(array) - 1);
		var varName = array[startAt][1];
		
		if (finalString == "") && (input = 1) finalString = "0"; // if the variable is a real value, and the input is "", just make it 0 to avoid errors
		if (input = 1) finalString = real(finalString); // then make it a real value
		
		// find if its a global variable or not and set the value to the users input
		if !(globalMode)
			variable_instance_set(selected, varName, finalString);
		if (globalMode)
			variable_global_set(varName, finalString);
		
		input = 0; // close the input ui
	}
	
	// let the user scroll to change the input value
	// but only if its a real value
	if (input = 1) {
		// determine the change
		var change = (mouse_wheel_up() - mouse_wheel_down());
		if (keyboard_check(vk_shift)) change = change * 0.1; // if shift is held, only change by 0.1
		
		// find the cur value and change it
		var cur = keyboard_string;
		if (cur == "") cur = "0";
		if (change != 0) keyboard_string = string(real(cur) + change);
	}
	
	// cancel
	if (mouse_check_button_pressed(mb_right))
		input = 0;	
}
openedInput = false; // this is to prevent clash with the edit mode, because when you would confirm, it would also confirm in the edit modes code (weird stuff)

// watermark lol
draw_text(0, 700, "CodDebugger " + version);