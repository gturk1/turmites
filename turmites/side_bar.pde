// Show rule table

// where the rule table starts
int x_rules;
int y_rules;

// draw sidebar (rule table)
void draw_sidebar()
{
    
  fill (255, 255, 255);
  noStroke();
  
 if (show_rule_table) {
    rect (grid_x_offset + gx * gsize + 10, 0, width, height);
    draw_rule_table();
  }

}

// draw the rule table, maybe highlighting next rule to be applied
void draw_rule_table()
{
  stroke (0, 0, 0);
  fill (0, 0, 0);
  
  String str = "";
  
  int tsize;            // text size
  int xspace,yspace;    // space between table entries
  int box_shift;        // horizontal shift amount for drawing boxes
  int dx,dy;
  
  if (num_states <= 4) {
    tsize = 32;
  }
  else {
    tsize = 20;
  }
    
  //println ("num_states num_colors: " + num_states + " " + num_colors);
  //println ("rule table text size: " + tsize);
  
  textSize (tsize);
  xspace = (int) (2.5 * tsize);
  yspace = (int) (1.5 * tsize);
  
  // shift amounts to place rule table
  if (num_states <= 4) {
    x_rules = grid_x_offset + gx * gsize + 90;
    box_shift = 8;
  }
  else {
    x_rules = grid_x_offset + gx * gsize + 60;
    box_shift = -2;
  }
  
  y_rules = (height / 2) - ((num_states - 2) * yspace) / 2;
  
  dx = (int) (0.5 * tsize);
  dy = (int) (0.3 * tsize);
  
  text ("Transition Table", x_rules - xspace + dx, y_rules - 4.0 * yspace);
  
  // symbols across the top
  strokeWeight (1.5);
  for (int c = 0; c < num_colors; c++) {
    
    // draw box corresponding to symbol
    
    // outline the first box with black (since the color is white)
    if (c == 0)
      stroke (0, 0, 0);
    else
      noStroke();

    // draw the color for a given symbol indexed with "j"
    set_cell_color (c, 0);
    rect (x_rules + c * xspace + box_shift, y_rules - 3 * yspace, 32, 32);
    
    stroke (0, 0, 0);
    fill (0, 0, 0);

    // draw character
    char ch = char (((int) 'a') + c);
    text (ch, x_rules + c * xspace + dx, y_rules - yspace - dy);
  }
  strokeWeight (1);

  // draw the individual rules
  for (int s = 0; s < num_states; s++) {
    
    // draw state number on the Left
    str = str(s+1);
    text (str, x_rules - xspace + dx, y_rules + s * yspace);

    for (int c = 0; c < num_colors; c++) {

      int dir   = rule_dir[s][c];
      int cell  = rule_cell[s][c];
      int state = rule_state[s][c];
      
      if (dir == Left)    { str = "L"; }
      if (dir == Right)   { str = "R"; }
      if (dir == Forward) { str = "F"; }
      if (dir == Back)    { str = "B"; }
      
      char ch = (char) (((int) 'a') + cell);
      
      str = str + str(ch) + str(state+1);
      
      if (dir == Halt)    { str = "----"; }

      // draw individual rule
      text (str, x_rules + c * xspace, y_rules + s * yspace);
    
    }
  }
  
  Turmite t = turmite_list.get(0);
  int c = grid[t.x][t.y];
  int s = t.state - 1;

  noFill();
  stroke (0, 0, 0);
  dx = (int) (0.5 * tsize);
  dy = (int) (0.35 * tsize);
  rect (x_rules + c * xspace - dx, y_rules + s * yspace + dy, xspace, yspace);

}

// maybe print or draw the first turmite's state and simulation step number
void show_state()
{
  // exit if we are not drawing the sidebar
  if (show_state == false)
    return;
  
  // bail if there are no turmites left on grid
  if (turmite_list.size() == 0)
    return;

  Turmite t = turmite_list.get(0);
  int state = t.state + 1;      // state values start at zero, but draw them from one

  noStroke();
  fill (255, 255, 255);
  
  float w = 90;
  rect (width - w, height - w, w, w);
  
  stroke (0, 0, 0);
  fill (0, 0, 0);
  
  textSize(12);
  
  String str = String.valueOf(state);
  float sw = textWidth (str);
  text (str, width - sw - 10, height - 40);
  
  str = String.valueOf(sim_step);
  sw = textWidth (str);
  text (str, width - sw - 10, height - 20);
  
}

String[] help_1 = {
  "space bar : toggle simulation off / on",
  "",
  "? : toggle help screen",
  "c : clear the grid",
  "t : toggle whether the vant or termite is shown",
  "x : toggle whether a grid is drawn",
  "z : toggle whether the state and step count is shown",
  "r : toggle whether to show the rule table",
  "i : toggle whether the SIR graph is drawn",
  ". : increase grid size",
  ", : decrease grid size",
  "arrows : move position in grid", 
  "w : write a snapshot of the currently displayed image to a file",
  "m : prepare to write out many image files, for movie creation",
  "q : quit program",
  "",
  "Vant and Turmite Selection:",
  "1 : original RL vant due to Langton",
  "2 : RRLL vant, rounded bilaterial symmetry",
  "3 : RLLR vant, boxy bilateral symmetry",
  "4 : binary counter",
  "5 : (B)RL slow symmetric growth",
  "6 : Fibonacci spiral",
  "7 : dragon curve",
  "8 : prime number sieve",
  "9 : universal machine that is calculating Fibonacci numbers",
  "0 : universal constructor the simulates the RL vant",
  "- : self-reproducing machine (close up)",
  "= : self-reproducing machine (zoomed out)",
  "! : infectious disease spread (SIR)",

};

String[] help_2 = {
  "Setting Time Steps (middle QWERTY row):",
  "s : take a single simulation step",
  "d : 1 step at a time",
  "f : 10 steps at a time",
  "g : 100 steps",
  "h : 1,000 steps",
  "j : 4,000 steps",
  "k : 10,000 steps",
  "l : 40,000 steps",
  "; : 320,000 steps",
  "' : 2,560,000 steps",
};

void show_help()
{
  background (255, 255, 255);
  
  textSize (18);
  
  int x = 20;
  int y = 50;
  
  for (int i = 0; i < help_1.length; i++) {
    text(help_1[i], x, y + i * 25); // Print each string with spacing
  }
  
  x = 600;
  
  for (int i = 0; i < help_2.length; i++) {
    text(help_2[i], x, y + i * 25); // Print each string with spacing
  }  

}
