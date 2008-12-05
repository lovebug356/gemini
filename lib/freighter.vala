using GLib;
using Gee;

namespace Gemini {
  public class Freighter : GLib.Object {
    ArrayList<Gemini.Terminal> terminals;
    ArrayList<Gemini.Hauler> haulers;
    public Gemini.Hauler active_hauler;

    public signal void hauler_change ();

    construct {
      terminals = new ArrayList<Gemini.Terminal> ();
      haulers = new ArrayList<Gemini.Hauler> ();
      active_hauler = null;
    }

    public int size {
      get {return haulers.size;}
    }

    public void hauler_new (GLib.Type layout_type) {
      lock (haulers) {
        var hauler = new Gemini.Hauler (layout_type);
        haulers.add (hauler);
        if (active_hauler == null) {
          hauler_show (hauler);
        }
      }
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

        if (hauler == null && haulers.size > 0)
          hauler_2 = haulers.get (0);
        else
          hauler_2 = hauler;

        if (hauler_2 != active_hauler) {
          if (active_hauler != null)
            active_hauler.visible = false;
          active_hauler = hauler_2;
          if (active_hauler != null)
            active_hauler.visible = true;
          hauler_change ();
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
  }
}
