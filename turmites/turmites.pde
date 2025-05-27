//  Turmites and Vants
//
//  Greg Turk, 2011 to 2025
//
//  My original code for vants and turmites was written in the late 1980's, but I no
//  longer have a copy of that program.

import processing.opengl.*;

int gsize = 12;             // size of one element in grid
int grid_lines_min = 4;     // minimum size of cell where grid lines are still drawn

// for gsize = 12
int gx_show_max = 1248;    // maximum grid width to display (used to determine screen size)
int gy_show_max = 824;     // maximum grid height to display

int gx,gy;   // grid elements to show in x and y

int grid_x_offset = 0;        // grid drawing offset from left edge
int grid_y_offset = 0;        // grid drawing offset from top edge

int gx_store_max = 4000;   // maximum grid storage width (used to allocate memory)
int gy_store_max = 4000;   // maximum grid storage height

// shift amounts to put turmites near the center of the grid
int x_shift_init = 2000; // use for most instances
int y_shift_init = 2000;
//int x_shift = 0;  // use for SIR, toroidal_wrap on
//int y_shift = 0;
int x_shift = x_shift_init;
int y_shift = y_shift_init;

int grid[][] =    new int[gx_store_max][gy_store_max];   // cell grid
int visited[][] = new int[gx_store_max][gy_store_max];   // was this cell visited?

boolean simulate_flag = false;     // if the turmite is running
boolean show_turmite = true;       // draw the turmite?
boolean show_grid = true;          // draw grid lines?
boolean show_visited_gray = true;  // show gray cells in visited empty areas?
boolean show_sir_graph = false;     // show graph for SIR?
boolean write_frames = false;      // write out frames of movie to file?

boolean show_sidebar = true;      // draw the sidebar?
boolean show_help = false;        // show help screen?
boolean show_rule_table = false;  // display the rule table?
boolean show_state = false;       // draw the state and step count?

boolean toroidal_wrap = false;     // use toroidal wrapping?
boolean stay_on_screen = false;    // does turmite need to stay on screen?

// start direction of turmite (0 = north, 1 = west, 2 = south, 3 = east)
int start_direction = 0;

// start position of turmite
float x_start_fract = 0.5;
float y_start_fract = 0.5;
int x_start, y_start;

float gx_fract = 0.3;  // fraction of grid to use for rule table (if shown)

int cell_type_max = 8;        // number of non-empty cell types
int cell_draw_type = 1;       // current cell type being drawn

int COLORS_DEFAULT = 0;
int COLORS_SIR = 1;
int COLORS_VANT = 2;

int which_colors = COLORS_DEFAULT;   // which color list to use?


public class Turmite {
  int x,y;     // position
  int dir;     // direction
  int state;

  public Turmite (int xx, int yy, int direction) {
    x = xx;
    y = yy;
    dir = direction;
    state = 0;
  }
}

// list of turmites
ArrayList<Turmite> turmite_list;

int sim_step = 0;      // number of simulation steps that have been taken
int frame_count = 0;   // frame count when writing out movie images

int draw_freq = 1;      // how often to re-draw the grid
int x0_draw,y0_draw;    // lower range of re-draw box
int x1_draw,y1_draw;    // upper rante of re-draw box

// colors of various parts of the interface
color background_color = color (255, 255, 255);
color grid_color = color (180, 180, 220);
color select_color = color (0, 0, 0);
color mite_color = color (0, 0, 0);

PFont font;    // font for drawing letters in window

// calculate how much of the grid will be visible
void visible_grid_calc()
{
  int pad = 8;    // minimum edge padding
  if (gsize < 4)  // no edge padding if we have very small grid cells
    pad = 0;

  int gx_remove = (int) (gx_show_max * gx_fract);

  // calculate how many grid squares can be shown horizontally and vertically
  gx = (gx_show_max - 2 * pad) / gsize;
  gy = (gy_show_max - 2 * pad) / gsize;
  
  // calculate x and y edge padding
  grid_x_offset = (gx_show_max - gx * gsize) / 2;
  grid_y_offset = (gy_show_max - gy * gsize) / 2;

  // re-calculate number of grid squares horizontally if we are showing rule table
  if (show_rule_table) {
    gx = (gx_show_max - gx_remove - 2 * pad) / gsize;
  }
  
}

