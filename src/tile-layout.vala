using Gtk;
using GLib;

namespace Gemini {
  public class TileLayout : Gtk.HBox, Gemini.Layout {

    Gemini.Terminal zoom_terminal;
    Gemini.TileBox tile_box;
    int tile_width;

    construct {
      set_homogeneous (false);
      zoom_terminal = null;
      tile_box = new Gemini.TileBox ();
      tile_width = 200;
      pack_end (tile_box, false, false, 0);
      tile_box.set_size_request (0, 0);
      show_all ();
    }

    bool terminal_key_press_event_cb (Gemini.Terminal terminal, Gdk.EventKey key) {
      return key_press_event (key);
    }

    public int length () {
      return tile_box.get_length () + 1;
    }

    public void terminal_resize (int delta_x, int delta_y) {
      tile_width += delta_x;
      if (tile_width < 0)
        tile_width = 0;
      tile_box.set_size_request ((length () > 1 ? tile_width : 0), 0);
    }

    void terminal_child_exited_cb (Gemini.Terminal terminal) {
      if (terminal == zoom_terminal) {
        remove (terminal);
        Gemini.Terminal new_terminal;
        new_terminal = tile_box.remove_first_terminal ();
        if (new_terminal == null) {
          all_childs_exited ();
        } else {
          zoom_terminal = new_terminal;
          pack_end (zoom_terminal, true, true, 0);
          zoom_terminal.grab_focus ();
        }
      } else {
        tile_box.remove (terminal);
        zoom_terminal.grab_focus ();
      }
      terminal_resize (0, 0);
    }

    void set_zoom_ontop_off_tile () {
      remove (zoom_terminal);
      tile_box.add_terminal (zoom_terminal, true);
      tile_box.set_size_request (tile_width, 0);
      zoom_terminal = null;
    }

    public void add_new_terminal () {
      if (zoom_terminal != null)
        set_zoom_ontop_off_tile ();
      var terminal = new Gemini.Terminal ();
      terminal.key_press_event += terminal_key_press_event_cb;
      terminal.child_exited += terminal_child_exited_cb;
      zoom_terminal = terminal;
      pack_end (zoom_terminal, true, true, 0);
      zoom_terminal.grab_focus ();
    }

    public void zoom () {
      if (length () <=1)
        return;

      Gemini.Terminal terminal;
      terminal = tile_box.remove_first_terminal ();
      remove (zoom_terminal);
      tile_box.add_terminal (zoom_terminal, true);
      zoom_terminal = terminal;
      pack_end (zoom_terminal, true, true, 0);
      zoom_terminal.grab_focus ();
    }

    public void close_current_terminal () {
      Gemini.Terminal terminal = null;

      if (zoom_terminal.is_focus) {
        terminal = zoom_terminal;
      } else {
      }

      if (terminal != null) {
        terminal_child_exited_cb (terminal);
        terminal.destroy ();
      }
    }
  }
}
