//! The launcher window's state and drawing.

use std::path::{Path, PathBuf};
use std::sync::Arc;
use std::time::{Duration, Instant};

use eframe::egui::{self, Color32, CornerRadius, RichText, TextureHandle, TextureOptions};
use tms_db::Source;
use tms_db::backup::{self, BackupInfo};

use super::form::{LOG_LEVELS, ServerForm, command_line};
use super::jobs::{EventRow, Job, Jobs, Place, Report};
use super::supervisor::{Notice, ServerState, Supervisor};
use super::{logs, qr};
use crate::settings::ServeArgs;

const TEAL: Color32 = Color32::from_rgb(0x00, 0x94, 0x85);

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tab {
  Connect,
  Server,
  Database,
  Backups,
  Logs,
}

/// What to check when tablets can't reach the server, and what keeps it reachable.
#[cfg(windows)]
const FIREWALL_HINT: &str = "Tablets can't connect? Allow tms through Windows Firewall, on Public networks too: school \
  Wi-Fi often counts as Public. This laptop is kept awake while the server runs; keep it plugged in with the lid open.";
#[cfg(not(windows))]
const FIREWALL_HINT: &str = "Tablets can't connect? Check this computer's firewall lets the port in.";

impl Tab {
  const ALL: [Tab; 5] = [Tab::Connect, Tab::Server, Tab::Database, Tab::Backups, Tab::Logs];

  fn label(self) -> &'static str {
    match self {
      Tab::Connect => "Connect",
      Tab::Server => "Server",
      Tab::Database => "Database",
      Tab::Backups => "Backups",
      Tab::Logs => "Logs",
    }
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Tone {
  Good,
  Bad,
  Neutral,
}

/// What to do once the server has stopped.
#[derive(Debug, Clone, PartialEq, Eq)]
enum AfterStop {
  Start,
  Restore(PathBuf),
  Quit,
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum Dialog {
  ConfirmRestore {
    file: PathBuf,
    label: String,
  },
  ConfirmQuit,
  Crash {
    message: String,
    code: Option<i32>,
    lines: Vec<String>,
  },
  ResetPassword {
    username: String,
    password: String,
  },
  ShowPassword {
    username: String,
    password: String,
  },
  Purge {
    selected: Option<usize>,
    typed: String,
  },
  About,
}

pub struct LauncherApp {
  program: PathBuf,
  launch_args: ServeArgs,
  data_dir: PathBuf,
  web_dir: PathBuf,
  form: ServerForm,
  /// The form as it was when the server last started, to offer "Restart to apply".
  applied: Option<ServerForm>,
  admin_password_input: String,
  supervisor: Supervisor,
  jobs: Jobs,
  job_step: Option<String>,
  restart_after_job: bool,
  after_stop: Option<AfterStop>,
  tab: Tab,
  selected_url: usize,
  qr: Option<(String, TextureHandle)>,
  log_level: String,
  log_lines: Vec<String>,
  logs_read_at: Option<Instant>,
  backups: Vec<BackupInfo>,
  backups_read_at: Option<Instant>,
  disk_size: Option<u64>,
  events: Vec<EventRow>,
  admin_password: Option<String>,
  message: Option<(Tone, String)>,
  dialog: Option<Dialog>,
  styled: bool,
}

impl LauncherApp {
  pub fn new(ctx: &egui::Context, program: PathBuf, launch_args: ServeArgs) -> anyhow::Result<Self> {
    let settings = launch_args.clone().resolve()?;
    let wake_ctx = ctx.clone();
    let wake: Arc<dyn Fn() + Send + Sync> = Arc::new(move || wake_ctx.request_repaint());
    Ok(Self {
      program,
      data_dir: settings.data_dir.clone(),
      web_dir: settings.web_dir.clone(),
      form: ServerForm::from_settings(&settings),
      applied: None,
      admin_password_input: String::new(),
      supervisor: Supervisor::new(Arc::clone(&wake)),
      jobs: Jobs::new(wake)?,
      job_step: None,
      restart_after_job: false,
      after_stop: None,
      tab: Tab::Connect,
      selected_url: 0,
      qr: None,
      log_level: "all".into(),
      log_lines: Vec::new(),
      logs_read_at: None,
      backups: Vec::new(),
      backups_read_at: None,
      disk_size: None,
      events: Vec::new(),
      admin_password: None,
      message: None,
      dialog: None,
      styled: false,
      launch_args,
    })
  }

