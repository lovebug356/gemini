using Gtk;
using GLib;

namespace Gemini {
  public class Window : Gtk.Window {
    UIManager ui_manager;
    ActionGroup menu_actions;
    bool is_fullscreen;

    Gemini.Layout layout;

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

    bool terminal_key_press_event (Gemini.Layout layout, Gdk.EventKey event_key) {
      bool valid = false;
      if ((event_key.state & Gdk.ModifierType.MOD1_MASK) == Gdk.ModifierType.MOD1_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "Return":
            layout.set_focus_next ();
            valid = true;
            break;
          default:
            break;
        }
      }
      if ((event_key.state & Gdk.ModifierType.MOD4_MASK) == Gdk.ModifierType.MOD4_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "o":
            layout.add_new_terminal ();
            valid = true;
            break;
          case "Return":
            layout.zoom ();
            valid = true;
            break;
          case "x":
            layout.close_terminal ();
            valid = true;
            break;
          case "j":
            layout.terminal_resize (30, 0);
            valid = true;
            break;
          case "k":
            layout.terminal_resize (-30, 0);
            valid = true;
            break;
          default:
            break;
        }
      }
      if (valid)
        return true;
      return false;
    }

    void fullscreen_f11_action_cb (Gtk.Action action) {
      if (is_fullscreen)
        unfullscreen ();
      else
        fullscreen ();
      is_fullscreen = !is_fullscreen;
    }

    void quit_action_cb (Gemini.Layout layout) {
      Gtk.main_quit ();
    }

    construct {
      set_title ("Gemini Terminal");
      is_fullscreen = false;

      layout = new Gemini.TileLayout ();
      layout.add_new_terminal ();
      layout.key_press_event += terminal_key_press_event;
      layout.all_childs_exited += quit_action_cb;
      add ((Gtk.Widget) layout);

      destroy += Gtk.main_quit;
      setup_ui_manager ();

      set_default_size (640, 480);
      show ();
    }
  }
  
  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.Window ();
    Gtk.main ();
  }
}
