using GLib;

namespace Gemini {
  public class TileBox : Gtk.VBox {
    construct {
    }

    public void remove_terminal (Gemini.Terminal terminal) {
      remove (terminal);
    }

    public int get_length () {
      weak List<Gemini.Terminal> list = get_children ();
      return (int) list.length ();
    }

    public void add_terminal (Gemini.Terminal terminal, bool on_top) {
      if (on_top)
        pack_end (terminal, true, true, 0);
      else
        pack_start (terminal, true, true, 0);
    }

    public void set_focus_first () {
      Gemini.Terminal terminal;
      int length = get_length ();

      weak List<Gemini.Terminal> list = get_children ();

      if (length >= 1) {
        terminal = list.nth_data (0);
        terminal.grab_focus ();
      }
    }

    public bool set_focus_next () {
      Gemini.Terminal terminal;
      int length = get_length ();
      bool found = false;
      bool next_focus = false;
      weak List<Gemini.Terminal> list = get_children ();

      foreach (Gemini.Terminal term in list) {
        if (!found) {
          if (next_focus) {
            term.grab_focus ();
            found = true;
          } else if (term.is_focus) {
            next_focus = true;
          }
        }
      }
      return found;
    }

    public Gemini.Terminal? get_first_terminal () {
      Gemini.Terminal terminal;
      weak List<Gemini.Terminal> list = get_children ();

      if (list.length () == 0)
        return null;

      return list.nth_data (0);
    }

    public Gemini.Terminal? remove_first_terminal () {
      Gemini.Terminal terminal;
      terminal = get_first_terminal ();

      if (terminal == null)
        return null;

      remove (terminal);
      return terminal;
    }
  }
}
