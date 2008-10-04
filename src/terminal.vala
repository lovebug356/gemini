using Gtk;
using GLib;

namespace Gemini {
  public class Terminal : Vte.Terminal {
    construct {
      fork_command (null, null, null, null, false, false, false);
      show ();
    }
  }
}
