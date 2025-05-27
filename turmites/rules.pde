// rule set for turmites and vants

import java.lang.*;

// rule table
int rule_state[][];   // next state for a given rule
int rule_dir[][];     // direction change for a rule
int rule_cell[][];    // cell type for a rule
int spawn_dir[][];    // direction to spawn new turmite (usually -1)
int spawn_state[][];  // state of newly spawned turmite
int rule_used[][];    // has this rule been used?

int num_states = 1;  // number of states of rules
int num_colors = 2;  // number of colors of rules

// directions a turmite can move (also halt and new)
int Forward = 0;
int Left = 1;
int Back = 2;
int Right = 3;
int Halt = 4;

// allocate space for the rule tables
void init_rules()
{
  int n_states = 40;
  int n_cell_colors = 26;
  rule_state  = new int[n_states][n_cell_colors];
  rule_dir    = new int[n_states][n_cell_colors];
  rule_cell   = new int[n_states][n_cell_colors];
  spawn_dir   = new int[n_states][n_cell_colors];
  spawn_state = new int[n_states][n_cell_colors];
  rule_used   = new int[n_states][n_cell_colors];
}

// set the state of all the turmites
// (rule definition states start at 1, but are stored at 0)
void set_init_state (int state)
{
  state = state - 1;
  for (int i = 0; i < turmite_list.size(); i++) {
    Turmite t = turmite_list.get(i);
    t.state = state;
  }
}

// advance the state of the grid and turmite(s)
void advance_sim()
{
//  println ("In advance_sim");
  for (int i = turmite_list.size() - 1; i >= 0 ; i--) {
    Turmite t = turmite_list.get(i);
    boolean okay = advance_turmite (t);
    // delete turmite if it went off the grid or halted
    if (!okay) {
      if (show_sidebar) {
        show_state();
      }
      turmite_list.remove(i);
      if (turmite_list.size() < 1)
        simulate_flag = false;
    }
  }
  
  // for figuring out how many steps for self-reproduction
  //if (sim_step == 7544430) {
  //  simulate_flag = false;
  //  println ("self-reproduction has been halted");
  //  draw_all();
  //}
  
  sim_step++;
}

// Advance the state of one turmite.
// Returns false if turmite halts or goes off the grid.
//
// Steps:
//  - determine next position based on current direction
//  - move turmite to new location
//  - use rule table to determine updated direction, turmite state, and cell color
//  - update direction, state, and cell color