  pub fn state(&self) -> &ServerState {
    self.supervisor.state()
  }

  /// The message line under the header, if one is showing.
  pub fn message(&self) -> Option<&str> {
    self.message.as_ref().map(|(_, text)| text.as_str())
  }

  fn backups_dir(&self) -> PathBuf {
    self.data_dir.join("backups")
  }

  fn logs_dir(&self) -> PathBuf {
    self.data_dir.join("logs")
  }

  fn first_start(&self) -> bool {
    !self.data_dir.join("postgres").exists()
  }

  fn place(&self) -> Place {
    let source = if self.form.external_db {
      Source::External {
        url: self.form.database_url.trim().to_owned(),
      }
    } else {
      Source::Embedded {
        dir: self.data_dir.join("postgres"),
        port: None,
      }
    };
    Place {
      source,
      postgres_dir: self.data_dir.join("postgres"),
      backups_dir: self.backups_dir(),
    }
  }

  /// The launcher's own folder flags, which the server must get too.
  fn launch_flags(&self) -> Vec<String> {
    let mut flags = Vec::new();
    if let Some(dir) = &self.launch_args.data_dir {
      flags.extend(["--data-dir".to_owned(), dir.display().to_string()]);
    }
    if let Some(dir) = &self.launch_args.web_dir {
      flags.extend(["--web-dir".to_owned(), dir.display().to_string()]);
    }
    flags
  }

  fn start(&mut self) {
    let checked = match self.form.check() {
      Ok(checked) => checked,
      Err(message) => {
        self.tab = Tab::Server;
        self.message = Some((Tone::Bad, message));
        return;
      }
    };
    if let Err(message) = self.form.save(&self.data_dir) {
      self.message = Some((Tone::Bad, message));
      return;
    }
    let mut args = self.launch_flags();
    for (flag, value) in &checked.flags {
      args.push(flag.clone());
      args.push(value.clone());
    }
    // Passed in the environment, so it never shows in the command line or tms.toml.
    let env = if self.admin_password_input.trim().is_empty() {
      Vec::new()
    } else {
      vec![(
        "TMS_ADMIN_PASSWORD".to_owned(),
        self.admin_password_input.trim().to_owned(),
      )]
    };
    match self.supervisor.start(self.program.clone(), &args, env, checked.health) {
      Ok(()) => {
        self.applied = Some(self.form.clone());
        self.message = None;
      }
      Err(e) => self.message = Some((Tone::Bad, format!("Could not start the server: {e}"))),
    }
  }

  fn stop_then(&mut self, after: Option<AfterStop>) {
    self.after_stop = after;
    if self.supervisor.state().is_up() {
      self.supervisor.stop();
    }
  }

  fn run_job(&mut self, job: Job) {
    if self.jobs.running() {
      return;
    }
    self.message = None;
    self.jobs.start(self.place(), job);
  }

  /// Applies news from the server and from jobs, and anything waiting for the server to stop.
  fn update(&mut self, ctx: &egui::Context) {
    for notice in self.supervisor.poll() {
      match notice {
        Notice::AdminPassword(password) => self.admin_password = Some(password),
        Notice::BackupCreated(file) => {
          self.backups_read_at = None;
          self.message = Some((Tone::Good, format!("Backup created: {file}")));
        }
        Notice::BackupFailed(message) => self.message = Some((Tone::Bad, format!("Backup failed: {message}"))),
        Notice::Crashed { message, code } => {
          let mut lines = logs::tail(&self.logs_dir());
          lines.extend(self.supervisor.stderr_tail());
          let skip = lines.len().saturating_sub(20);
          self.dialog = Some(Dialog::Crash {
            message,
            code,
            lines: lines.split_off(skip),
          });
        }
      }
    }
    for report in self.jobs.poll() {
      match report {
        Report::Step(step) => self.job_step = Some(step),
        Report::Done(text) => {
          self.job_step = None;
          self.backups_read_at = None;
          self.message = Some((Tone::Good, text));
          if std::mem::take(&mut self.restart_after_job) {
            self.start();
          }
        }
        Report::Failed(text) => {
          self.job_step = None;
          self.restart_after_job = false;
          self.message = Some((Tone::Bad, text));
        }
        Report::Events(events) => {
          self.job_step = None;
          self.events = events;
        }
        Report::Password { username, password } => {
          self.job_step = None;
          self.dialog = Some(Dialog::ShowPassword { username, password });
        }
      }
    }
    if !self.supervisor.state().is_up()
      && let Some(after) = self.after_stop.take()
    {
      match after {
        AfterStop::Start => self.start(),
        AfterStop::Restore(file) => {
          self.restart_after_job = true;
          self.run_job(Job::Restore(file));
        }
        AfterStop::Quit => ctx.send_viewport_cmd(egui::ViewportCommand::Close),
      }
    }
    if ctx.input(|i| i.viewport().close_requested()) && self.supervisor.state().is_up() {
      ctx.send_viewport_cmd(egui::ViewportCommand::CancelClose);
      if self.after_stop != Some(AfterStop::Quit) {
        self.dialog = Some(Dialog::ConfirmQuit);
      }
    }
    // Uptime and log tails move on their own.
    ctx.request_repaint_after(Duration::from_secs(1));
  }

