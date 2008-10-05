using Gtk;
using GLib;

namespace Gemini {
  public interface Layout : GLib.Object {
    public abstract void add_new_terminal ();
    public abstract int length ();
    /* ADD a signal for all exited */
    public signal bool key_press_event (Gdk.EventKey event);
    public signal void all_childs_exited ();
  }
}
