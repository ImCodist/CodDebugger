draw_set_color(c_red);
draw_rectangle(0, 0, gameWidth, 10, false);
draw_set_color(c_white);

// game variables box
function varBox(_x, _y, _w, _h, title, varArray, type) {
	
	var startAt = clamp(scrollY, 0, array_length(varArray));
	if (type == "donthide") startAt = 0;
	
	draw_set_alpha(0.5);
	draw_set_color(debugColors.windowTop);
	
	draw_rectangle(_x, _y, _x + _w, _y + 20, false);
	
	draw_set_color(debugColors.window);
	
	if (_h < 0) _h = (spacing*(array_length(varArray)-startAt)) + 15;
	draw_rectangle(_x, _y, _x + _w, ((_y + 20) + _h), false);

	draw_set_color(c_white);
	draw_set_alpha(1);
	
	if (type == "object") title += " (" + object_get_name(selected.object_index) + ")";
	draw_text(_x, _y, title);
	
	var maxLength = 22;
	
	for (var i = startAt; i < array_length(varArray); ++i) {
		var txt = varArray[i][1] + ": " + string(varArray[i][0]);
		
		if (scrollX > string_length(txt)) continue;
		txt = string_copy(txt, scrollX, maxLength);
		
		if (editMode) && (i = startAt) && (type == "object") {
			draw_set_color(c_yellow);
			txt = "> " + txt;
		}
		
		draw_text(_x + 10, _y + (spacing * (i-startAt)) + 25, txt);
		
		draw_set_color(c_white);
	}
}

varBox(winGameVar.x, winGameVar.y, winGameVar.width, winGameVar.height,
"Game Vars", winGameVars, "donthide");

varBox(winGlobalVar.x, winGlobalVar.y, winGlobalVar.width, winGlobalVar.height,
"Global Vars", winGlobalVars, "default");

if !(is_undefined(selected)) && (instance_exists(selected)) {
	
varBox(winVar.x, winVar.y, winVar.width, winVar.height,
"Variables", winVars, "object");

var _y = 600;
var startAt = clamp(scrollY, 0, array_length(winVars));
if (winVar.height < 0) _y = (spacing*(array_length(winVars)-startAt)) + 80;

varBox(winVar.x, _y, winVar.width, -1,
"Built-In Vars", winVarsB, "donthide");

}

// contextMenu
var lerpTo = 0;
if (contextMenuOpen)
	lerpTo = 1;
contextMenuScale = lerp(contextMenuScale, lerpTo, 0.1);

var _x = contextMenuPos[0];
var _y = contextMenuPos[1];
var _w = contextMenu.width;
var _h = (array_length(contextMenuOptions)*40);
var _rh = contextMenuScale * _h;
if (_rh < 2) _rh = -1;

draw_set_color(debugColors.contextMenu);

draw_rectangle(_x, _y, _x + _w, _y + _rh, false);

draw_set_color(c_white);

// edit mode

if (editMode) && !(is_undefined(selected)) {
	draw_set_halign(fa_center);
	
	var startAt = clamp(scrollY, 0, array_length(winVars) - 1);
	var varName = winVars[startAt][1];
	var _x = gameWidth / 2;
	var txt = "Edit " + varName + " of " + object_get_name(selected.object_index) + "?";
	
	draw_text_transformed(_x, 50, txt, 1.4, 1.4, 0);
	draw_text(_x, 80, "(Left Click to Confirm)\n(Right Click to exit Edit Mode)");
	
	draw_set_halign(fa_left);
	
	if (mouse_check_button_pressed(mb_left)) {
		var oldVal = variable_instance_get(selected, varName);
		
		var val = 0;
		if (is_string(oldVal)) val = get_string("set", oldVal);
		else val = get_integer("set", oldVal);
		
		variable_instance_set(selected, varName, val);
	}
	
	if (mouse_check_button_pressed(mb_right))
		editMode = false;
}
if (is_undefined(selected)) editMode = false;

// context meny

if (contextMenuOpen) {

	draw_set_alpha(contextMenuScale);

	var mx = window_mouse_get_x();
	var my = window_mouse_get_y();
	
	for (var i = 0; i < array_length(contextMenuOptions); ++i) {
		var menuY = _y + (i*40);
		
		if (point_in_rectangle(mx, my, _x, menuY, _x + _w, menuY + 30)) {
			draw_set_color(debugColors.contextMenuSelect);
			
			draw_rectangle(_x, menuY, _x + _w, menuY + 39, false);
			
			draw_set_color(c_white);
			
			if (mouse_check_button_pressed(mb_left)) {
				contextMenuOpen = false;
				
				switch (i) {
					case 0:
						editMode = true;
						break;
					case 1:
						instance_destroy(selected);
						break;
				}
			}
		}
		else if (mouse_check_button_pressed(mb_left))
			contextMenuOpen = false;
		
		draw_text(_x + 10, menuY + 10, contextMenuOptions[i]);
	}

	draw_set_alpha(1);

}

// draw sprite

if !(is_undefined(selected)) {
	var selectSpr = selected.sprite_index;
	var _x = 1120;
	var _y = 560;
	
	draw_set_alpha(0.6);

	if (selectSpr != -1)
		draw_sprite_stretched(selectSpr, selected.image_index, _x, _y, 150, 150);
	
	draw_set_alpha(1);
}