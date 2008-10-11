using Gtk;
using GLib;

namespace Gemini {
  public class FullscreenLayout : Gemini.Layout {
    Gtk.Box layout_box;
    Gemini.Terminal active_terminal;

    construct {
      name = "fullscreen";
      layout_widget = (Gtk.Widget) new Gtk.HBox (false, 0);
      layout_box = (Gtk.Box) layout_widget;
      layout_box.show_all ();
      active_terminal = null;
    }

    protected override void terminal_resize (Gemini.Terminal terminal, int delta_x, int delta_y) {
      /* nothing todo in fullscreen */
    }

    protected override void terminal_new_widget (Gemini.Terminal terminal) {
      layout_box.pack_start (terminal, true, true, 0);
      terminal_focus (terminal);
    }

    protected override void terminal_focus (Gemini.Terminal terminal) {
      if (terminal != active_terminal) {
        if (active_terminal != null)
          active_terminal.hide ();
        active_terminal = terminal;
        active_terminal.show ();
        active_terminal.grab_focus ();
      }
    }

    protected override void focus_next (Gemini.Terminal terminal) {
      int position = terminal_list.index_of (terminal);
      int next_position = (position < terminal_list.size -1 ? position + 1 : 0);
      terminal_focus (terminal_list.get (next_position));
    }

    protected override void terminal_zoom (Gemini.Terminal terminal) {
      /* don't zoom yet */
    }

    protected override void terminal_remove_widget (Gemini.Terminal terminal) {
      layout_box.remove (terminal);
      if (terminal_list.size == 0) {
        all_terminals_exited ();
        return;
      }
      terminal_focus (terminal_list.get (0));
    }

    protected override void remove_widgets () {
      foreach (Gemini.Terminal terminal in terminal_list) {
        layout_box.remove (terminal);
      }
      active_terminal = null;
    }
  }
}
