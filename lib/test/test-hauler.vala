using GLib;
using Gee;

void test_hauler_create () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var layout = hauler.layout;

  assert (hauler != null);
  assert (layout is Gemini.TileLayout);
}

void test_hauler_copy () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  hauler.terminal_add (new Gemini.Terminal (), 0);
  hauler.terminal_add (new Gemini.Terminal (), 0);
  hauler.terminal_add (new Gemini.Terminal (), 0);
  var hauler2 = hauler.copy ();

  var layout2 = hauler2.layout;
  weak ArrayList<Gemini.Terminal> terminals_1;
  weak ArrayList<Gemini.Terminal> terminals_2;
  terminals_1 = hauler.terminals;
  terminals_2 = hauler2.terminals;

  assert (hauler2 != null);
  assert (hauler.title == hauler2.title);
  assert (layout2 is Gemini.TileLayout);
  assert (terminals_1.size == terminals_2.size);
  for (int i = 0 ; i < terminals_1.size ; i++) {
    var terminal1 = terminals_1.get (i);
    var terminal2 = terminals_2.get (i);
    assert (terminal1 == terminal2);
  }
}

void test_hauler_switch () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  assert (hauler.layout_switch (typeof (Gemini.TileLayout)) == false);
  assert (hauler.layout_switch (typeof (Gemini.FullscreenLayout)) == true);
}

void test_hauler_get_focus_after_visible () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal3, 0);
  hauler.visible = true;

  assert (hauler.terminal_get_focus () == terminal3);
}

void test_hauler_switch_2 () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal3, 0);
  hauler.visible = true;

  assert (hauler.layout_switch (typeof (Gemini.FullscreenLayout)) == true);
  assert (hauler.layout is Gemini.FullscreenLayout);
}

void test_hauler_focus () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal2, 0);

  assert (hauler.terminal_get_focus () == null);
  assert (hauler.terminal_set_focus (terminal1));
  assert (hauler.terminal_get_focus () == terminal1);
  assert (hauler.terminal_set_focus (terminal2));
  assert (hauler.terminal_get_focus () == terminal2);
  assert (hauler.terminal_set_focus (terminal3) == false);
  assert (hauler.terminal_get_focus () == terminal2);
}

void test_hauler_position () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  var terminal4 = new Gemini.Terminal ();
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal3, 2);

  assert (hauler.terminal_get_position (terminal1) == 0);
  assert (hauler.terminal_get_position (terminal2) == 1);
  assert (hauler.terminal_get_position (terminal3) == 2);
  assert (hauler.terminal_get_position (terminal4) == -1);
}

void test_hauler_move () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal3, 2);

  hauler.terminal_move (terminal1, 0);
  assert (hauler.terminal_get_position (terminal1) == 0);
  assert (hauler.terminal_get_position (terminal2) == 1);
  assert (hauler.terminal_get_position (terminal3) == 2);
  hauler.terminal_move (terminal1, 1);
  assert (hauler.terminal_get_position (terminal1) == 1);
  assert (hauler.terminal_get_position (terminal2) == 0);
  assert (hauler.terminal_get_position (terminal3) == 2);
  hauler.terminal_move (terminal1, 2);
  assert (hauler.terminal_get_position (terminal1) == 2);
  assert (hauler.terminal_get_position (terminal2) == 0);
  assert (hauler.terminal_get_position (terminal3) == 1);
}

void test_hauler_remove () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal3, 2);

  assert (hauler.terminal_get_position (terminal1) == 0);
  assert (hauler.terminal_get_position (terminal2) == 1);
  assert (hauler.terminal_get_position (terminal3) == 2);
  hauler.terminal_remove (terminal2);
  assert (hauler.terminal_get_position (terminal1) == 0);
  assert (hauler.terminal_get_position (terminal2) == -1);
  assert (hauler.terminal_get_position (terminal3) == 1);
  hauler.terminal_remove (terminal2);
  assert (hauler.terminal_get_position (terminal1) == 0);
  assert (hauler.terminal_get_position (terminal2) == -1);
  assert (hauler.terminal_get_position (terminal3) == 1);
  hauler.terminal_remove (terminal3);
  assert (hauler.terminal_get_position (terminal1) == 0);
  assert (hauler.terminal_get_position (terminal2) == -1);
  assert (hauler.terminal_get_position (terminal3) == -1);
  hauler.terminal_remove (terminal1);
  assert (hauler.terminal_get_position (terminal1) == -1);
  assert (hauler.terminal_get_position (terminal2) == -1);
  assert (hauler.terminal_get_position (terminal3) == -1);
  /*assert (hauler.terminal_get_focus () == null);*/
}

void test_hauler_zoom () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal3, 2);

  hauler.terminal_zoom (terminal1);
  assert (hauler.terminal_get_position (terminal1) == 0);
  assert (hauler.terminal_get_position (terminal2) == 1);
  assert (hauler.terminal_get_position (terminal3) == 2);
  hauler.terminal_zoom (terminal2);
  assert (hauler.terminal_get_position (terminal1) == 1);
  assert (hauler.terminal_get_position (terminal2) == 0);
  assert (hauler.terminal_get_position (terminal3) == 2);
  hauler.terminal_zoom (terminal3);
  assert (hauler.terminal_get_position (terminal1) == 2);
  assert (hauler.terminal_get_position (terminal2) == 1);
  assert (hauler.terminal_get_position (terminal3) == 0);
}

