using Gtk;
using GLib;

namespace Gemini {
  public class Terminal : Vte.Terminal {

    public signal void selection (bool active);

    construct {
      set_size_request (0, 0);
      set_size (80, 24);
      show ();
      fork_command (null, null, null, null, false, false, false);
      button_release_event += button_release_event_cb;
    }

    ~Terminal () {
      message ("Im duing");
    }

    bool button_release_event_cb (Gemini.Terminal terminal, Gdk.EventButton button) {
      if (button.type == Gdk.EventType.BUTTON_RELEASE &&
          button.button == 1) {
        selection (get_has_selection ());
      }
      return false;
    }
  }
}