// calculate size of window
void settings()
{
  visible_grid_calc();
        
  size (gx_show_max, gy_show_max);
  
  //println ("gx gy: " + gx + " " + gy);
  //println ("screen size: " + width + " " + height);
}

// initialize various things
void setup()
{
  // create drawing window
  background (background_color);
  
  // load or create font
  
  font = createFont ("ArialMT", 48);
  textFont (font, 16);
  
  strokeWeight (1);
  
  set_grid_size (16);
  
  // determine where turmite will start
  calculate_start_position();

  // maybe seed the random number generator
  randomSeed (10);

  // initialize the transition rule table
  init_rules();
  
  // test the vant rule creation method
  //new_vant_rule ("RL", 0);
  
  // test the turmite rule creation method
  new_turmite_rule (1, "Rb1 La1");
  
  // initialize the grid and draw it
  init_grid();
  
  // initialize the list of turmites
  init_turmites();
  
  // start on help screen
  show_help = true;
  draw_all();
  
}

// initialize various things to make ready for simulating vants / turmites
void init_all()
{
  x_shift = x_shift_init;
  y_shift = y_shift_init;
  
  toroidal_wrap = false;
  show_turmite = true;
  stay_on_screen = false;
  
  init_grid();
  init_turmites();
  draw_all();
  simulate_flag = false;
  which_colors = COLORS_DEFAULT;  // set use of default colors
}

// initialize the grid
void init_grid()
{
  int i,j;

  // clear out the grid
  for (i = 0; i < gx_store_max; i++)
    for (j = 0; j < gy_store_max; j++) {
      grid[i][j] = 0;
      visited[i][j] = 0;
    }

  sim_step = 0;
}

// initialize the list of turmites to just one turmite in the center of the grid
void init_turmites()
{
  // initialize the turmite position and direction

  int mite_x = x_start;
  int mite_y = y_start;
  
  // initialize turmite list
  turmite_list = new ArrayList<Turmite>();
  add_turmite (mite_x + x_shift, mite_y + y_shift, start_direction, 0);
  
  // set the re-draw box
  x0_draw = x1_draw = mite_x;
  y0_draw = y1_draw = mite_y;  
  
  show_state();
}

// add a new turmite to the list of turmites
void add_turmite (int x, int y, int dir, int state)
{
  Turmite t = new Turmite (x, y, dir);
  t.state = state;
  turmite_list.add(t);
  
  // account for shift that centers the turmites in the grid
  x -= x_shift;
  y -= y_shift;
  
  // expand the drawing box if necessary
  if (x < x0_draw) x0_draw = x;
  if (x > x1_draw) x1_draw = x;
  if (y < y0_draw) y0_draw = y;
  if (y > y1_draw) y1_draw = y;
}

// process draw commands
void draw()
{
  // maybe write out frames for a movie
  if (simulate_flag && write_frames) {
    write_movie_frame();
  }

  if (simulate_flag) {
    if (draw_freq == 1) {
      advance_sim();
      draw_all();
    }
    else
      simulate_several_steps();
  }
  
  // draw the turmites
  if (show_turmite)
    draw_all_turmites();

  // draw SIR graphs?
  if (which_colors == COLORS_SIR)
    draw_SIR_graphs();
}

// draw everything
void draw_all()
{
  background (background_color);
  
  if (show_help) {
    show_help();
    return;
  }
  
  visible_grid_calc();
  
  if (show_grid)
    draw_grid();

  draw_all_cells();
  
  if (show_sidebar) {
    draw_sidebar();
    show_state();
  }
  
  if (show_turmite)
    draw_all_turmites();
}