void test_hauler_visible () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var t = new Gemini.Terminal ();
  hauler.terminal_add (t, 0);
  hauler.visible = true;
  assert (hauler.visible == true);
  hauler.visible = true;
  assert (hauler.visible == true);
  hauler.visible = false;
  assert (hauler.visible == false);
  hauler.visible = false;
  assert (hauler.visible == false);
}

void test_hauler_focus_order () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();

  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal3, 2);
  hauler.terminal_set_focus (terminal1);
  hauler.terminal_set_focus (terminal2);
  hauler.terminal_set_focus (terminal3);

  assert (hauler.terminal_get_focus () == terminal3);
  hauler.terminal_remove (terminal3);
  assert (hauler.terminal_get_focus () == terminal2);
  hauler.terminal_remove (terminal2);
  assert (hauler.terminal_get_focus () == terminal1);
  hauler.terminal_remove (terminal1);

  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal3, 2);
  hauler.terminal_set_focus (terminal1);
  hauler.terminal_set_focus (terminal2);
  hauler.terminal_set_focus (terminal3);

  assert (hauler.terminal_get_focus () == terminal3);
  hauler.terminal_remove (terminal2);
  assert (hauler.terminal_get_focus () == terminal3);
  hauler.terminal_remove (terminal3);
  assert (hauler.terminal_get_focus () == terminal1);
  hauler.terminal_remove (terminal1);

}

void test_hauler_focus_order_copy () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();

  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal3, 0);
  hauler.terminal_set_focus (terminal1);
  hauler.terminal_set_focus (terminal2);
  hauler.terminal_set_focus (terminal3);
  
  var h2 = hauler.copy ();
  assert (h2.terminal_get_focus () == terminal3);
  h2.terminal_remove (terminal3);
  assert (h2.terminal_get_focus () == terminal2);
  h2.terminal_remove (terminal2);
  assert (h2.terminal_get_focus () == terminal1);
  h2.terminal_remove (terminal1);

  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal3, 0);
  hauler.terminal_set_focus (terminal1);
  hauler.terminal_set_focus (terminal3);
  hauler.terminal_set_focus (terminal2);
  
  h2 = hauler.copy ();
  assert (h2.terminal_get_focus () == terminal2);
  h2.terminal_remove (terminal2);
  assert (h2.terminal_get_focus () == terminal3);
  h2.terminal_remove (terminal3);
  assert (h2.terminal_get_focus () == terminal1);
  h2.terminal_remove (terminal1);

  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal3, 0);
  hauler.terminal_set_focus (terminal1);
  hauler.terminal_set_focus (terminal3);
  hauler.terminal_set_focus (terminal2);
  
  h2 = hauler.copy ();
  assert (h2.terminal_get_focus () == terminal2);
  h2.terminal_remove (terminal3);
  assert (h2.terminal_get_focus () == terminal2);
  h2.terminal_remove (terminal2);
  assert (h2.terminal_get_focus () == terminal1);
  h2.terminal_remove (terminal1);
}

void test_hauler_focus_order_copy2 () {
  var hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  var terminal4 = new Gemini.Terminal ();

  hauler.terminal_add (terminal1, 0);
  hauler.terminal_add (terminal2, 0);
  hauler.terminal_add (terminal3, 0);
  hauler.terminal_add (terminal4, 0);
  hauler.terminal_set_focus (terminal3);
  hauler.terminal_set_focus (terminal4);
  hauler.terminal_set_focus (terminal2);
  hauler.terminal_set_focus (terminal1);
  var h2 = hauler.copy ();
  h2.terminal_remove (terminal1);
  assert (h2.terminal_get_focus () == terminal2);
  h2.terminal_remove (terminal2);
  assert (h2.terminal_get_focus () == terminal4);
  h2.terminal_remove (terminal4);
  assert (h2.terminal_get_focus () == terminal3);
}

public static void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Gemini.configuration = new Gemini.Configuration ();

  Test.add_func ("/Gemini/Hauler/Create", test_hauler_create);
  Test.add_func ("/Gemini/Hauler/Switch", test_hauler_switch);
  Test.add_func ("/Gemini/Hauler/Switch_2", test_hauler_switch_2);
  Test.add_func ("/Gemini/Hauler/Copy", test_hauler_copy);
  Test.add_func ("/Gemini/Hauler/Focus", test_hauler_focus);
  Test.add_func ("/Gemini/Hauler/Position", test_hauler_position);
  Test.add_func ("/Gemini/Hauler/Move", test_hauler_move);
  Test.add_func ("/Gemini/Hauler/Remove", test_hauler_remove);
  Test.add_func ("/Gemini/Hauler/Zoom", test_hauler_zoom);
  Test.add_func ("/Gemini/Hauler/Visible", test_hauler_visible);
  Test.add_func ("/Gemini/Hauler/FocusAfterVisible", test_hauler_get_focus_after_visible);
  Test.add_func ("/Gemini/Hauler/FocusOrder", test_hauler_focus_order);
  Test.add_func ("/Gemini/Hauler/FocusOrderCopy", test_hauler_focus_order_copy);
  Test.add_func ("/Gemini/Hauler/FocusOrderCopy2", test_hauler_focus_order_copy2);

  Test.run ();
}