boolean advance_turmite(Turmite tur)
{
  int dx = 0;
  int dy = 0;
  
  int mite_x = tur.x;
  int mite_y = tur.y;
  int mite_dir = tur.dir;
  int mite_state = tur.state;

//  println ("In advance_turmite: " + str(mite_x) + " " + str(mite_y));

  // mark the current position as having been visited
  visited[mite_x][mite_y] = 1;
  
  // grab appropriate values from the rule table
  int cell_type  = grid[mite_x][mite_y];
  int dir_change = rule_dir[mite_state][cell_type];
  int next_state = rule_state[mite_state][cell_type];
  int next_cell  = rule_cell[mite_state][cell_type];
  int new_spawn_dir = spawn_dir[mite_state][cell_type];
  int new_spawn_state = spawn_state[mite_state][cell_type];
  
  // mark that this rule has been used
  rule_used[mite_state][cell_type] = 1;
  
  // check to see if turmite should be halted
  if (dir_change == Halt) {
    println ("halt");
    draw_cell (mite_x, mite_y);
    return (false);
  } 

  // save the old position and direction
  int x_old = mite_x;
  int y_old = mite_y;
  int old_mite_dir = mite_dir;
  
  // update the direction of the turmite
  mite_dir = mite_dir + dir_change;
  while (mite_dir >= 4) mite_dir -= 4;
  while (mite_dir < 0) mite_dir += 4;
    
  // update grid value and turmite state
  grid[mite_x][mite_y] = next_cell;
  mite_state = next_state;
    
  // figure out change in position based on direction
  if (mite_dir == 0) {
    dy = -1;
  }
  if (mite_dir == 1) {
    dx = -1;
  }
  if (mite_dir == 2) {
    dy = 1;
  }
  if (mite_dir == 3) {
    dx = 1;
  }
  
  // update to new position
  mite_x += dx;
  mite_y += dy;
  
  // check for turmite going off grid
  if (stay_on_screen) {
    
    int mx = mite_x - x_shift;
    int my = mite_y - y_shift;

    if (mx < 0 || mx >= gx || my < 0 || my >= gy) {
      if (toroidal_wrap) {
        // wrap the turmite's position
        if (mx < 0)   mite_x += gx;
        if (mx >= gx) mite_x -= gx;
        if (my < 0)   mite_y += gy;
        if (my >= gy) mite_y -= gy;
      }
      else {
        // move it back onto the grid
        mite_x -= dx;
        mite_y -= dy;
        draw_cell (mite_x, mite_y);
        println ("off the grid #1: " + mite_x + " " + mite_y);
        return (false);
      }
    }
  
  }

  if (!stay_on_screen &&
    (mite_x < 0 || mite_x >= gx_store_max || mite_y < 0 || mite_y >= gy_store_max)) {
    println ("off the grid #2: " + mite_x + " " + mite_y);
    return (false);
  }

  // save the new state of the turmite
  tur.x = mite_x;
  tur.y = mite_y;
  tur.dir = mite_dir;
  tur.state = mite_state;
  
  // maybe spawn a new turmite
  if (new_spawn_dir >= 0) {
    println ("New turmite created");
    new_spawn_dir = (old_mite_dir + new_spawn_dir);
    while (new_spawn_dir >= 4) new_spawn_dir -= 4;
    while (new_spawn_dir < 0) new_spawn_dir += 4;
    add_turmite (x_old, y_old, new_spawn_dir, new_spawn_state);
    //println (tur.x + " " + tur.y + " " + x_old + " " + y_old);
  }

  // maybe draw the updated cells at every step
  if (draw_freq == 1) {
    // draw the old cell the turmite moved from
    draw_cell (x_old, y_old);
    
    // draw the cell that the turmite has moved to
    draw_cell (mite_x, mite_y);
    
    // show the turmite's state
    if (show_sidebar) {
      draw_sidebar();
      show_state();
    }
    
    // draw the turmite
    if (show_turmite)
      draw_turmite (tur);
  }
  else {  // otherwise update the re-draw box size, if necessary
    // account for shift of turmite to center of grid
    int x = mite_x - x_shift;
    int y = mite_y - y_shift;
    if (x < x0_draw) x0_draw = x;
    if (x > x1_draw) x1_draw = x;
    if (y < y0_draw) y0_draw = y;
    if (y > y1_draw) y1_draw = y;
  }
  
  // signal that the turmite is okay (has not halted or gone off the grid)
  return (true);
}

// translate a character code (rlfb) into a numeric code for turmite direction
int get_direction_code (char c)
{
  if (c == 'r') {
    return (Right);
  }
  else if (c == 'l') {
    return (Left);
  }
  else if (c == 'f') {
    return (Forward);
  }
  else if (c == 'b') {
    return (Back);
  }
  else if (c == 'h' || c == '-') {
    return (Halt);
  }
  else {
    println ("bad character: " + c);
    return (-1);
  }
}

