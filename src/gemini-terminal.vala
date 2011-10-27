using Gtk;
using GLib;

namespace Gemini {
  public class GeminiTile : Gtk.Window {
    /* menu stuff */
    UIManager ui_manager;
    Gtk.ActionGroup menu_actions;
    Gtk.Widget menu_bar;
    ToggleAction fullscreen_action;
    ToggleAction statusbar_action;
    ToggleAction menubar_action;

    Gemini.Freighter freighter;
    Gdk.Pixbuf gemini_logo;

    static const string MAIN_UI = """
      <ui>
        <menubar name="MenuBar">
          <menu action="Terminal">
            <menuitem action="TerminalNew" />
            <menuitem action="TerminalClose" />
            <separator />
            <menuitem action="Quit" />
          </menu>
          <menu action="View">
            <menuitem action="Statusbar" />
            <menuitem action="Menubar" />
            <menuitem action="Fullscreen" />
          </menu>
          <menu action="Help">
            <menuitem action="About" />
          </menu>
        </menubar>
      </ui>
    """;

    const Gtk.ActionEntry[] action_entries = {
      {"Terminal", null, "_Terminal", null, null, null},
      {"TerminalNew", null, "_New Terminal", null, null, terminal_new_cb},
      {"TerminalClose", null, "_Close Terminal", null, null, terminal_close_cb},

      {"View", null, "_View", null, null, null},

      {"Help", null, "H_elp", null, null, null},
      {"About", STOCK_ABOUT, "_About", null, null, about_action_cb},

      {"Quit", null, "_Quit", null, null, quit_action_cb}
    };

    const ToggleActionEntry[] toggle_entries = {
      {"Statusbar", null, "_Statusbar", null, null, statusbar_action_cb, true},
      {"Menubar", null, "_Menubar", null, null, menubar_action_cb, true},
      {"Fullscreen", null, "_Full screen", "F11", null, fullscreen_action_cb, false}
    };

    void quit_action_cb (Gtk.Action action) {
      delete_cb ();
    }

    void terminal_new_cb (Gtk.Action action) {
      terminal_new ();
    }

    void terminal_close_cb (Gtk.Action action) {
      lock (freighter) {
        freighter.terminal_close (freighter.active_hauler.terminal_get_focus ());
      }
    }

    void fullscreen_action_cb (Gtk.Action action) {
      if (fullscreen_action.get_active ())
        fullscreen ();
      else
        unfullscreen ();
    }

    void statusbar_action_cb (Gtk.Action action) {
      freighter.statusbar_visible = statusbar_action.get_active ();
    }

    void menubar_action_cb (Gtk.Action action) {
      menu_bar.visible = menubar_action.get_active ();
    }

    construct {
      /* Load the configuration */
      Gemini.configuration = new Gemini.Configuration ();

      /* Build the UI */
      freighter = new Gemini.Freighter ();
      freighter.hauler_change += hauler_change_cb;
      freighter.hauler_new (typeof (Gemini.TileLayout));
      freighter.all_terminals_exited += all_terminals_exited_cb;

      terminal_new ();

      setup_ui_manager ();

      set_default_size (640, 480);
      string filename = Gemini.File.pixmaps ("gemini.svg");
      try {
        gemini_logo = new Gdk.Pixbuf.from_file (filename);
        set_icon (gemini_logo);
      } catch (Error e) {
        gemini_logo = null;
      }
      var vbox = new VBox (false, 0);
      menu_bar = ui_manager.get_widget ("/MenuBar");
      vbox.pack_start (menu_bar, false, false, 0);
      vbox.pack_start (freighter.vbox, true, true, 0);
      vbox.show_all ();
      add (vbox);
      connect ("delete_event", delete_cb);
      /* set actions from configuration */
      statusbar_action.set_active (Gemini.configuration.statusbar);
      menubar_action.set_active (Gemini.configuration.menubar);
      fullscreen_action.set_active (Gemini.configuration.fullscreen);

      show ();
    }

    bool delete_cb () {
      /* throw a warning that we will close all the terminals */
      var dialog = new MessageDialog (this, DialogFlags.DESTROY_WITH_PARENT, MessageType.QUESTION, ButtonsType.OK_CANCEL,
                  "Do you really want to close gemini-terminal ?");
      dialog.set_default_response (ResponseType.YES);
      if (dialog.run () == ResponseType.OK) {
        Gtk.main_quit ();
        dialog.destroy ();
        return false;
      }
      dialog.destroy ();
      return true;
    }