  /// Draws the whole window. Also the entry point for tests.
  pub fn draw(&mut self, ui: &mut egui::Ui) {
    let ctx = ui.ctx().clone();
    if !self.styled {
      style(&ctx);
      self.styled = true;
    }
    self.update(&ctx);
    egui::Panel::top("header").show(ui, |ui| self.header(ui));
    egui::Panel::bottom("footer").show(ui, |ui| self.footer(ui));
    egui::CentralPanel::default().show(ui, |ui| {
      if let Some((tone, text)) = self.message.clone() {
        ui.horizontal(|ui| {
          if ui.small_button("Dismiss").clicked() {
            self.message = None;
          }
          ui.add(egui::Label::new(RichText::new(text).color(tone_color(tone))).wrap());
        });
        ui.separator();
      }
      if let Some(step) = &self.job_step {
        ui.horizontal(|ui| {
          ui.spinner();
          ui.label(step);
        });
        ui.separator();
      }
      egui::ScrollArea::vertical()
        .auto_shrink(false)
        .show(ui, |ui| match self.tab {
          Tab::Connect => self.connect_tab(ui),
          Tab::Server => self.server_tab(ui),
          Tab::Database => self.database_tab(ui),
          Tab::Backups => self.backups_tab(ui),
          Tab::Logs => self.logs_tab(ui),
        });
    });
    self.dialogs(&ctx);
  }

  fn header(&mut self, ui: &mut egui::Ui) {
    ui.add_space(6.0);
    ui.horizontal(|ui| {
      ui.label(RichText::new("TMS").strong().size(20.0));
      let (text, tone) = status_text(self.supervisor.state());
      ui.label(RichText::new(text).strong().color(tone_color(tone)));
      ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
        let up = self.supervisor.state().is_up();
        let busy = self.jobs.running();
        if ui.add_enabled(up && !busy, egui::Button::new("Restart")).clicked() {
          self.stop_then(Some(AfterStop::Start));
        }
        if ui.add_enabled(up, egui::Button::new("Stop")).clicked() {
          self.stop_then(None);
        }
        if ui
          .add_enabled(!up && !busy, egui::Button::new(RichText::new("Start").strong()))
          .clicked()
        {
          self.start();
        }
      });
    });
    ui.add_space(4.0);
    ui.horizontal(|ui| {
      for tab in Tab::ALL {
        ui.selectable_value(&mut self.tab, tab, tab.label());
      }
    });
    ui.add_space(4.0);
  }

