using Gtk;
using GLib;
using Gee;

namespace Gemini {

  public class Layout : GLib.Object {
    public ArrayList<Gemini.Terminal> terminal_list = new ArrayList<Gemini.Terminal> ();
    public Gtk.Widget layout_widget;
    public string name;
    Gemini.Terminal last_terminal = null;

    public signal void size_changed (int new_size);
    public signal void all_terminals_exited ();

    public void terminal_add (Gemini.Terminal terminal) {
      lock (terminal_list) {
        terminal_list.insert (0, terminal);
        terminal.show (); /* some layout's hide them */
        virt_terminal_new_widget (terminal);
        size_changed (terminal_list.size);
      }
    }

    public void terminal_last_focus (Gemini.Terminal terminal) {
      lock (terminal_list) {
        last_terminal = terminal;
      }
    }

    public void terminal_list_add (ArrayList<Gemini.Terminal> new_terminal_list) {
      lock (terminal_list) {
        for (int i=new_terminal_list.size;i > 0; i--)
          terminal_add (new_terminal_list.get (i-1));
      }
    }

    public void terminal_close (Gemini.Terminal terminal) {
      lock (terminal_list) {
        if (terminal in terminal_list) {
          terminal_list.remove (terminal);
          virt_terminal_remove_widget (terminal);
          size_changed (terminal_list.size);
        } else {
          warning ("trying to remove a terminal that is not in this layout");
        }
      }
    }

    public void terminal_focus_back () {
      lock (terminal_list) {
        if (terminal_list.size > 1) {
          if (last_terminal == null || !terminal_list.contains (last_terminal)) {
            if (get_active_terminal () == terminal_list.get(0))
              last_terminal = terminal_list.get (1);
            else
              last_terminal = terminal_list.get (0);
          }
          terminal_focus (last_terminal);
        }
      }
    }

    public virtual void terminal_focus (Gemini.Terminal terminal) {
      virt_terminal_focus (terminal);
    }

    public virtual void virt_terminal_focus (Gemini.Terminal terminal) {
      message ("implement me");
    }

    public void terminal_focus_next (Gemini.Terminal terminal) {
      if (terminal_list.size > 1) {
        virt_terminal_focus_next (terminal);
      }
    }

    protected virtual void virt_terminal_focus_next (Gemini.Terminal terminal) {
      message ("implement me");
    }

    protected virtual void virt_terminal_new_widget (Gemini.Terminal terminal) {
      message ("implement me");
    }

    protected virtual void virt_terminal_remove_widget (Gemini.Terminal terminal) {
      message ("implement me");
    }

    protected virtual void virt_terminal_resize (Gemini.Terminal terminal, int delta_x, int delta_y) {
      message ("implement me");
    }

    protected virtual void virt_terminal_zoom (Gemini.Terminal terminal) {
      message ("implement me");
    }

    protected virtual void virt_remove_widgets () {
      message ("implement me");
    }

    protected Gemini.Terminal? get_active_terminal () {
      Gemini.Terminal temp = null;
      lock (terminal_list) {
        foreach (Gemini.Terminal terminal in terminal_list) {
          if (terminal.is_focus) {
            temp = terminal;
          }
        }
      }
      return temp;
    }
  }
}
