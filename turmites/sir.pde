// Simulate infectious disease spread (SIR model)

// proportions of S, I, R turmites at each timestep
float[] s_val = new float[9000];
float[] i_val = new float[9000];
float[] r_val = new float[9000];

// initialize the SIR simulation
void init_SIR()
{
  // start of infectious disease
  
  //                     a   b   c   d
  new_turmite_rule (1, "Rb1 La1 Fc1 Fc1");  // cleans d -> c
  new_turmite_rule (2, "Rb2 La2 Fc2 Fd4");  // susceptible
  new_turmite_rule (3, "Rb3 La3 Fc3 Fd3");  // recovered
  new_turmite_rule (4, "Rb4 La4 Fd5 Fd4");  // infectious c -> d
  new_turmite_rule (5, "Rb5 La5 Fd6 Fd5");
  new_turmite_rule (6, "Rb6 La6 Fd7 Fd6");
  new_turmite_rule (7, "Rb7 La7 Fd8 Fd7");
  new_turmite_rule (8, "Rb8 La8 Fd3 Fd8");
  
  init_all();
  x_shift = 0;
  y_shift = 0;
  toroidal_wrap = true;
  show_turmite = false;
  stay_on_screen = true;
  which_colors = COLORS_SIR;  // specify use of SIR colors
  randomize_grid_SIR (0.3, 0.3, 0.5);
  create_SIR_turmites();
}

// initialize many turmites for SIR simulation
void create_SIR_turmites()
{
  float turmite_density = 0.1;
  float p_cleans = 0.05;
  float p_suscept = 0.8;
  float p_infect = 0.005;
  
  // normalize the probabilities (sum to 1)
  float sum = p_cleans + p_suscept + p_infect;
  p_cleans  /= sum;
  p_suscept /= sum;
  p_infect  /= sum;
  
  // initialize turmite list
  turmite_list = new ArrayList<Turmite>();
  
  int infect_count = 0;
  
  // go thru whole grid, and place a turmite at each location with probability "density"
  for (int i = 0; i < gx; i++)
    for (int j = 0; j < gy; j++)
      if (random(1) < turmite_density) {
        int x = (int) random(gx);
        int y = (int) random(gy);
        int dir = (int) random(4);
        Turmite t = new Turmite (x, y, dir);
        turmite_list.add(t);
        float r = random(1);
        if (r < p_cleans) {
          t.state = 0;
        }
        else if (r < p_cleans + p_suscept) {
          t.state = 1;
        }
        else {
          t.state = 3;
          infect_count++;
        }
      }
  
  println ("initial infected count: " + infect_count);
  
  // set the re-draw box to be the whole screen
  x0_draw = 0;
  y0_draw = 0;  
  x0_draw = gx - 1;
  y0_draw = gy - 1;  
  
  show_state();
}

// initialize the grid with random a, b and c, according to given probabilities
void randomize_grid_SIR(float pa, float pb, float pc)
{
  int i,j;
  
  // make sure sum of pa, pb, and pc equals 1
  float s = pa + pb + pc;
  pa /= s;
  pb /= s;
  pc /= s;

  // clear out the grid
  for (i = 0; i < gx_store_max; i++)
    for (j = 0; j < gy_store_max; j++) {
      float r = random(1);
      
      if (r < pa) {
        grid[i][j] = 0;  // set to a
      }
      else if (r < pa + pb) {
        grid[i][j] = 1;  // set to b
      }
      else {
        grid[i][j] = 2;  // set to c
      }
      
      visited[i][j] = 0;
    }

  draw_all();

  sim_step = 0;
}

void draw_SIR_graphs()
{
  int s_count = 0;
  int i_count = 0;
  int r_count = 0;
  
  // count the different types of turmites
  for (Turmite mite : turmite_list) {
    if (mite.state == 1)      // succeptible
      s_count++;
    else if (mite.state == 2) // recovered
      r_count++;
    else if (mite.state >= 3) // infected
      i_count++;
  }
  
  // calculate and store the proportion of S, I, R turmites
  float sum = s_count + i_count + r_count;
  s_val[sim_step] = s_count / sum;
  i_val[sim_step] = i_count / sum;
  r_val[sim_step] = r_count / sum;
  
  // exit if we are not actually drawing the graph
  if (!show_sir_graph)
    return;
  
  // vertical spacing
  int v_pad = 6;
  int v_box = 120;  // graph height
  int v_show = v_box - 2 * v_pad;
  int v_off = height - v_box;
  
  // horizontal spacing
  int h_off = (int) (0.5 * width);
  
  noStroke();
  fill (255);
  rect (h_off, v_off, 2000, v_box);
  
  // draw the graphs
  
  for (int i = 0; i <= sim_step; i++) {
    fill (0, 0, 255);
    circle (i + h_off, v_off + v_pad + (1 - s_val[i]) * v_show, 4);  // susceptible, blue
    fill (0, 255, 0);
    circle (i + h_off, v_off + v_pad + (1 - r_val[i]) * v_show, 4);  // recovered, green
    fill (255, 0, 0);
    circle (i + h_off, v_off + v_pad + (1 - i_val[i]) * v_show, 4);  // infected, red
  }
  
  //println ("s i r: " + s + " " + i + " " + r);
}

// write out SIR counts to a text file
void write_SIR()
{
  PrintWriter out = createWriter ("infection_out.txt");
  
  for (int i = 0; i < sim_step; i++) {
    out.println (i + ", " + s_val[i] + ", " + i_val[i] + ", " + r_val[i]);
  }
  
  out.close();
}

// set the color for a given cell type
void set_cell_color_SIR (int cell_type, int visit_flag)
{
  int l = 220;
  int h = 255;

  if      (cell_type ==  0)  fill (h, h, h);  // a -> white
  else if (cell_type ==  1)  fill (l, l, h);  // b -> light blue
  else if (cell_type ==  2)  fill (0, h, 0);  // c -> green
  else if (cell_type ==  3)  fill (h, 0, 0);  // d -> red
  else {
    fill (255);  // everything else is white
  }
 
}
