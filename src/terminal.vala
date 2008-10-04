using Gtk;
using GLib;

namespace Gemini {
  public class Terminal : Vte.Terminal {
    construct {
      set_size_request (0, 0);
      set_size (80, 24);
      show ();
      fork_command (null, null, null, null, false, false, false);
    }
  }
}