void simulate_several_steps()
{
  int i,j;

   for (i = 0; i < draw_freq; i++)
     if (simulate_flag)
       advance_sim();

  // re-draw everything in the region that was changed
  for (i = x0_draw; i <= x1_draw; i++)
    for (j = y0_draw; j <= y1_draw; j++)
      draw_cell (i, j);
      
  if (show_sidebar) {
    draw_sidebar();
    show_state();
  }

  if (!simulate_flag)
    return;

  if (show_turmite)
    draw_all_turmites();

  // set the re-draw box to the first turmite's position
  Turmite t = turmite_list.get(0);
  x0_draw = x1_draw = t.x - x_shift;
  y0_draw = y1_draw = t.y - y_shift;
  
  // expand the re-draw box to encompass any other turmite's positions
  for (i = 1; i < turmite_list.size(); i++) {
    t = turmite_list.get(i);
    // account for shifting turmite to center of grid
    int x = t.x - x_shift;
    int y = t.y - y_shift;
    if (x < x0_draw) x0_draw = x;
    if (x > x1_draw) x1_draw = x;
    if (y < y0_draw) y0_draw = y;
    if (y > y1_draw) y1_draw = y;
  }

}

// write out current image to a file (for movie making)
void write_movie_frame()
{
  String str = String.format ("movie/frame_%04d.png", frame_count);
  frame_count++;
  saveFrame (str);
}

// set the color for a given cell type
void set_cell_color (int cell_type, int visit_flag)
{
  if (which_colors == COLORS_DEFAULT)
    set_cell_color_standard (cell_type, visit_flag);
  else if (which_colors == COLORS_SIR)
    set_cell_color_SIR (cell_type, visit_flag);
  else if (which_colors == COLORS_VANT)
    set_cell_color_vant (cell_type, visit_flag);
  else {
    println ("Error, undefined colors: ", which_colors);
  }
}

// set the color for a given cell type
void set_cell_color_standard (int cell_type, int visit_flag)
{
  if (cell_type == 0) {  // a
    if (visit_flag == 1 && show_visited_gray)
      fill (220, 220, 220);
    else
      fill (255, 255, 255);
  }
  else if (cell_type ==  1)  fill (200,  50,  50);  // b
  else if (cell_type ==  2)  fill ( 50, 200,  50);  // c
  else if (cell_type ==  3)  fill ( 50,  50, 200);  // d
  else if (cell_type ==  4)  fill (250, 150, 150);  // e
  else if (cell_type ==  5)  fill (150, 250, 150);  // f
  else if (cell_type ==  6)  fill (150, 150, 250);  // g
  else if (cell_type ==  7)  fill ( 50, 150, 250);  // h
  else if (cell_type ==  8)  fill (150,  50, 250);  // i
  else if (cell_type ==  9)  fill (250, 150,  50);  // a'
  else if (cell_type == 10)  fill (250,  50, 150);  // b'
  else if (cell_type == 11)  fill ( 50, 250, 150);  // c'
  else if (cell_type == 12)  fill (150, 250,  50);  // d'
  else if (cell_type == 13)  fill (200, 200,  50);  // e'
  else if (cell_type == 14)  fill (200,  50, 200);  // f'
  else if (cell_type == 15)  fill ( 50, 200, 200);  // g'
  else if (cell_type == 16)  fill ( 50,  50, 150);  // h'
  else if (cell_type == 17)  fill (150,  50, 150);  // i'
  else {
    println ("don't know how to draw cell type");
  }
 
}

