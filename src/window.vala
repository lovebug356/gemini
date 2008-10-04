using Gtk;
using GLib;

namespace Gemini {
  public class Window : Gtk.Window {
    UIManager ui_manager;
    ActionGroup menu_actions;
    bool is_fullscreen;

    const ActionEntry[] action_entries = {
      {"FullscreenF11", null, null, "F11", null, fullscreen_f11_action_cb}
    };

    static const string MAIN_UI = """
      <ui>
        <accelerator action="FullscreenF11" />
      </ui>
    """;

    void setup_ui_manager () {
      ui_manager = new UIManager ();
      menu_actions = new ActionGroup ("Actions");
      menu_actions.add_actions (action_entries, this);
      ui_manager.insert_action_group (menu_actions, 0);
      try {
        ui_manager.add_ui_from_string (MAIN_UI, MAIN_UI.length);
      } catch (GLib.Error err) {
        warning ("Error while reading the main ui: %s", err.message);
      }
      add_accel_group (ui_manager.get_accel_group ());
    }

    void fullscreen_f11_action_cb (Gtk.Action action) {
      if (is_fullscreen)
        unfullscreen ();
      else
        fullscreen ();
      is_fullscreen = !is_fullscreen;
    }

    construct {
      set_title ("Gemini Terminal");
      is_fullscreen = false;

      var terminal = new Gemini.Terminal ();
      terminal.child_exited += Gtk.main_quit;
      add (terminal);
      destroy += Gtk.main_quit;
      setup_ui_manager ();
    }
  }
  
  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.Window ();
    gemini.show ();
    Gtk.main ();
  }
}