  fn footer(&mut self, ui: &mut egui::Ui) {
    ui.add_space(4.0);
    let flags = self.form.check().map(|c| c.flags).unwrap_or_default();
    let line = command_line(&flags, self.launch_args.data_dir.as_deref());
    ui.label(RichText::new("The same server from a terminal:").small());
    ui.horizontal(|ui| {
      if ui.small_button("Copy").clicked() {
        ui.ctx().copy_text(line.clone());
      }
      ui.add(egui::Label::new(RichText::new(&line).monospace()).truncate())
        .on_hover_text(&line);
    });
    ui.horizontal(|ui| {
      ui.menu_button("Maintenance", |ui| {
        let up = self.supervisor.state().is_up();
        if ui
          .add_enabled(!up, egui::Button::new("Reset a user's password…"))
          .clicked()
        {
          self.dialog = Some(Dialog::ResetPassword {
            username: "admin".into(),
            password: String::new(),
          });
        }
        if ui.add_enabled(!up, egui::Button::new("Delete an event…")).clicked() {
          self.events.clear();
          self.run_job(Job::LoadEvents);
          self.dialog = Some(Dialog::Purge {
            selected: None,
            typed: String::new(),
          });
        }
        if up {
          ui.label(RichText::new("Stop the server to use these.").small());
        }
        ui.separator();
        if ui.button("Open data folder").clicked() {
          open_folder(&self.data_dir);
        }
        if ui.button("About TMS").clicked() {
          self.dialog = Some(Dialog::About);
        }
      });
      ui.label(RichText::new(format!("Data: {}", self.data_dir.display())).small());
    });
    ui.add_space(4.0);
  }

  fn connect_tab(&mut self, ui: &mut egui::Ui) {
    if let Some(password) = self.admin_password.clone() {
      egui::Frame::group(ui.style()).show(ui, |ui| {
        ui.label(RichText::new("First start").strong());
        ui.label(format!(
          "Log in as admin with the password {password}. Set a better one in the Server tab (Admin password), \
           then add your own user in the web UI."
        ));
      });
      ui.add_space(8.0);
    }
    let urls = self.supervisor.state().urls().to_vec();
    if urls.is_empty() {
      ui.label("Start the server to see the address other devices use.");
      if !self.web_dir.join("index.html").exists() {
        ui.add_space(8.0);
        ui.label(
          RichText::new(format!(
            "The web client was not found in {}. Keep the web folder next to the tms program.",
            self.web_dir.display()
          ))
          .color(tone_color(Tone::Bad)),
        );
      }
      return;
    }
    self.selected_url = self.selected_url.min(urls.len() - 1);
    let url = urls[self.selected_url].clone();
    ui.label("Open this on any device on the same network, or scan the code:");
    egui::ComboBox::from_id_salt("address")
      .selected_text(&url)
      .width(320.0)
      .show_ui(ui, |ui| {
        for (i, u) in urls.iter().enumerate() {
          ui.selectable_value(&mut self.selected_url, i, u);
        }
      });
    if self.qr.as_ref().is_none_or(|(shown, _)| *shown != url)
      && let Some(image) = qr::image(&url, 8)
    {
      let texture = ui.ctx().load_texture("join-qr", image, TextureOptions::NEAREST);
      self.qr = Some((url.clone(), texture));
    }
    if let Some((_, texture)) = &self.qr {
      ui.add_space(8.0);
      ui.add(egui::Image::new(texture).fit_to_exact_size(egui::vec2(260.0, 260.0)));
    }
    ui.add_space(8.0);
    ui.horizontal(|ui| {
      if ui.button("Copy address").clicked() {
        ui.ctx().copy_text(url.clone());
      }
      if ui.button("Open in browser").clicked() {
        let _ = opener::open_browser(&url);
      }
      if ui.button("Save QR code…").clicked()
        && let Some(path) = rfd::FileDialog::new()
          .set_file_name("tms-join.svg")
          .add_filter("SVG image", &["svg"])
          .save_file()
        && let Some(svg) = qr::svg(&url)
      {
        self.message = Some(match std::fs::write(&path, svg) {
          Ok(()) => (Tone::Good, format!("Saved {}", path.display())),
          Err(e) => (Tone::Bad, format!("Saving the QR code: {e}")),
        });
      }
    });
    ui.add_space(10.0);
    ui.label(RichText::new(format!("Venue screens (TVs and projectors): open {url}/display")).small());
    ui.label(RichText::new(FIREWALL_HINT).small());
  }

