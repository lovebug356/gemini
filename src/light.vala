using Gtk;
using GLib;

namespace Gemini {
  public class GeminiLight : Gtk.Window {
    construct {
      /* Load the configuration */
      Gemini.configuration = new Gemini.Configuration ();
      set_default_size (640, 480);
      destroy += Gtk.main_quit;
      var t = new Gemini.Terminal ();
      t.window_title_changed += (term) => {
        Gtk.Window toplevel = (Gtk.Window) get_toplevel(); toplevel.set_title( term.window_title );
      };
      t.child_exited += Gtk.main_quit;
      add (t);
      show ();
    }
  }

  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.GeminiLight ();
    Gtk.main ();
  }
}
