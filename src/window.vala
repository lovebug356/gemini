using Gtk;
using GLib;

namespace Gemini {
  public class Window : Gtk.Window {
    UIManager ui_manager;
    ActionGroup menu_actions;
    Gtk.VBox vbox;
    Gtk.Widget menubar;
    Gtk.Menu popup_menu;
    Gdk.Pixbuf gemini_logo;

    Gemini.Layout layout;

    ToggleAction fullscreen_action;
    ToggleAction show_menubar_action;

    const ActionEntry[] action_entries = {
      {"File",      null,       "_File",  null,   null, null},
      {"NewTerminal",   null,       "_Open terminal",       "<shift><control>n",   null, new_terminal_action_cb},
      {"CloseTerminal", null,       "_Close terminal", "<shift><control>w", null, close_terminal_action_cb},
      {"Quit",          STOCK_QUIT, "_Quit",      null,   null, quit_action_cb},

      {"Edit",          null,       "_Edit",          null, null, null},
      {"Copy",          STOCK_COPY, "_Copy",          "<shift><control>c", null, copy_action_cb},
      {"Paste",         STOCK_PASTE,"_Paste",         "<shift><control>v", null, paste_action_cb},

      {"View",          null,       "_View",          null, null, null},

      {"Terminal",          null,       "_Terminal",          null, null, null},
      {"FocusNextTerminal", null,   "_Next terminal", "<shift><control>n", null, focus_next_terminal_action_cb},
      {"FocusLastTerminal", null,   "_Last terminal", "<shift><control>b", null, focus_last_terminal_action_cb},
      {"Zoom",              null,   "_Zoom",          "<shift><control>z", null, zoom_action_cb},

      {"Help",          null,               "_Help",          null,   null, null},
      {"About",         STOCK_ABOUT,        "_About",         null,   null, about_action_cb}
    };

    const ToggleActionEntry[] toggle_entries = {
      {"ShowMenubar",   null,       "Show Menu_bar",  "<shift><control>m", null, show_menubar_action_cb, true},
      {"Fullscreen",    null,       "_Full screen",     "F11", null, fullscreen_action_cb, false}
    };

    static const string MAIN_UI = """
      <ui>
        <menubar name="MenuBar">
          <menu action="File">
            <menuitem action ="NewTerminal" />
            <menuitem action ="CloseTerminal" />
            <separator />
            <menuitem action ="Quit" />
          </menu>
          <menu action="Edit">
            <menuitem action="Copy" />
            <menuitem action="Paste" />
          </menu>
          <menu action="View">
            <menuitem action="ShowMenubar" />
            <menuitem action="Fullscreen" />
          </menu>
          <menu action="Terminal">
            <menuitem action="FocusNextTerminal" />
            <menuitem action="FocusLastTerminal" />
            <separator />
            <menuitem action="Zoom" />
          </menu>
          <menu action="Help">
            <menuitem action="About" />
          </menu>
        </menubar>
        <popup name="PopupMenu">
          <menuitem action="Copy" />
          <menuitem action="Paste" />
          <separator />
          <menuitem action="Zoom" />
          <menuitem action="FocusNextTerminal" />
          <menuitem action="FocusLastTerminal" />
          <separator />
          <menuitem action ="NewTerminal" />
          <menuitem action ="CloseTerminal" />
        </popup>
      </ui>
    """;

    void copy_action_cb (Gtk.Action action) {
      lock (layout) {
        layout.get_active_terminal ().copy_clipboard ();
      }
    }

    void paste_action_cb (Gtk.Action action) {
      lock (layout) {
        layout.get_active_terminal ().paste_clipboard ();
      }
    }

    void zoom_action_cb (Gtk.Action action) {
      layout.virt_terminal_zoom (layout.get_active_terminal ());
    }

    void show_menubar_action_cb (Gtk.Action action) {
      if (show_menubar_action.get_active ())
        menubar.show ();
      else
        menubar.hide ();
    }

    void fullscreen_action_cb (Gtk.Action action) {
      if (fullscreen_action.get_active ())
        fullscreen ();
      else
        unfullscreen ();
    }

    void about_action_cb (Gtk.Action action) {
      var dialog = new AboutDialog ();
      dialog.set_logo (gemini_logo);
      dialog.set_icon (gemini_logo);
      dialog.set_copyright ("Copyright (c) 2008 Thijs Vermeir");
      dialog.set_program_name ("Gemini Terminal");
      /* FIXME the version number needs to come from the build system */
      dialog.set_version (Gemini.version);
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
      menu_actions.add_toggle_actions (toggle_entries, this);
      fullscreen_action = (Gtk.ToggleAction) menu_actions.get_action ("Fullscreen");
      show_menubar_action = (Gtk.ToggleAction) menu_actions.get_action ("ShowMenubar");
      ui_manager.insert_action_group (menu_actions, 0);
      try {
        ui_manager.add_ui_from_string (MAIN_UI, MAIN_UI.length);
      } catch (GLib.Error err) {
        warning ("Error while reading the main ui: %s", err.message);
      }
      add_accel_group (ui_manager.get_accel_group ());
      menubar = ui_manager.get_widget ("/MenuBar");
      vbox.pack_start (menubar, false, false, 0);
      menubar.show_all ();
      popup_menu = (Gtk.Menu) ui_manager.get_widget ("/PopupMenu");
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
        terminal.button_press_event += (btn, ev) => {
          if (ev.button == 3) {
            popup_menu.popup (null, null, null, ev.button, ev.time);
            return true;
          }
          return false;
        };
        layout.terminal_add (terminal);
      }
    }

    void all_terminals_exited_cb (Gemini.Layout layout) {
      Gtk.main_quit ();
    }

    construct {
      vbox = new Gtk.VBox (false, 0);
      add (vbox);
      vbox.show ();

      setup_ui_manager ();
      change_layout (typeof (Gemini.TileLayout));
      add_new_terminal ();
      destroy += Gtk.main_quit;

      set_default_size (640, 480);
      string filename = Gemini.File.pixmaps ("gemini.svg");
      try {
        gemini_logo = new Gdk.Pixbuf.from_file (filename);
        set_icon (gemini_logo);
      } catch (Error e) {
        gemini_logo = null;
      }
      show ();
    }
  }

  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.Window ();
    Gtk.main ();
  }
}