  fn server_tab(&mut self, ui: &mut egui::Ui) {
    let up = self.supervisor.state().is_up();
    if up {
      ui.label("These settings are locked while the server runs.");
      if self.applied.as_ref().is_some_and(|a| *a != self.form) && ui.button("Restart to apply").clicked() {
        self.stop_then(Some(AfterStop::Start));
      }
      ui.add_space(6.0);
    }
    let first_start = self.first_start();
    let form = &mut self.form;
    ui.add_enabled_ui(!up, |ui| {
      egui::Grid::new("server")
        .num_columns(2)
        .spacing([12.0, 8.0])
        .show(ui, |ui| {
          ui.label("Listen on");
          ui.text_edit_singleline(&mut form.bind);
          ui.end_row();
          ui.label("HTTP port");
          ui.text_edit_singleline(&mut form.port);
          ui.end_row();
          ui.label("Public host");
          ui.add(egui::TextEdit::singleline(&mut form.public_host).hint_text("Shown in the address and QR code"));
          ui.end_row();
          ui.label("HTTPS");
          ui.checkbox(&mut form.https, "Serve HTTPS (HTTP then redirects)");
          ui.end_row();
          if form.https {
            ui.label("Certificate");
            file_field(ui, &mut form.tls_cert);
            ui.end_row();
            ui.label("Private key");
            file_field(ui, &mut form.tls_key);
            ui.end_row();
            ui.label("HTTPS port");
            ui.text_edit_singleline(&mut form.tls_port);
            ui.end_row();
          }
          ui.label("Log level");
          egui::ComboBox::from_id_salt("log-level")
            .selected_text(&form.log_level)
            .show_ui(ui, |ui| {
              for level in LOG_LEVELS {
                ui.selectable_value(&mut form.log_level, level.to_owned(), level);
              }
            });
          ui.end_row();
        });
    });
    ui.add_space(10.0);
    ui.add_enabled_ui(!up, |ui| {
      ui.label("Admin password");
      ui.add(
        egui::TextEdit::singleline(&mut self.admin_password_input)
          .password(true)
          .hint_text(if first_start {
            "Leave empty to start with: admin"
          } else {
            "Leave empty to keep it"
          }),
      );
    });
    ui.label(
      RichText::new(
        "Starting with a password here gives the admin user that password, and re-enables it if needed. \
         It is the way back in if you forget yours.",
      )
      .small(),
    );
  }

  fn database_tab(&mut self, ui: &mut egui::Ui) {
    let up = self.supervisor.state().is_up();
    let busy = self.jobs.running();
    ui.add_enabled_ui(!up, |ui| {
      ui.radio_value(&mut self.form.external_db, false, "Built-in database (recommended)");
      ui.radio_value(&mut self.form.external_db, true, "An existing PostgreSQL server");
    });
    ui.add_space(8.0);
    if self.form.external_db {
      ui.label("Connection URL");
      ui.add_enabled(
        !up,
        egui::TextEdit::singleline(&mut self.form.database_url)
          .hint_text("postgres://user:password@host:5432/tms")
          .desired_width(f32::INFINITY),
      );
      if ui.add_enabled(!busy, egui::Button::new("Test connection")).clicked() {
        let url = self.form.database_url.trim().to_owned();
        self.run_job(Job::TestConnection(url));
      }
      return;
    }
    let postgres = self.data_dir.join("postgres");
    egui::Grid::new("database")
      .num_columns(2)
      .spacing([12.0, 8.0])
      .show(ui, |ui| {
        ui.label("Folder");
        ui.horizontal(|ui| {
          ui.label(postgres.display().to_string());
          if ui.small_button("Open").clicked() {
            open_folder(&postgres);
          }
        });
        ui.end_row();
        ui.label("Fixed port");
        ui.add_enabled(
          !up,
          egui::TextEdit::singleline(&mut self.form.db_port).hint_text("Any free port"),
        );
        ui.end_row();
        ui.label("Size on disk");
        ui.horizontal(|ui| {
          ui.label(self.disk_size.map_or_else(|| "–".to_owned(), size_text));
          if ui.small_button("Measure").clicked() {
            self.disk_size = Some(folder_size(&postgres));
          }
        });
        ui.end_row();
        ui.label("Password");
        ui.label(postgres.join("password").display().to_string());
        ui.end_row();
      });
    ui.add_space(6.0);
    ui.label(
      RichText::new("Set a fixed port to look at the database with pgAdmin or psql (user postgres, database tms).")
        .small(),
    );
  }

