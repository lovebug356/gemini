using Gtk;
using GLib;

namespace Gemini {
  public interface Layout : GLib.Object {
    public abstract void add_new_terminal ();
    public abstract void close_terminal ();
    public abstract void terminal_resize (int delta_x, int delta_y);
    public abstract void zoom ();
    public abstract int length ();
    public abstract void set_focus_next ();
    public abstract void set_fullscreen_mode (bool mode);
    /* ADD a signal for all exited */
    public signal bool key_press_event (Gdk.EventKey event);
    public signal void all_childs_exited ();
  }
}
