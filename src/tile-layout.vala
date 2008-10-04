using Gtk;
using GLib;

namespace Gemini {
  public class TileLayout : Gtk.VBox, Gemini.Layout {

    construct {
      show ();
    }

    bool terminal_key_press_event_cb (Gemini.Terminal terminal, Gdk.EventKey key) {
      return key_press_event (key);
    }

    public void add_new_terminal () {
      var terminal = new Gemini.Terminal ();
      terminal.key_press_event += terminal_key_press_event_cb;
      pack_start (terminal, true, true, 0);
    }
  }
}