  fn backups_tab(&mut self, ui: &mut egui::Ui) {
    if self
      .backups_read_at
      .is_none_or(|at| at.elapsed() > Duration::from_secs(3))
    {
      self.backups = backup::list(&self.backups_dir());
      self.backups_read_at = Some(Instant::now());
    }
    let up = self.supervisor.state().is_up();
    let busy = self.jobs.running();
    ui.horizontal(|ui| {
      let can_create = matches!(self.supervisor.state(), ServerState::Running { .. }) || (!up && !busy);
      if ui.add_enabled(can_create, egui::Button::new("Create now")).clicked() {
        if up {
          self.supervisor.backup();
          self.message = Some((Tone::Neutral, "Backing up…".into()));
        } else {
          self.run_job(Job::Backup);
        }
      }
      if ui.button("Import file…").clicked()
        && let Some(file) = rfd::FileDialog::new()
          .add_filter("TMS backup", &[backup::EXTENSION])
          .pick_file()
      {
        self.message = Some(match backup::import(&file, &self.backups_dir()) {
          Ok(path) => (Tone::Good, format!("Imported {}", path.display())),
          Err(e) => (Tone::Bad, format!("{e:#}")),
        });
        self.backups_read_at = None;
      }
      if ui.button("Open backups folder").clicked() {
        let _ = std::fs::create_dir_all(self.backups_dir());
        open_folder(&self.backups_dir());
      }
    });
    ui.add_enabled_ui(!up, |ui| {
      ui.horizontal(|ui| {
        ui.label("Every");
        ui.add(egui::TextEdit::singleline(&mut self.form.backup_interval).desired_width(40.0));
        ui.label("minutes (0 for never), keeping the newest");
        ui.add(egui::TextEdit::singleline(&mut self.form.backup_retain).desired_width(40.0));
        ui.label("automatic ones.");
      });
    });
    ui.separator();
    if self.backups.is_empty() {
      ui.label("No backups yet.");
      return;
    }
    let mut restore = None;
    egui::Grid::new("backups")
      .num_columns(5)
      .striped(true)
      .spacing([12.0, 6.0])
      .show(ui, |ui| {
        for header in ["Made", "Kind", "Size", "Events", ""] {
          ui.label(RichText::new(header).strong());
        }
        ui.end_row();
        for b in &self.backups {
          let made = b
            .manifest
            .created_at
            .with_timezone(&chrono::Local)
            .format("%a %d %b %H:%M:%S");
          ui.label(made.to_string())
            .on_hover_text(format!("{}\nTMS {}", b.file_name, b.manifest.app_version));
          ui.label(b.manifest.kind.label());
          ui.label(size_text(b.size));
          ui.label(b.manifest.event_codes.join(", "));
          if ui.add_enabled(!busy, egui::Button::new("Restore")).clicked() {
            restore = Some((b.path.clone(), made.to_string()));
          }
          ui.end_row();
        }
      });
    if let Some((file, label)) = restore {
      self.dialog = Some(Dialog::ConfirmRestore { file, label });
    }
  }

  fn logs_tab(&mut self, ui: &mut egui::Ui) {
    if self.logs_read_at.is_none_or(|at| at.elapsed() > Duration::from_secs(1)) {
      self.log_lines = logs::tail(&self.logs_dir());
      self.logs_read_at = Some(Instant::now());
    }
    ui.horizontal(|ui| {
      egui::ComboBox::from_id_salt("log-filter")
        .selected_text(format!("Show: {}", self.log_level))
        .show_ui(ui, |ui| {
          for level in ["all", "info", "warn", "error"] {
            ui.selectable_value(&mut self.log_level, level.to_owned(), level);
          }
        });
      if ui.button("Open logs folder").clicked() {
        open_folder(&self.logs_dir());
      }
      if ui.button("Copy last 100 lines").clicked() {
        let skip = self.log_lines.len().saturating_sub(100);
        ui.ctx().copy_text(self.log_lines[skip..].join("\n"));
      }
    });
    ui.separator();
    let level = self.log_level.clone();
    egui::ScrollArea::vertical()
      .id_salt("log-lines")
      .stick_to_bottom(true)
      .auto_shrink(false)
      .show(ui, |ui| {
        for line in self.log_lines.iter().filter(|l| logs::passes(l, &level)) {
          ui.label(RichText::new(line).monospace().small());
        }
      });
  }