    void setup_ui_manager () {
      ui_manager = new UIManager ();
      menu_actions = new Gtk.ActionGroup ("Actions");
      menu_actions.add_actions (action_entries, this);
      menu_actions.add_toggle_actions (toggle_entries, this);
      ui_manager.insert_action_group (menu_actions, 0);
      fullscreen_action = (Gtk.ToggleAction) menu_actions.get_action ("Fullscreen");
      statusbar_action = (Gtk.ToggleAction) menu_actions.get_action ("Statusbar");
      menubar_action = (Gtk.ToggleAction) menu_actions.get_action ("Menubar");
      try {
        ui_manager.add_ui_from_string (MAIN_UI, MAIN_UI.length);
      } catch (GLib.Error err) {
        warning ("Error while reading the main ui: %s", err.message);
      }
      add_accel_group (ui_manager.get_accel_group ());
    }

    void about_action_cb (Gtk.Action action) {
      var dialog = new AboutDialog ();
      dialog.set_logo (gemini_logo);
      dialog.set_icon (gemini_logo);
      dialog.set_copyright ("Copyright (c) 2008, 2009 Thijs Vermeir");
      dialog.set_program_name ("Gemini Terminal");
      dialog.set_version ("0.10");
      dialog.set_website ("http://gemini.digitalmediaplanet.net");
      dialog.run ();
      dialog.hide ();
      dialog.destroy ();
    }

    void all_terminals_exited_cb (Gemini.Freighter f) {
      Gtk.main_quit ();
    }

    void terminal_new () {
      lock (freighter) {
        string working_dir = null;
        if (freighter.active_hauler != null && freighter.active_hauler.size > 0)
          working_dir = freighter.active_hauler.terminal_get_focus ().get_working_dir ();
        var terminal = new Gemini.Terminal (working_dir);
        terminal.key_press_event += key_press_event_cb;
        terminal.child_exited += terminal_child_exited_cb;
        terminal.focus_in_event += terminal_focus_in_event_cb;
        freighter.terminal_add (terminal);
        freighter.active_hauler.terminal_set_focus (terminal);
      }
    }

    bool terminal_focus_in_event_cb (Gemini.Terminal terminal, Gdk.EventFocus focus) {
      lock (freighter) {
        freighter.active_hauler.terminal_set_focus (terminal);
      }
      return false;
    }

    void terminal_child_exited_cb (Gemini.Terminal terminal) {
      lock (freighter) {
        freighter.terminal_remove (terminal);
      }
    }

    void hauler_show (uint position) {
      lock (freighter) {
        if (position < freighter.size) {
          freighter.hauler_show (freighter.hauler_get (position));
        }
      }
    }

    void hauler_change_cb (Gemini.Freighter f) {
      lock (freighter) {
        if (freighter.active_hauler == null) {
          all_terminals_exited_cb (f);
        }
      }
    }

