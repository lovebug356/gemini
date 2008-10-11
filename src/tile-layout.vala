using Gtk;
using GLib;

namespace Gemini {
  public class TileLayout : Gemini.Layout {
    Gemini.Terminal zoom_terminal;
    Gemini.TileBox tile_box;
    int tile_width;
    Gtk.Box layout_box;

    construct {
      name = "tile";
      layout_widget = (Gtk.Widget) new Gtk.HBox (false, 0);
      layout_box = (Gtk.Box) layout_widget;
      layout_box.set_homogeneous (false);
      zoom_terminal = null;
      tile_box = new Gemini.TileBox ();
      tile_width = 200;
      layout_box.pack_end (tile_box, false, false, 0);
      tile_box.set_size_request (0, 0);
      layout_box.show_all ();
    }

    void set_zoom_ontop_off_tile () {
      layout_box.remove (zoom_terminal);
      tile_box.add_terminal (zoom_terminal, true);
      zoom_terminal = null;
      resize (0, 0);
    }

    void resize (int delta_x, int delta_y) {
      tile_width += delta_x;
      if (tile_width < 0)
        tile_width = 0;
      tile_box.set_size_request ((terminal_list.size > 1 ? tile_width : 0), 0);
    }

    protected override void remove_widgets () {
      tile_box.remove_all_terminals ();
      layout_box.remove (tile_box);
      layout_box.remove (zoom_terminal);
    }

    protected override void terminal_resize (Gemini.Terminal terminal, int delta_x, int delta_y) {
      resize (-delta_x, delta_y);
    }

    protected override void terminal_focus (Gemini.Terminal terminal) {
      terminal.grab_focus ();
    }

    protected override void terminal_new_widget (Gemini.Terminal terminal) {
      if (zoom_terminal != null)
        set_zoom_ontop_off_tile ();
      zoom_terminal = terminal;
      layout_box.pack_end (zoom_terminal, true, true, 0);
      zoom_terminal.grab_focus ();
    }

    protected override void focus_next (Gemini.Terminal terminal) {
      if (zoom_terminal == terminal) {
        tile_box.set_focus_first ();
      } else if (!tile_box.set_focus_next ()) {
        zoom_terminal.grab_focus ();
      }
    }

    protected override void terminal_zoom (Gemini.Terminal terminal) {
      if (zoom_terminal != terminal) {
        terminal_remove_widget (terminal);
        terminal_new_widget (terminal);
      } else {
        var top_terminal = tile_box.remove_first_terminal ();
        if (top_terminal != null) {
          terminal_new_widget (top_terminal);
        }
      }
    }

    protected override void terminal_remove_widget (Gemini.Terminal terminal) {
      if (zoom_terminal == terminal) {
        layout_box.remove (terminal);
        zoom_terminal = tile_box.remove_first_terminal ();
        if (zoom_terminal == null)
        {
          all_terminals_exited ();
          return;
        }
        layout_box.pack_start(zoom_terminal, true, true, 0);
      } else {
        tile_box.remove_terminal (terminal);
      }
      resize (0, 0);
      zoom_terminal.grab_focus ();
    }
  }
}