  fn dialogs(&mut self, ctx: &egui::Context) {
    let Some(dialog) = self.dialog.clone() else {
      return;
    };
    let mut close = false;
    let mut next = None;
    egui::Modal::new(egui::Id::unique("dialog")).show(ctx, |ui| {
      ui.set_max_width(460.0);
      match dialog {
        Dialog::ConfirmRestore { file, label } => {
          ui.heading("Restore this backup?");
          ui.label(format!(
            "Everything in the database is replaced with the backup from {label}. A backup of the current data is \
             made first. The server stops while this happens and starts again afterwards."
          ));
          ui.horizontal(|ui| {
            if ui.button("Cancel").clicked() {
              close = true;
            }
            if ui.button(RichText::new("Restore").strong()).clicked() {
              let was_up = self.supervisor.state().is_up();
              if was_up {
                self.stop_then(Some(AfterStop::Restore(file.clone())));
              } else {
                self.run_job(Job::Restore(file.clone()));
              }
              close = true;
            }
          });
        }
        Dialog::ConfirmQuit => {
          ui.heading("Stop the server and quit?");
          ui.label("Devices connected to TMS lose their connection until it is started again.");
          ui.horizontal(|ui| {
            if ui.button("Cancel").clicked() {
              close = true;
            }
            if ui.button(RichText::new("Stop and quit").strong()).clicked() {
              self.stop_then(Some(AfterStop::Quit));
              close = true;
            }
          });
        }
        Dialog::Crash { message, code, lines } => {
          ui.heading("The server stopped");
          ui.label(&message);
          ui.label(format!("Exit code: {}", code.map_or_else(|| "none".to_owned(), |c| c.to_string())));
          egui::ScrollArea::vertical().max_height(220.0).show(ui, |ui| {
            for line in &lines {
              ui.label(RichText::new(line).monospace().small());
            }
          });
          ui.horizontal(|ui| {
            if ui.button("Open logs").clicked() {
              open_folder(&self.logs_dir());
            }
            if ui.button("Copy details").clicked() {
              ui.ctx().copy_text(format!("{message}\nexit code {code:?}\n{}", lines.join("\n")));
            }
            if ui.button("Restart").clicked() {
              self.start();
              close = true;
            }
            if ui.button("Close").clicked() {
              close = true;
            }
          });
        }
        Dialog::ResetPassword {
          mut username,
          mut password,
        } => {
          ui.heading("Set a user's password");
          ui.label("Type the new password, or leave it empty for a one-time password they change at their next login. Their other logins end.");
          egui::Grid::new("reset-password").num_columns(2).show(ui, |ui| {
            ui.label("Username");
            ui.text_edit_singleline(&mut username);
            ui.end_row();
            ui.label("New password");
            ui.add(egui::TextEdit::singleline(&mut password).password(true).hint_text("one-time password"));
            ui.end_row();
          });
          ui.horizontal(|ui| {
            if ui.button("Cancel").clicked() {
              close = true;
            }
            if ui.add_enabled(!username.trim().is_empty(), egui::Button::new("Set password")).clicked() {
              let chosen = (!password.is_empty()).then(|| password.clone());
              self.run_job(Job::ResetPassword(username.clone(), chosen));
              close = true;
            }
          });
          if !close {
            next = Some(Dialog::ResetPassword { username, password });
          }
        }
        Dialog::ShowPassword { username, password } => {
          ui.heading("One-time password");
          ui.label(format!("{username} logs in with:"));
          ui.label(RichText::new(&password).monospace().size(18.0));
          ui.horizontal(|ui| {
            if ui.button("Copy").clicked() {
              ui.ctx().copy_text(password.clone());
            }
            if ui.button("Done").clicked() {
              close = true;
            }
          });
        }
        Dialog::Purge { mut selected, mut typed } => {
          ui.heading("Delete an event");
          ui.label("Deletes the event with its teams, schedule, scoresheets and access keys. This can't be undone, but a backup made earlier can bring it back.");
          if self.events.is_empty() {
            ui.label(if self.jobs.running() { "Loading events…" } else { "There are no events." });
          }
          for (i, event) in self.events.iter().enumerate() {
            ui.radio_value(&mut selected, Some(i), format!("{} {}", event.code, event.name));
          }
          let chosen = selected.and_then(|i| self.events.get(i)).cloned();
          if let Some(event) = &chosen {
            ui.label(format!("Type {} to confirm", event.code));
            ui.text_edit_singleline(&mut typed);
          }
          ui.horizontal(|ui| {
            if ui.button("Cancel").clicked() {
              close = true;
            }
            let confirmed = chosen.as_ref().is_some_and(|e| e.code.eq_ignore_ascii_case(typed.trim()));
            if ui.add_enabled(confirmed, egui::Button::new("Delete event")).clicked()
              && let Some(event) = &chosen
            {
              self.run_job(Job::Purge {
                event_id: event.id,
                code: typed.clone(),
              });
              close = true;
            }
          });
          if !close {
            next = Some(Dialog::Purge { selected, typed });
          }
        }
        Dialog::About => {
          ui.heading("TMS");
          ui.label(format!("Version {}", env!("CARGO_PKG_VERSION")));
          ui.label("Tournament management for FIRST LEGO League Challenge.");
          ui.label(format!("Program: {}", self.program.display()));
          if ui.button("Close").clicked() {
            close = true;
          }
        }
      }
    });
    if close {
      self.dialog = None;
    } else if let Some(next) = next {
      self.dialog = Some(next);
    }
  }
}

