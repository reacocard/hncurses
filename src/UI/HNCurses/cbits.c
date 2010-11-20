#include "cbits.h"

WINDOW* get_stdscr() { return stdscr; }
int get_cols() { return COLS; }
int get_lines() { return LINES; }
int get_color_pairs() { return COLOR_PAIRS; }

