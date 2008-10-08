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

    bool key_press_event_cb (Gemini.Terminal terminal, Gdk.EventKey event_key) {
      bool valid = false;
      if ((event_key.state & Gdk.ModifierType.MOD1_MASK) == Gdk.ModifierType.MOD1_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "Return":
            layout.terminal_focus_next (terminal);
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
            add_new_terminal ();
            valid = true;
            break;
          case "Return":
            layout.terminal_zoom (terminal);
            valid = true;
            break;
          case "x":
            layout.terminal_close (terminal);
            valid = true;
            break;
          case "l":
            layout.terminal_resize (terminal, 30, 0);
            valid = true;
            break;
          case "h":
            layout.terminal_resize (terminal, -30, 0);
            valid = true;
            break;
          case "f":
            change_layout (new FullscreenLayout ());
            terminal.grab_focus ();
            valid =true;
            break;
          case "space":
            change_layout (new TileLayout ());
            terminal.grab_focus ();
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

    void change_layout (Gemini.Layout new_layout) {
      if (layout != null) {
        layout.remove_widgets ();
        remove (layout.layout_widget);
        new_layout.add_terminal_list (layout.terminal_list);
      }
      add (new_layout.layout_widget);
      layout = new_layout;
      layout.all_terminals_exited += all_terminals_exited_cb;
      set_title ("Gemini Terminal [%s]".printf (layout.name));
    }

    void child_exited_cb (Gemini.Terminal terminal) {
      layout.terminal_close (terminal);
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

    void add_new_terminal () {
      Gemini.Terminal terminal = new Gemini.Terminal ();
      terminal.key_press_event += key_press_event_cb;
      terminal.child_exited += child_exited_cb;
      layout.terminal_add (terminal);
    }

    void all_terminals_exited_cb (Gemini.Layout layout) {
      Gtk.main_quit ();
    }

    construct {
      is_fullscreen = false;

      change_layout (new Gemini.TileLayout ());
      add_new_terminal ();
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
