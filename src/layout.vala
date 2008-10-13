using Gtk;
using GLib;
using Gee;

namespace Gemini {

  public class Layout : GLib.Object {
    public ArrayList<Gemini.Terminal> terminal_list = new ArrayList<Gemini.Terminal> ();
    public Gtk.Widget layout_widget;
    public string name;
    Gemini.Terminal last_terminal = null;

    public signal void all_terminals_exited ();

    /* FIXME vala bug */
    private int unused;

    public void terminal_add (Gemini.Terminal terminal) {
      lock (terminal_list) {
        terminal_list.insert (0, terminal);
        terminal.show ();
        terminal_new_widget (terminal);
      }
    }

    public void terminal_last_focus (Gemini.Terminal terminal) {
      lock (last_terminal) {
        last_terminal = terminal;
      }
    }

    public void add_terminal_list (ArrayList<Gemini.Terminal> new_terminal_list) {
      for (int i=new_terminal_list.size;i > 0; i--)
        terminal_add (new_terminal_list.get (i-1));
    }

    public void terminal_close (Gemini.Terminal terminal) {
      lock (terminal_list) {
        if (terminal in terminal_list) {
          terminal_list.remove (terminal);
          terminal_remove_widget (terminal);
        } else {
          warning ("trying to remove a terminal that is not in this layout");
        }
      }
    }

    public void terminal_focus_back () {
      lock (last_terminal) {
        if (last_terminal == null || !terminal_list.containts (last_terminal)) {
          if (get_active_terminal () == terminal_list.get (0))
        }
        terminal_focus (last_terminal);
      }
    }

    public virtual void terminal_focus (Gemini.Terminal terminal) {
      focus (terminal);
    }

    public virtual void focus (Gemini.Terminal terminal) {
      message ("implement me");
    }

    public void terminal_focus_next (Gemini.Terminal terminal) {
      if (terminal_list.size > 1) {
        focus_next (terminal);
      }
    }

    protected virtual void focus_next (Gemini.Terminal terminal) {
      message ("implement me");
    }

    protected virtual void terminal_new_widget (Gemini.Terminal terminal) {
      message ("implement me");
    }

    protected virtual void terminal_remove_widget (Gemini.Terminal terminal) {
      message ("implement me");
    }

    protected virtual void terminal_resize (Gemini.Terminal terminal, int delta_x, int delta_y) {
      message ("implement me");
    }

    protected virtual void terminal_zoom (Gemini.Terminal terminal) {
      message ("implement me");
    }

    protected virtual void remove_widgets () {
      message ("implement me");
    }

    protected virtual Gemini.Terminal? get_active_terminal () {
      Gemini.Terminal temp = null;
      foreach (Gemini.Terminal terminal in terminal_list) {
        if (terminal.is_focus) {
          temp = terminal;
        }
      }
      return temp;
    }
  }
}
