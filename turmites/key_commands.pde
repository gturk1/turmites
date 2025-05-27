// process keyboard events

void keyPressed() {
  
  // any key press will get us out of "help" mode
  if (show_help) {
    show_help = false;
    draw_all();
    return;
  }

  if (key == CODED) {
    
    int shift = (int) (gx / 16.0);  // arrows shift 1/8 of screen width
    
    if (keyCode == LEFT) {
      //println ("left");
      x_shift -= shift;
      draw_all();
    }
    else if (keyCode == RIGHT) {
      //println ("right");
      x_shift += shift;
      draw_all();
    }
    else if (keyCode == UP) {
      //println ("up");
      y_shift -= shift;
      draw_all();
    }
    else if (keyCode == DOWN) {
      //println ("down");
      y_shift += shift;
      draw_all();
    }
    return;
  }  
  
  if (key == ' ') {  // toggle simulation
    simulate_flag = !simulate_flag;
    draw_all();
  }
  else if (key == '?') { 
    show_help = !show_help;
    draw_all();  
  }
  else if (key == 's') {  // single step
    simulate_flag = false;
    advance_sim();
    draw_all();
  }
  else if (key == 'c') {
    calculate_start_position();
    init_all();
    draw_all();
  }
  else if (key == 't') {
    show_turmite = !show_turmite;
    draw_all();
  }
  else if (key == 'x') {
    show_grid = !show_grid;
    draw_all();
  }
  else if (key == 'z') {
    show_state = !show_state;
    draw_all();
  }
  else if (key == 'r') {
    show_rule_table = !show_rule_table;
    visible_grid_calc();
    calculate_start_position();
    draw_all();
  }
  else if (key == 'i') {
    show_sir_graph = !show_sir_graph;
    draw_all();
  }
  else if (key == '.') {
    increase_grid_size (false);
  }
  else if (key == ',') {
    decrease_grid_size (false);
  }
  else if (key == 'w') {
    save ("turmite_out.png");
    println ("saved screen to file");
  }
  else if (key == 'm') {
    println ("Writing out movie frames.");
    write_frames = true;
    draw_all();
  }
  else if (key == 'd') {
    draw_freq = 1;
    draw_all();
  }
  else if (key == 'f') {
    draw_freq = 10;
    draw_all();
  }
  else if (key == 'g') {
    draw_freq = 100;
    draw_all();
  }
  else if (key == 'h') {
    draw_freq = 1000;
    draw_all();
  }
  else if (key == 'j') {
    draw_freq = 4000;
    draw_all();
  }
  else if (key == 'k') {
    draw_freq = 10000;
    draw_all();
  }
  else if (key == 'l') {
    draw_freq = 40000;
    draw_all();
  }
  else if (key == ';') {
    draw_freq = 320000;
    draw_all();
  }
  else if (key == '\'') {
    draw_freq = 2560000;
    draw_all();
  }
  else if (key == '1') {  // original vant
    draw_freq = 10;
    set_grid_size (16);
    start_direction = 0;
    calculate_start_position (0.5, 0.5);
    new_vant_rule ("RL", 0);
  }
  else if (key == '2') {  // bilateral symmetry rounded
    draw_freq = 100;
    set_grid_size (8);
    start_direction = 3;
    calculate_start_position (0.5, 0.36);
    init_all();
    new_vant_rule ("RRLL", 0);
  }
  else if (key == '3') {  // bilateral symmetry boxy
    draw_freq = 100;
    set_grid_size (8);
    start_direction = 3;
    calculate_start_position (0.5, 0.5);
    init_all();
    new_vant_rule ("RLLR", 0);
  }
  else if (key == '4') {  // binary counter
    draw_freq = 1;
    set_grid_size (16);
    start_direction = 0;
    calculate_start_position (0.5, 0.5);
    new_vant_rule ("RF", 0);
  }
  else if (key == '5') {  // slow symmetric growth
    draw_freq = 1000;
    set_grid_size (16);
    start_direction = 0;
    calculate_start_position (0.5, 0.5);
    new_vant_rule ("BRL", 1);
  }
  else if (key == '6') {   // spiral that Dewdney published
  
    new_turmite_rule (1, "Lb1 Fa2");
    new_turmite_rule (2, "Rb1 Rb1");
    
    draw_freq = 1000;
    set_grid_size (2);
    start_direction = 0;
    x_start_fract = 0.43;
    y_start_fract = 0.4;
    calculate_start_position();
    init_all();
  }
  else if (key == '7') {    // Dragon curve
    
    //                     a   b   c   d   e   f   g
    new_turmite_rule (1, "Fg2 --- --- --- --- --- ---");
    new_turmite_rule (2, "Rb7 --- --- --- --- --- ---");
    new_turmite_rule (3, "Bb3 Re3 Lf3 Fg3 --- --- Fd4");
    new_turmite_rule (4, "Ba3 Lb4 Rc4 Fd4 Bb5 Bc6 Bd7");
    new_turmite_rule (5, "Bc4 Rb5 Lc5 Fd5 --- --- ---");
    new_turmite_rule (6, "Bb4 Rb6 Lc6 Fd6 --- --- ---");
    new_turmite_rule (7, "Bd4 Rb7 Lc7 Fd7 --- --- ---");
    
    draw_freq = 1000;
    set_grid_size (5);
    start_direction = 3;
    x_start_fract = 0.76;
    y_start_fract = 0.345;
    calculate_start_position();
    
    init_all();
  }
  else if (key == '8') {    // Prime number sieve (spawns many turmites)
    
    //                       a     b    c     d    e
    new_turmite_rule (1,  "Fa2F4  Fb6  ----  Fd1  Fe6");  // initiate "e" on diagonal and "b" in row along bottom
    new_turmite_rule (2,  "La3    ---- ---- ---- ----");  // make diagonal "e"
    new_turmite_rule (3,  "Re2B1  ---- ---- ---- ----");  // make diagonal "e"
    new_turmite_rule (4,  "Fb5L9  ---- ---- ---- ----");  // make column of "e" on left
    new_turmite_rule (5,  "Fb5    ---- ---- ---- ----");  // make row of "b" on bottom
    new_turmite_rule (6,  "Bc7    Bb8  Fc6  Bc7  Be8 ");  // place spaced out b's a column (every 2, 3, 4...)
    new_turmite_rule (7,  "Bd1    Fb7  Fc7  Fd7  Fe7 ");  // space b's
    new_turmite_rule (8,  "Bb6    Fb8  Fc8  Fd8  Fe8 ");  // space b's
    new_turmite_rule (9,  "Fe9R10 Fa9  ---- ---- ----");  // create per-row turmites for detecting primes
    new_turmite_rule (10, "Ba12   Fb11 ---- ---- Fe10");  // skip over b and e
    new_turmite_rule (11, "Ba12   Hb11 Fc11 Fd11 Be13");  // moves east, halt on "b" (composite)
    new_turmite_rule (12, "Ba10   Fb12 Fc12 Fd12 Fe12");  // moves west after finding "a" or "d" (don't know)
    new_turmite_rule (13, "Ha13   Fb13 Fc13 Fd13 Fb13");  // moves west after finding "e" (prime)

    draw_freq = 1;
    set_grid_size (12);
    start_direction = 3;
    calculate_start_position (0.3, 0.85);

    init_all();
  }
  else if (key == '9') {  // universal machine, calculating Fibonacci numbers

    init_all();

    // new version, where a zero on decrement causes a jump
    //                     a   b   c   d   e   f   g
    new_turmite_rule (1, "Fa1 Fe3 --- Fd2 Fe1 Ff1 Lg4");
    new_turmite_rule (2, "Bc3 Bc3 Fb2 --- --- --- ---");
    new_turmite_rule (3, "Fa3 Fb3 --- Rd3 Lb3 Lf1 Bg9");
    new_turmite_rule (4, "Ba9 Fc4 Fb5 Rd4 --- Lf6 Fg4");
    new_turmite_rule (5, "Ba7 Bb6 Bc6 --- --- Rf6 Fg5");
    new_turmite_rule (6, "--- Fb6 Fc6 Rd3 Fb3 Ff6 Fg6");
    new_turmite_rule (7, "Fa7 Fa7 Fc6 Rd3 Fe8 Lf8 ---");
    new_turmite_rule (8, "Fa8 Re8 Lc4 Rd5 Fe8 Ff8 Fg8");
    new_turmite_rule (9, "Fa9 Fe8 --- Rd9 Fe3 Lf8 ---");

    draw_freq = 10;
    set_grid_size (16);
    start_direction = 0;
    calculate_start_position (0.5, 0.5);
    read_grid ("fibonacci.txt");
    
    draw_all();
  }
  else if (key == '0') {   // universal constructor that simulates RL machine
    init_all();
    
    set_universal_rules();
    
    draw_freq = 1000;
    set_grid_size (10);
    set_init_state (1);

    x_start_fract = 0.5;
    y_start_fract = 0.8;
    calculate_start_position();

    // simulate RL vant
    read_grid ("rl_simulator.txt");
    
    draw_all();
  }
  else if (key == '-') {  // universal constructor, performing self-reproduction (closes-up)
    init_all();
    
    set_universal_rules();
    
    x_start_fract = 0.5;
    y_start_fract = 0.8;
    calculate_start_position();

    // self-reproduction
    
    draw_freq = 1000;
    set_grid_size (5);
    set_init_state (3);
    read_grid ("copy_block_no_comments_close.txt");
    
    draw_all();
  }
  else if (key == '=') {  // universal constructor, performing self-reproduction
    init_all();
    
    set_universal_rules();
    
    x_start_fract = 0.5;
    y_start_fract = 0.8;
    calculate_start_position();

    // self-reproduction
    
    draw_freq = 10000;
    set_grid_size (3);
    set_init_state (3);
    read_grid ("copy_block_no_comments.txt");
        
    draw_all();
  }
  else if (key == '!') {  // spread of infectious disease
    draw_freq = 1;
    set_grid_size (6);
    show_sir_graph = true;
    init_SIR();
  }
  else if (key == 'q' || key == 'Q') {
    exit();
  }
}

