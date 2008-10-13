using Gtk;
using GLib;

namespace Gemini {
  public class Window : Gtk.Window {
    UIManager ui_manager;
    ActionGroup menu_actions;
    bool is_fullscreen;
    Gtk.VBox vbox;

    Gemini.Layout layout;

    const ActionEntry[] action_entries = {
      {"Terminal",      null,       "_Terminal",  null,   null, null},
      {"NewTerminal",   null,       "_New",       "<control>o",   null, new_terminal_action_cb},
      {"CloseTerminal", null,       "_Close terminal", "<control>x", null, close_terminal_action_cb},
      {"Quit",          STOCK_QUIT, "_Quit",      null,   null, quit_action_cb},

      {"View",          null,       "_View",      null,   null, null},
      {"FocusNextTerminal", null,   "Focus _next terminal", "<control>n", null, focus_next_terminal_action_cb},
      {"FocusLastTerminal", null,   "Focus _last terminal", "<control>b", null, focus_last_terminal_action_cb},

      {"Help",          null,               "_Help",          null,   null, null},
      {"About",         STOCK_ABOUT,        "_About",         null,   null, about_action_cb},

      {"FullscreenF11", null,       null,         "F11",  null, fullscreen_f11_action_cb}
    };

    static const string MAIN_UI = """
      <ui>
        <menubar name="MenuBar">
          <menu action="Terminal">
            <menuitem action ="NewTerminal" />
            <menuitem action ="CloseTerminal" />
            <separator />
            <menuitem action ="Quit" />
          </menu>
          <menu action="View">
            <menuitem action="FocusNextTerminal" />
            <menuitem action="FocusLastTerminal" />
          </menu>
          <menu action="Help">
            <menuitem action="About" />
          </menu>
        </menubar>
        <accelerator action="FullscreenF11" />
      </ui>
    """;

    void about_action_cb (Gtk.Action action) {
      var dialog = new AboutDialog ();
      dialog.set_copyright ("Copyright (c) 2008 Thijs Vermeir");
      dialog.set_program_name ("Gemini Terminal");
      dialog.set_version ("0.3.0");
      dialog.set_website ("http://lovebug356.blogspot.com");
      dialog.run ();
      dialog.hide ();
      dialog.destroy ();
    }

    void focus_next_terminal_action_cb (Gtk.Action action) {
      lock (layout) {
        layout.terminal_focus_next (layout.get_active_terminal ());
      }
    }

    void focus_last_terminal_action_cb (Gtk.Action action) {
      lock (layout) {
        layout.terminal_focus_back ();
      }
    }

    void new_terminal_action_cb (Gtk.Action action) {
      add_new_terminal ();
    }

    void close_terminal_action_cb (Gtk.Action action) {
      var terminal = layout.get_active_terminal ();
      child_exited_cb (terminal);
    }

    void quit_action_cb (Gtk.Action action) {
      Gtk.main_quit ();
    }

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
      var menubar = ui_manager.get_widget ("/MenuBar");
      vbox.pack_start (menubar, false, false, 0);
      menubar.show_all ();
    }

    bool key_press_event_cb (Gemini.Terminal terminal, Gdk.EventKey event_key) {
      bool valid = true;
      if ((event_key.state & Gdk.ModifierType.MOD1_MASK) == Gdk.ModifierType.MOD1_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "Return":
            layout.terminal_focus_next (terminal);
            break;
          default:
            valid = false;
            break;
        }

      } else if ((event_key.state & Gdk.ModifierType.MOD4_MASK) == Gdk.ModifierType.MOD4_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "o":
            add_new_terminal ();
            break;
          case "Return":
            layout.virt_terminal_zoom (terminal);
            break;
          case "x":
            layout.terminal_close (terminal);
            break;
          case "l":
            layout.virt_terminal_resize (terminal, 30, 0);
            break;
          case "h":
            layout.virt_terminal_resize (terminal, -30, 0);
            break;
          case "j":
            layout.virt_terminal_resize (terminal, 0, -30);
            break;
          case "k":
            layout.virt_terminal_resize (terminal, 0, 30);
            break;
          case "f":
            change_layout (typeof (FullscreenLayout));
            layout.virt_terminal_focus (terminal);
            break;
          case "space":
            change_layout (typeof (TileLayout));
            layout.virt_terminal_focus (terminal);
            break;
          case "b":
            layout.terminal_focus_back ();
            break;
          default:
            valid = false;
            break;
        }
      } else
        valid = false;
      return valid;
    }

    void change_layout (GLib.Type new_layout_type) {
      lock (layout) {
        if (layout == null || layout.get_type () != new_layout_type) {
          Layout old_layout;
          old_layout = layout;
          switch (new_layout_type) {
            case typeof (FullscreenLayout):
              layout = new FullscreenLayout ();
              break;
            case typeof (TileLayout):
              layout = new TileLayout ();
              break;
            default:
              warning ("Didn't recognize the requested layout type");
              break;
          }

          /* connect the signals */
          layout.all_terminals_exited += all_terminals_exited_cb;
          layout.size_changed += (lay, size) => size_changed_cb (size);

          if (old_layout != null) {
            old_layout.virt_remove_widgets ();
            vbox.remove (old_layout.layout_widget);
            vbox.pack_start (layout.layout_widget, true, true, 0);
            layout.terminal_list_add (old_layout.terminal_list);
          } else {
            vbox.pack_start (layout.layout_widget, true, true, 0);
          }
        }
      }
    }

    void child_exited_cb (Gemini.Terminal terminal) {
      lock (layout) {
        layout.terminal_close (terminal);
      }
    }

    void size_changed_cb (int size) {
      lock (layout) {
        set_title ("Gemini Terminal [%s-%dT]".printf (layout.name, size));
      }
    }

    void fullscreen_f11_action_cb (Gtk.Action action) {
      if (is_fullscreen)
        unfullscreen ();
      else
        fullscreen ();
      is_fullscreen = !is_fullscreen;
    }

    bool focus_out_event (Gemini.Terminal terminal, Gdk.EventFocus event) {
      lock (layout) {
        layout.terminal_last_focus (terminal);
      }
      return false;
    }

    void add_new_terminal () {
      lock (layout) {
        Gemini.Terminal terminal = new Gemini.Terminal ();
        terminal.key_press_event += key_press_event_cb;
        terminal.child_exited += child_exited_cb;
        terminal.focus_out_event += focus_out_event;
        layout.terminal_add (terminal);
      }
    }

    void all_terminals_exited_cb (Gemini.Layout layout) {
      Gtk.main_quit ();
    }

    construct {
      is_fullscreen = false;
      vbox = new Gtk.VBox (false, 0);
      add (vbox);
      vbox.show ();

      setup_ui_manager ();
      change_layout (typeof (Gemini.TileLayout));
      add_new_terminal ();
      destroy += Gtk.main_quit;

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
