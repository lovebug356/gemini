using GLib;
using Gee;

namespace Gemini {
  public class Freighter : GLib.Object {
    ArrayList<Gemini.Terminal> terminals;
    ArrayList<Gemini.Hauler> haulers;
    public Gemini.Hauler active_hauler;

    public signal void hauler_change ();
    public signal void all_terminals_exited ();

    construct {
      terminals = new ArrayList<Gemini.Terminal> ();
      haulers = new ArrayList<Gemini.Hauler> ();
      active_hauler = null;
    }

    public int size {
      get {return haulers.size;}
    }

    public int terminal_size {
      get {return terminals.size;}
    }

    public void hauler_new (GLib.Type layout_type) {
      lock (haulers) {
        hauler_add (new Gemini.Hauler (layout_type));
      }
    }

    public void hauler_add (Gemini.Hauler hauler) {
      lock (haulers) {
        haulers.add (hauler);
        hauler.all_terminals_exited += hauler_all_terminals_exited_cb;
        if (active_hauler == null) {
          hauler_show (hauler);
        }
      }
    }

    public void hauler_all_terminals_exited_cb (Gemini.Hauler h) {
      hauler_remove (h);
    }

    public Gemini.Hauler? hauler_get (uint position) {
      Gemini.Hauler hauler = null;
      lock (haulers) {
        if (position < haulers.size) {
          hauler = haulers.get ((int)position);
        }
      }
      return hauler;
    }

    public void hauler_remove (Gemini.Hauler hauler) {
      lock (haulers) {
        if (hauler in haulers)
          haulers.remove (hauler);

        if (active_hauler == hauler) {
          active_hauler.visible = false;
          active_hauler = null;
          hauler_show (null);
        }
      }
    }

    public void hauler_move (Gemini.Hauler hauler, int new_position) {
      lock (haulers) {
        haulers.remove (hauler);
        haulers.insert (new_position, hauler);
      }
    }

    public void hauler_show (Gemini.Hauler? hauler) {
      lock (haulers) {
        Gemini.Hauler hauler_2;

        if (hauler == null && haulers.size > 0 && active_hauler == null)
          hauler_2 = haulers.get (0);
        else
          hauler_2 = hauler;

        if (hauler_2 != active_hauler) {
          if (active_hauler != null)
            active_hauler.visible = false;
          active_hauler = hauler_2;
          hauler_change ();
          if (active_hauler != null)
            active_hauler.visible = true;
        }
      }
    }

    public void terminal_add (Gemini.Terminal terminal) {
      lock (haulers) {
        if (!(terminal in terminals))
          terminals.add (terminal);
        active_hauler.terminal_add (terminal, 0);
      }
    }

    public void terminal_remove (Gemini.Terminal terminal) {
      lock (haulers) {
        ArrayList<Gemini.Hauler> empty_haulers = new ArrayList<Gemini.Hauler> ();
        terminals.remove (terminal);
        foreach (Hauler h in haulers) {
          if (terminal in h.terminals) {
            if (h.size == 1)
              empty_haulers.add (h);
            else
              h.terminal_remove (terminal);
          }
        }

        foreach (Hauler h in empty_haulers)
          h.terminal_remove (terminal);

        if (terminals.size == 0)
          all_terminals_exited ();
      }
    }

    public void terminal_close (Gemini.Terminal terminal) {
      lock (haulers) {

        bool more = false;
        foreach (Hauler h in haulers) {
          if (h != active_hauler && h.terminal_get_position (terminal) != -1) {
            more = true;
            break;
          }
        }

        if (!more)
          terminals.remove (terminal);

        active_hauler.terminal_remove (terminal);

        if (terminals.size == 0)
          all_terminals_exited ();
      }
    }
  }
}
