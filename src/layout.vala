using Gtk;
using GLib;

namespace Gemini {
  public interface Layout : GLib.Object {
    public abstract void add_new_terminal ();
    public signal bool key_press_event (Gdk.EventKey event);
    /* ADD a signal for all exited */
  }
}
