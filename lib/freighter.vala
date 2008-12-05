using GLib;
using Gee;

namespace Gemini {
  public class Freighter : GLib.Object {
    ArrayList<Gemini.Terminal> terminals;
    ArrayList<Gemini.Hauler> haulers;
    public Gemini.Hauler active_hauler;

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
        if (active_hauler == null)
          active_hauler = hauler;
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
          if (haulers.size > 0)
            active_hauler = haulers.get (0);
          else
            active_hauler = null;
        }
      }
    }
  }
}