    bool key_press_event_cb (Gemini.Terminal terminal, Gdk.EventKey event_key) {
      bool valid = true;
      if ((event_key.state & Gdk.ModifierType.MOD1_MASK) == Gdk.ModifierType.MOD1_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        if ((event_key.state & Gdk.ModifierType.CONTROL_MASK) == Gdk.ModifierType.CONTROL_MASK) {
          switch (name) {
            case "1":
              freighter.terminal_hauler_copy (freighter.hauler_get (0));
              break;
            case "2":
              freighter.terminal_hauler_copy (freighter.hauler_get (1));
              break;
            case "3":
              freighter.terminal_hauler_copy (freighter.hauler_get (2));
              break;
            case "4":
              freighter.terminal_hauler_copy (freighter.hauler_get (3));
              break;
            case "5":
              freighter.terminal_hauler_copy (freighter.hauler_get (4));
              break;
            case "6":
              freighter.terminal_hauler_copy (freighter.hauler_get (5));
              break;
            case "7":
              freighter.terminal_hauler_copy (freighter.hauler_get (6));
              break;
            case "8":
              freighter.terminal_hauler_copy (freighter.hauler_get (7));
              break;
            case "9":
              freighter.terminal_hauler_copy (freighter.hauler_get (8));
              break;
            default:
              valid = false;
              break;
          }
        } else {
          switch (name) {
            case "Return":
              lock (freighter) {
                freighter.active_hauler.terminal_focus_up ();
              }
              break;
            case "h":
              lock (freighter) {
                freighter.active_hauler.layout.width_change (5);
              }
              break;
            case "l":
              lock (freighter) {
                freighter.active_hauler.layout.width_change (-5);
              }
              break;
            default:
              valid = false;
              break;
          }
        }
      } else if ((event_key.state & Gdk.ModifierType.MOD4_MASK) == Gdk.ModifierType.MOD4_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "o":
            terminal_new ();
            break;
          case "x":
            lock (freighter) {
              freighter.terminal_close (freighter.active_hauler.terminal_get_focus ());
            }
            break;
          case "Return":
            lock (freighter) {
              if (freighter.active_hauler.size > 1) {
                var t1 = freighter.active_hauler.terminals.get (0);
                var t2 = freighter.active_hauler.terminals.get (1);
                var active = freighter.active_hauler.terminal_get_focus ();

                if (t1 == active)
                  freighter.active_hauler.terminal_zoom (t2);
                else
                  freighter.active_hauler.terminal_zoom (active);
              }
            }
            break;
          case "k":
            lock (freighter) {
              freighter.active_hauler.terminal_focus_up ();
            }
            break;
          case "j":
            lock (freighter) {
              freighter.active_hauler.terminal_focus_down ();
            }
            break;
          case "H":
            lock (freighter) {
              freighter.active_hauler.layout.width_change (5);
            }
            break;
          case "L":
            lock (freighter) {
              freighter.active_hauler.layout.width_change (-5);
            }
            break;
          case "c":
            lock (freighter) {
              var new_hauler = freighter.active_hauler.copy ();
              freighter.hauler_add (new_hauler);
              freighter.hauler_show (new_hauler);
            }
            break;
          case "n":
            lock (freighter) {
              var new_hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
              freighter.hauler_add (new_hauler);
              freighter.hauler_show (new_hauler);
              terminal_new ();
            }
            break;
          case "1":
            hauler_show (0);
            break;
          case "2":
            hauler_show (1);
            break;
          case "3":
            hauler_show (2);
            break;
          case "4":
            hauler_show (3);
            break;
          case "5":
            hauler_show (4);
            break;
          case "6":
            hauler_show (5);
            break;
          case "7":
            hauler_show (6);
            break;
          case "8":
            hauler_show (7);
            break;
          case "9":
            hauler_show (8);
            break;
          case "m":
            menubar_action.activate ();
            break;
          case "s":
            statusbar_action.activate ();
            break;
          case "f":
            lock (freighter) {
              freighter.active_hauler.layout_switch (typeof (FullscreenLayout));
            }
            break;
          case "space":
            lock (freighter) {
              freighter.active_hauler.layout_switch (typeof (TileLayout));
            }
            break;
          default:
            valid = false;
            break;
        }
      } else if ((event_key.state & Gdk.ModifierType.CONTROL_MASK) == Gdk.ModifierType.CONTROL_MASK) {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "1":
            freighter.terminal_hauler_move (freighter.hauler_get (0));
            break;
          case "2":
            freighter.terminal_hauler_move (freighter.hauler_get (1));
            break;
          case "3":
            freighter.terminal_hauler_move (freighter.hauler_get (2));
            break;
          case "4":
            freighter.terminal_hauler_move (freighter.hauler_get (3));
            break;
          case "5":
            freighter.terminal_hauler_move (freighter.hauler_get (4));
            break;
          case "6":
            freighter.terminal_hauler_move (freighter.hauler_get (5));
            break;
          case "7":
            freighter.terminal_hauler_move (freighter.hauler_get (6));
            break;
          case "8":
            freighter.terminal_hauler_move (freighter.hauler_get (7));
            break;
          case "9":
            freighter.terminal_hauler_move (freighter.hauler_get (8));
            break;
          default:
            valid = false;
            break;
        }
      } else
        valid = false;
      return valid;
    }
  }

  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.GeminiTile ();
    Gtk.main ();
  }
}