void set_universal_rules()
{
    //                      a    b    c    d    e    f    g    h    i    j    k    l    m    n    o    p    q    r
    new_turmite_rule ( 1, "Fa1  Fe3  ---  Fd2  Fe1  Ff1  Lg4  Rh8  Fi1  Fa11 Fb11 Fc11 Fd11 Fe11 Ff11 Fg11 Fh11 Fi11 ");
    new_turmite_rule ( 2, "Bc3  Bc3  Fb2  ---  ---  ---  ---  Fh7  Lj12 Fj2  Fk2  Fl2  Fm2  Fn2  Fo2  Fp2  Fq2  Fr2  ");
    new_turmite_rule ( 3, "Fa3  Fb3  Lc3  Rd3  Lb3  Lf1  Bg9  Fh5  Ri1  Ri16 Ri16 Ri16 Ri16 Ri16 Ri16 Ri16 Ri16 Ri16 ");  // 14 -> 16
    new_turmite_rule ( 4, "Ba9  Fc4  Fb5  Rd4  ---  Lf6  Fg4  Fh5  Li17 Fj4  Fk4  Fl4  Fm4  Fn4  Fo4  Fp4  Fq4  Fr4  ");
    new_turmite_rule ( 5, "Ba7  Bb6  Bc6  ---  ---  Rf6  Fg5  ---  Li20 Fj5  Fk5  Fl5  Fm5  Fn5  Fo5  Fp5  Fq5  Fr5  ");
    new_turmite_rule ( 6, "Ri11 Fb6  Fc6  Rd3  Fb3  Ff6  Fg6  Fh3  ---  Fj6  Fk6  Fl6  Fm6  Fn6  Fo6  Fp6  Fq6  Fr6 ");
    new_turmite_rule ( 7, "Fa7  Fa7  Fc6  Rd3  ---  ---  ---  Fh4  Ba3  Fj7  Fk7  Fl7  Fm7  Fn7  Fo7  Fp7  Fq7  Fr7  ");
    new_turmite_rule ( 8, "Fa8  Re8  Lc4  Rd5  Fe8  Ff8  Fg8  Fh10 Li18 Fj8  ---  ---");
    new_turmite_rule ( 9, "Fa9  Fe8  Lc9  Rd9  Fe3  Lf8  ---  Fh9  Ri9  Fj9  Fk9  Fl9  Fm9  Fn9  Fo9  Fp9  Fq9  Fr9  ");
    new_turmite_rule (10, "---  ---  ---  ---  ---  ---  ---  Fh2  Li19 Fj10 ---  ---  ---  ---  ---  ---  ---  ---  ");
    new_turmite_rule (11, "Fa3  ---  ---  ---  ---  ---  ---  Fh11 Ri11 Fj11 Fk11 Fl11 Fm11 Fn11 Fo11 Fp11 Fq11 Fr11 ");
    new_turmite_rule (12, "Ra14 Rb14 Rc14 Rd14 Re14 Rf14 Rg14 Rh14 Ri14 Rj13 Rk13 Rl13 Rm13 Rn13 Ro13 Rp13 Rq13 Rr13 ");  // 16 -> 14
    new_turmite_rule (13, "Bj13 Bk13 Bl13 Bm13 Bn13 Bo13 Bp13 Bq13 Br13 Ra12 Rb12 Rc12 Rd12 Re12 Rf12 Rg12 Rh12 Ri12 ");
    new_turmite_rule (14, "Ra6  Rb6  Rc6  Rd6  Re6  Rf6  Rg6  Rh6  Ri6  La11 Lb11 Lc11 Ld11 Le11 Lf11 Lg11 Lh11 Li11 ");
    new_turmite_rule (15, "Ba14 Bb14 Bc14 Bd14 Be14 Bf14 Bg14 Bh14 Bi14 Ba16 Bb16 Bc16 Bd16 Be16 Bf16 Bg16 Bh16 Bi16 ");  // 14 <-> 16
    new_turmite_rule (16, "Rj15 Rk15 Rl15 Rm15 Rn15 Ro15 Rp15 Rq15 Rr15 Rj16 Rk16 Rl16 Rm16 Rn16 Ro16 Rp16 Rq16 Rr16 ");  // 14 -> 16
    new_turmite_rule (17, "Bb11 Bc11 Bd11 Be11 Bf11 Bg11 Bh11 Bi11 Bi11 Fj17 Fk17 Fl17 Fm17 Fn17 Fo17 Fp17 Fq17 Fr17 ");
    new_turmite_rule (18, "Bj11 Bk11 Bl11 Bm11 Bn11 Bo11 Bp11 Bq11 Br11 Fj18 Fk18 Fl18 Fm18 Fn18 Fo18 Fp18 Fq18 Fr18 ");
    new_turmite_rule (19, "Ba1  Bb1  Bc1  Bd1  Be1  Bf1  Bg1  Bh1  Bi1  Fj19 Fk19 Fl19 Fm19 Fn19 Fo19 Fp19 Fq19 Fr19 ");
    new_turmite_rule (20, "Ba9  Ba11 Bb11 Bc11 Bd11 Be11 Bf11 Bg11 Bh11 Fj20 Fk20 Fl20 Fm20 Fn20 Fo20 Fp20 Fq20 Fr20 ");
}
