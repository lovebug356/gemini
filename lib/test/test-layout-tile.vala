using GLib;
using Gee;

void test_layout_create () {
  var layout = new Gemini.TileLayout ();

  assert (layout != null);
  assert (layout.name == "tile");
  GLib.List children = layout.get_children ();
  assert (children.length () == 1);
  Gtk.HBox hbox = (Gtk.HBox) children.nth_data (0);
  assert (hbox is Gtk.HBox);
  GLib.List children_hbox = hbox.get_children ();
  assert (children_hbox.length () == 1);
  Gtk.VBox stack = (Gtk.VBox) children_hbox.nth_data (0);
  assert (stack is Gtk.VBox);
}

GLib.List get_hbox_from_layout (Gemini.Layout layout) {
  GLib.List children = layout.get_children ();
  assert (children.length () == 1);
  Gtk.HBox hbox = (Gtk.HBox) children.nth_data (0);
  return hbox.get_children ();
}

Gemini.Terminal get_zoom_from_layout (Gemini.Layout layout) {
  GLib.List children = get_hbox_from_layout (layout);
  assert (children.length () >= 1);
  Gemini.Terminal terminal = (Gemini.Terminal) children.nth_data (0);
  assert (terminal is Gemini.Terminal);
  return terminal;
}

void test_layout_add_1 () {
  var layout = new Gemini.TileLayout ();
  var terminal = new Gemini.Terminal ();
  layout.terminal_add (terminal, 0);

  GLib.List children = get_hbox_from_layout (layout);
  assert (children.length () == 2);
  Gemini.Terminal widget1 = (Gemini.Terminal) children.nth_data (0);
  assert (widget1 is Gemini.Terminal);
  assert (widget1 == terminal);
  assert (get_zoom_from_layout (layout) == terminal);
}

void test_layout_add_pos_2 () {
  var layout = new Gemini.TileLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 1);

  assert (get_zoom_from_layout (layout) == terminal1);
  var stack = get_stack_from_layout (layout);
  assert (get_terminal_from_stack (stack, 0) == terminal2);
}

void test_layout_add_pos_5 () {
  var layout = new Gemini.TileLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  var terminal4 = new Gemini.Terminal ();
  var terminal5 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 1);
  layout.terminal_add (terminal3, 1);
  layout.terminal_add (terminal4, 2);
  layout.terminal_add (terminal5, 0);
  
  assert (false == true);
}

Gtk.VBox get_stack_from_layout (Gemini.Layout layout) {
  GLib.List children = get_hbox_from_layout (layout);
  assert (children.length () == 2);
  Gtk.VBox stack = (Gtk.VBox) children.nth_data (1);
  assert (stack is Gtk.VBox);
  return stack;
}

Gemini.Terminal get_terminal_from_stack (Gtk.VBox stack, int position) {
  GLib.List children = stack.get_children ();
  assert (children.length () > position);
  Gemini.Terminal terminal = (Gemini.Terminal) children.nth_data (position);
  assert (terminal is Gemini.Terminal);
  return terminal;
}

void test_layout_add_2 () {
  var layout = new Gemini.TileLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 0);

  assert (get_zoom_from_layout (layout) == terminal2);
  var stack = get_stack_from_layout (layout);
  assert (get_terminal_from_stack (stack, 0) == terminal1);
}

void test_layout_add_5 () {
  var layout = new Gemini.TileLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  var terminal4 = new Gemini.Terminal ();
  var terminal5 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 0);
  layout.terminal_add (terminal3, 0);
  layout.terminal_add (terminal4, 0);
  layout.terminal_add (terminal5, 0);

  assert (get_zoom_from_layout (layout) == terminal5);
  var stack = get_stack_from_layout (layout);
  assert (get_terminal_from_stack (stack, 0) == terminal4);
  assert (get_terminal_from_stack (stack, 1) == terminal3);
  assert (get_terminal_from_stack (stack, 2) == terminal2);
  assert (get_terminal_from_stack (stack, 3) == terminal1);
}

void test_layout_move_1 () {
  var layout = new Gemini.TileLayout ();
  var terminal1 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_move (terminal1, 0);
  assert (get_zoom_from_layout (layout) == terminal1);
}

void test_layout_move_2 () {
  var layout = new Gemini.TileLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 0);
  layout.terminal_move (terminal1, 0);
  var stack = get_stack_from_layout (layout);
  assert (get_zoom_from_layout (layout) == terminal1);
  assert (get_terminal_from_stack (stack, 0) == terminal2);
  layout.terminal_move (terminal1, 1);
  assert (get_zoom_from_layout (layout) == terminal2);
  assert (get_terminal_from_stack (stack, 0) == terminal1);
}

void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func ("/Gemini/Layout/Tile/Create", test_layout_create);
  Test.add_func ("/Gemini/Layout/Tile/Add1", test_layout_add_1);
  Test.add_func ("/Gemini/Layout/Tile/Add2", test_layout_add_2);
  Test.add_func ("/Gemini/Layout/Tile/Add5", test_layout_add_5);
  Test.add_func ("/Gemini/Layout/Tile/AddPos2", test_layout_add_pos_2);
  Test.add_func ("/Gemini/Layout/Tile/AddPos5", test_layout_add_pos_5);
  Test.add_func ("/Gemini/Layout/Tile/Move1", test_layout_move_1);
  // Test.add_func ("/Gemini/Layout/Tile/Move2", test_layout_move_2);

  Test.run ();
}
