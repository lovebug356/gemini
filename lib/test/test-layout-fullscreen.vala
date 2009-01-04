using GLib;
using Gee;
using Gemini;

void test_layout_create () {
  var layout = new FullscreenLayout ();

  assert (layout != null);
  assert (layout.name == "fullscreen");
  GLib.List children = layout.get_children ();
  assert (children.length () == 0);
}

void test_layout_add_1 () {
  var layout = new Gemini.FullscreenLayout ();
  var terminal = new Gemini.Terminal ();
  layout.terminal_add (terminal, 0);

  /* adding one terminal, should be fullscreen */
  assert (layout.size == 1);
}

void test_layout_add_2 () {
  var layout = new Gemini.FullscreenLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 0);

  /* adding the second one, first still needs to be fullscreen */
  assert (layout.size == 2);
}

void test_layout_grab_focus () {
  var layout = new Gemini.FullscreenLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 0);

  /* grab the focus of the current terminal */
  layout.terminal_grab_focus (terminal1);

  /* grab the focus of a hidden terminal */
  layout.terminal_grab_focus (terminal2);

  /* grab the focus of a non existing terminal */
  layout.terminal_grab_focus (new Terminal ());

  /* grab the focus of the first one again */
  layout.terminal_grab_focus (terminal1);
}

void test_layout_remove () {
  var layout = new Gemini.FullscreenLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 1);
  layout.terminal_add (terminal3, 2);

  /* remove the active terminal */
  layout.terminal_remove (terminal1);
  assert (layout.size == 2);

  /* remove a not active terminal */
  layout.terminal_remove (terminal3);

  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal3, 0);

  /* move the terminals around */
  layout.terminal_move (terminal1, 0);
  layout.terminal_move (terminal3, 2);

  layout.terminal_remove (terminal2);
}

void test_layout_all_terminals_remove () {
  var layout = new Gemini.FullscreenLayout ();

  layout.terminal_add (new Terminal (), 0);
  layout.terminal_add (new Terminal (), 0);
  layout.terminal_add (new Terminal (), 0);
  layout.terminal_add (new Terminal (), 0);

  layout.all_terminals_remove ();
}

void test_visible_true () {
  var layout = new FullscreenLayout ();

  var t1 = new Terminal ();
  var t2 = new Terminal ();
  var t3 = new Terminal ();
  var t4 = new Terminal ();

  layout.terminal_add (t1, 0);
  layout.terminal_add (t2, 0);
  layout.terminal_add (t3, 0);
  layout.terminal_add (t4, 0);

  assert (t1.visible == true);
  assert (t2.visible == false);
  assert (t3.visible == false);
  assert (t4.visible == false);
}

void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func ("/Gemini/Layout/Fullscreen/Create", test_layout_create);
  Test.add_func ("/Gemini/Layout/Fullscreen/Add1", test_layout_add_1);
  Test.add_func ("/Gemini/Layout/Fullscreen/Add2", test_layout_add_2);
  Test.add_func ("/Gemini/Layout/Fullscreen/GrabFocus", test_layout_grab_focus);
  Test.add_func ("/Gemini/Layout/Fullscreen/Remove", test_layout_remove);
  Test.add_func ("/Gemini/Layout/Fullscreen/AllTerminalsRemove", test_layout_all_terminals_remove);
  Test.add_func ("/Gemini/Layout/Fullscreen/Visible", test_visible_true);

  Test.run ();
}