// create a new VANT rule based on the given string (just one state)
void new_vant_rule (String str, int cycle_offset)
{
  //println ("string length = " + str.length());
  char[] str_array = str.toCharArray();
  
  // set the next state, cell type, and direction for the current cell type
  
  for (int i = 0; i < str.length(); i++) {
    
    rule_state[0][i] = 0;  // stay in state zero
    
    // set the next state, based on the current cell value
    if (i < str.length() - 1) {
      rule_cell[0][i] = i + 1;
    }
    else {
      rule_cell[0][i] = cycle_offset;
    }
    
    // the string defines what the next turn will be
    char c = Character.toLowerCase(str_array[i]);
    rule_dir[0][i] = get_direction_code (c);
    
    // vants do not spawn new vants (currently)
    spawn_dir[0][i] = -1;
    spawn_state[0][i] = 0;
    
    // mark each part of rule as unused
    rule_used[0][i] = 0;
  }
  
  num_states = 1;
  num_colors = str.length();
  
//  println ("num states = " + num_states);
//  println ("num colors = " + num_colors);

  // initialize everything for drawing
  init_all();
}

// create new TURMITE rules for a turmite in a given state
// (rule definition states start at 1, but are stored at 0)
void new_turmite_rule (int state_num, String str)
{
  state_num = state_num - 1;
  
  //println();
  //println ("rules for state number " + state_num);
  
  // split the rule string using one or more spaces as the separator  
  String[] parts = str.split(" +");
  
  for (int cell_val = 0; cell_val < parts.length; cell_val++) {
    String word = parts[cell_val];
//    println (word);

    // Most rules are three charcters long (new direction, new cell value, new state).

    char c = Character.toLowerCase(word.charAt(0));
    int new_dir = get_direction_code (c);

    int new_cell = Character.toLowerCase(word.charAt(1)) - 'a';
    int new_state = word.charAt(2) - '0';
    
    // States may be one or two digits, which complicates the rule string parsing.
    // Also the turmite may spawn another, which makes the rule string longer still.
    
    // handle case where state is two digits
    int next_char = 3;
    if (word.length() > 3) {
      int new_digit = word.charAt(next_char) - '0';
      if (new_digit >= 0 && new_digit <= 9) {
        new_state = 10 * new_state + new_digit;
        next_char += 1;
//        println ("Next state is two digits: " + new_state);
      }
    }

    // handle case where a new turmite is spawned
    int new_spawn_dir = -1;
    int new_spawn_state = 1;
    
    if (word.length() > 4) {
      println ("New turmite rule");
      c = Character.toLowerCase(word.charAt(next_char));
      new_spawn_dir = get_direction_code (c);
      new_spawn_state = word.charAt(next_char + 1) - '0';
      // handle case where the new spawn state is two digits
      if (next_char + 2 == word.length() - 1) {
        int new_digit = word.charAt(next_char + 2) - '0';
        // sanity check for this digit
        if (new_digit < 0 || new_digit > 9) {
          println ("error: second digit for new_spawn_state is not a digit: " + new_digit);
          exit();
        }
        new_spawn_state = 10 * new_spawn_state + new_digit;
//        println ("Next spawn state is two digits: " + new_spawn_state);
      }
    }

    //println ("dir = " + new_dir);
    //println ("cell = " + new_cell);
    //println ("state = " + new_state);
    
    // states in rules start at 1, but are stored starting at 0
    new_state -= 1;
    new_spawn_state -= 1;
    
    // add this rule to the table
    rule_dir[state_num][cell_val] = new_dir;
    rule_cell[state_num][cell_val] = new_cell;
    rule_state[state_num][cell_val] = new_state;
    spawn_dir[state_num][cell_val] = new_spawn_dir;
    spawn_state[state_num][cell_val] = new_spawn_state;
    rule_used[state_num][cell_val] = 0;
  }
  
  num_states = state_num + 1;
  num_colors = parts.length;
}

// print out a table showing which rules have been used
void print_rules_used()
{
  println();
  
  print ("    ");
  for (int c = 0; c < num_colors; c++) {
    print (char(c + int('a')) + " ");
  }
  println();
  
  for (int s = 0; s < num_states; s++) {
    print (String.format("%2d  ", s+1));
    for (int c = 0; c < num_colors; c++) {
      print (rule_used[s][c] + " ");
    }
    println();
  }
}
