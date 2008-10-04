using Gtk;
using GLib;

namespace Gemini {
  public class Window : Gtk.Window {
    construct {
      set_title ("Gemini Terminal");
      var terminal = new Gemini.Terminal ();
      terminal.child_exited += Gtk.main_quit;
      add (terminal);
      destroy += Gtk.main_quit;
    }
  }
  
  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.Window ();
    gemini.show ();
    Gtk.main ();
  }
}
