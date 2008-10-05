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

    public int length () {
      weak List list = get_children ();
      return (int) list.length ();
    }

    Gemini.Terminal? get_first_child () {
      weak List list = get_children ();
      if (list.length () <= 0)
        return null;
      return (Gemini.Terminal) list.nth_data (0);
    }

    void set_focus_on_first_child () {
      var terminal = get_first_child ();
      set_focus_child (terminal);
      terminal.grab_focus ();
    }

    void terminal_child_exited_cb (Gemini.Terminal terminal) {
      remove (terminal);
      if (length () > 0)
        set_focus_on_first_child ();
      else
        all_childs_exited ();
    }

    public void add_new_terminal () {
      var terminal = new Gemini.Terminal ();
      terminal.key_press_event += terminal_key_press_event_cb;
      terminal.child_exited += terminal_child_exited_cb;
      pack_start (terminal, true, true, 0);
    }

    public void close_current_terminal () {
      weak List<Gemini.Terminal> list = get_children ();
      Gemini.Terminal terminal = null;

      foreach (Gemini.Terminal term in list) {
        if (term.is_focus) {
          terminal = term;
        }
      }
      if (terminal != null) {
        terminal_child_exited_cb (terminal);
        terminal.destroy ();
      }
    }
  }
}