// set the color for a Vant
void set_cell_color_vant (int cell_type, int visit_flag)
{
  int l = 220;
  int h = 255;

  if (cell_type ==  0) {
    if (visit_flag == 1)
      fill (255, 0, 0);
    else
      fill (255, l, l);
  }
  else if (cell_type ==  1) {
    if (visit_flag == 1)
      fill (0, 255, 0);
    else
      fill (l, 255, l);
  }
  else if (cell_type ==  2) {
    if (visit_flag == 1)
      fill (0, 0, 255);
    else
      fill (l, l, 255);
  }
  else {
    fill (0, 0, 0);
  }
 
}

// draw an object in one cell
void draw_cell (int i, int j)
{
  // don't draw cells that are not in visible part of grid
  if (i < 0 || i >= gx)
    return;
  if (j < 0 || j >= gy)
    return;

  // take into account initial shifts of turmites in the grid
  int ii = i + x_shift;
  int jj = j + y_shift;

  // don't draw cells that are off the grid
  if (ii < 0 || ii >= gx_store_max)
    return;
  if (jj < 0 || jj >= gy_store_max)
    return;
    
  set_cell_color (grid[ii][jj], visited[ii][jj]);
  
  noStroke();
  int x = grid_x_offset + i * gsize + 1;
  int y = grid_y_offset + j * gsize + 1;
  
  // don't leave room for the grid lines if the resolution is too high
  if (gsize < grid_lines_min || show_grid == false)
    rect (x, y, gsize, gsize);
  else
    rect (x, y, gsize-1, gsize-1);
}

// draw the interiors of all the cells
void draw_all_cells()
{
  int i,j;
  
  // draw any non-zero cells
  for (i = 0; i < gx; i++)
    for (j = 0; j < gy; j++)
        draw_cell (i, j);
}

// draw the grid
void draw_grid()
{
  int i,j;
  float x,x2;
  float y,y2;
  
  // don't draw the grid if the resolution is too high
  if (gsize < grid_lines_min) { return; }
  
  strokeWeight (1);
  stroke (grid_color);
  
  // vertical grid lines
  y = grid_y_offset;
  y2 = grid_y_offset + gy * gsize;
  for (i = 0; i <= gx; i++) {
    x = grid_x_offset + i * gsize;
    line (x, y, x, y2);
  }
  
  // horozontal grid lines
  x = grid_x_offset;
  x2 = grid_x_offset + gx * gsize;
  for (j = 0; j <= gy; j++) {
    y = grid_y_offset + j * gsize;
    line (x, y, x2, y);
  }
}

// draw a turmite
void draw_turmite (Turmite tur)
{
  // don't draw the turmite if the resolution is too high
  if (gsize < 4)
    return;

  // don't draw if the turmite is off the visible part of the grid
  int xx = tur.x - x_shift;
  int yy = tur.y - y_shift;
  if (xx < 0 || xx >= gx)
    return;
  if (yy < 0 || yy >= gy)
    return;

  fill (mite_color);
  noStroke();
  
  float x = grid_x_offset + (tur.x - x_shift + 0.5) * gsize;
  float y = grid_y_offset + (tur.y - y_shift + 0.5) * gsize;
  float radius = gsize * 0.15;
  
  ellipse (x, y, 2*radius, 2*radius);
  
  if (gsize < 8)
    return;
  
  float theta = (tur.dir + 1) * PI * -0.5;
  radius = gsize * 0.3;
  float dx = radius * cos(theta);
  float dy = radius * sin(theta);
  
  stroke (mite_color);
  strokeWeight (2);
  line (x, y, x+dx, y+dy);
  strokeWeight (1);
}

void draw_all_turmites()
{
  if (show_help)
    return;
    
  for (int i = 0; i < turmite_list.size(); i++) {
    draw_turmite (turmite_list.get(i));
  }
}

void calculate_start_position()
{
  x_start = (int) (gx * x_start_fract);
  y_start = (int) (gy * y_start_fract);
}

void calculate_start_position(float x, float y)
{
  x_start_fract = x;
  y_start_fract = y;
  x_start = (int) (gx * x_start_fract);
  y_start = (int) (gy * y_start_fract);
}

