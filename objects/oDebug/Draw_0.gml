
/*

---------- DRAW ----------

Just draw outlines.
Thats literally all this event is for.

*/

if !(is_undefined(mouseOver)) {
	drawOutline(mouseOver, c_white);
}

if !(is_undefined(selected)) {
	drawOutline(selected, c_yellow);
}