impl eframe::App for LauncherApp {
  fn ui(&mut self, ui: &mut egui::Ui, _frame: &mut eframe::Frame) {
    self.draw(ui);
  }
}

/// Square corners and the TMS teal, in light or dark following the system.
fn style(ctx: &egui::Context) {
  ctx.set_theme(egui::ThemePreference::System);
  ctx.all_styles_mut(|style| {
    let visuals = &mut style.visuals;
    visuals.window_corner_radius = CornerRadius::ZERO;
    visuals.menu_corner_radius = CornerRadius::ZERO;
    for widget in [
      &mut visuals.widgets.noninteractive,
      &mut visuals.widgets.inactive,
      &mut visuals.widgets.hovered,
      &mut visuals.widgets.active,
      &mut visuals.widgets.open,
    ] {
      widget.corner_radius = CornerRadius::ZERO;
    }
    visuals.selection.bg_fill = TEAL;
    visuals.hyperlink_color = TEAL;
    style.spacing.button_padding = egui::vec2(10.0, 5.0);
  });
}

fn tone_color(tone: Tone) -> Color32 {
  match tone {
    Tone::Good => Color32::from_rgb(0x1a, 0x7f, 0x37),
    Tone::Bad => Color32::from_rgb(0xc0, 0x1c, 0x28),
    Tone::Neutral => Color32::GRAY,
  }
}

fn status_text(state: &ServerState) -> (String, Tone) {
  match state {
    ServerState::Stopped | ServerState::Exited(_) => ("Stopped".into(), Tone::Neutral),
    ServerState::Starting(step) => (format!("Starting: {step}"), Tone::Neutral),
    ServerState::Running { since, .. } => (format!("Running for {}", uptime(since.elapsed())), Tone::Good),
    ServerState::NotResponding { .. } => ("Not responding".into(), Tone::Bad),
    ServerState::Stopping => ("Stopping".into(), Tone::Neutral),
    ServerState::Crashed { .. } => ("Stopped with an error".into(), Tone::Bad),
  }
}

fn uptime(elapsed: Duration) -> String {
  let s = elapsed.as_secs();
  match s {
    0..60 => format!("{s} s"),
    60..3600 => format!("{} min", s / 60),
    _ => format!("{} h {} min", s / 3600, s % 3600 / 60),
  }
}

#[allow(clippy::cast_precision_loss)]
fn size_text(bytes: u64) -> String {
  match bytes {
    0..1024 => format!("{bytes} B"),
    1024..1_048_576 => format!("{:.0} KB", bytes as f64 / 1024.0),
    _ => format!("{:.1} MB", bytes as f64 / 1_048_576.0),
  }
}

fn folder_size(dir: &Path) -> u64 {
  let Ok(entries) = std::fs::read_dir(dir) else {
    return 0;
  };
  entries
    .flatten()
    .map(|e| match e.metadata() {
      Ok(m) if m.is_dir() => folder_size(&e.path()),
      Ok(m) => m.len(),
      Err(_) => 0,
    })
    .sum()
}

fn file_field(ui: &mut egui::Ui, value: &mut String) {
  ui.horizontal(|ui| {
    ui.text_edit_singleline(value);
    if ui.small_button("Choose…").clicked()
      && let Some(path) = rfd::FileDialog::new().pick_file()
    {
      *value = path.display().to_string();
    }
  });
}

fn open_folder(dir: &Path) {
  let _ = std::fs::create_dir_all(dir);
  let _ = opener::open(dir);
}