void decrease_grid_size(boolean clear)
{
  if (gsize >= 32) { println ("no change in grid size"); return; }
  gx /= 2;
  gy /= 2;
  x_shift += (int) (gx * 0.5);
  y_shift += (int) (gy * 0.5);  
  gsize *= 2;
  if (clear) {
    calculate_start_position();
    init_grid();
    init_turmites();
  }
  draw_all();
  //println ("grid width & height: " + gx + " " + gy + " gsize: " + gsize);
}

void increase_grid_size(boolean clear)
{
  if (gsize == 1) {  println ("no change in grid size"); return; }
  x_shift -= (int) (gx * 0.5);
  y_shift -= (int) (gy * 0.5);
  gx *= 2;
  gy *= 2;
  gsize /= 2;
  if (clear) {
    calculate_start_position();
    init_grid();
    init_turmites();
  }
  draw_all();
  //println ("grid width & height: " + gx + " " + gy);
}

void set_grid_size (int gsize_new)
{
  if (gsize_new == gsize) {  println ("no change in grid size"); return; }

  gsize = gsize_new;
  visible_grid_calc();
  
  init_grid();
  init_turmites();
  draw_all();
  //println ("grid width & height: " + gx + " " + gy);
}

// read a grid pattern from a file
void read_grid(String filename)
{
  int i,j;
  
  // prepend data file location
  filename = "../data/" + filename;
  
  // open the file
  String lines[] = loadStrings(filename);
  if (lines == null) {
    println ("cannot open file " + filename);
    return;
  }
  
  // get the position where to start the upper left of the grid pattern
  String[] words = split (lines[0], " ");
  float fx = parseFloat (words[0]);
  float fy = parseFloat (words[1]);
  
  int x0 = (int) (gx * fx);
  int y0 = (int) (gy * fy);
  
  println ("fx fy : " + str(fx) + " " + str(fy));
  println ("x0 y0 : " + str(x0) + " " + str(y0));
  
  // read the remaining lines from the file
  for (j = 1; j < lines.length; j++) {
    int y = y0 + j - 1;
    int yy = y + y_shift;
    //println (lines[j]);
    char[] str_array = lines[j].toCharArray();
    //println ("string length = " + str(str_array.length));
    for (i = 0; i < str_array.length; i++) {
      int x = x0 + i;
      int xx = x + x_shift;
      char c = str_array[i];
      //print (c);
//      int val = c - '0';  // use digits 0 to 9
      int val = c - 'a';  // use characters a to i
      if (c == '<' || c == '>' || c == '^' || c == 'v') {
        Turmite t = turmite_list.get(0);
        t.x = xx;
        t.y = yy;
        if (c == '^') t.dir = 0;
        if (c == 'v') t.dir = 2;
        if (c == '<') t.dir = 1;
        if (c == '>') t.dir = 3;
        continue;
      }
      if (c == ' ') {
        val = 0;
      }
      if (val < 0 || val > 17) {
//        println ("Bad grid value: " + str(c));
      }
      else {
//        print (str(val) + " ");
        grid[xx][yy] = val;
      }
    }
//    println();
  }
  
  draw_all();

}

// process mouse press (change color of cell)
void mousePressed()
{
  int x = (mouseX - grid_x_offset) / gsize;
  int y = (mouseY - grid_y_offset) / gsize;
  
  // see if user clicked in the right margin
  if (x >= gx) {
    draw_all();
    return;
  }
  
  // ignore clicks that are not on the grid
  if (x < 0 || x >= gx || y < 0 || y >= gy)
    return;
  
  // change the state of grid cell

  if (grid[x][y] == cell_draw_type)
    grid[x][y] = 0;
  else
    grid[x][y] = cell_draw_type;
  
  println ("clicked at cell: " + x + " " + y);
  
  draw_all();
}
