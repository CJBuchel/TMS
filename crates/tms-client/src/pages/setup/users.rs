use dioxus::prelude::*;
use tms_core::Role;
use tms_core::dto::{
  CreateUserRequest, OneTimePassword, Principal, SetPasswordRequest, UpdateUserRequest, UserSummary,
};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Checkbox, DataTable, Modal, TextField, Tone};
use uuid::Uuid;

use crate::components::{ConfirmButton, ErrorBox, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::store::session::{Session, SessionState};

#[derive(Clone, PartialEq)]
enum Dialog {
  Create,
  Edit(UserSummary),
  Password(OneTimePassword),
}

#[component]
pub fn SetupUsers() -> Element {
  let session = use_context::<Session>();
  let mut version = use_signal(|| 0_u32);
  let users = use_resource(move || async move {
    let _ = version();
    api::get::<Vec<UserSummary>>("/users", token(session).as_deref()).await
  });
  let mut dialog = use_signal(|| None::<Dialog>);
  let mut error = use_signal(|| None::<ApiFailure>);

  let set_disabled = move |id: Uuid, disabled: bool| async move {
    let body = UpdateUserRequest {
      disabled: Some(disabled),
      ..UpdateUserRequest::default()
    };
    match api::patch::<_, UserSummary>(&format!("/users/{id}"), token(session).as_deref(), &body).await {
      Ok(_) => error.set(None),
      Err(e) => error.set(Some(e)),
    }
    version += 1;
  };
  let reset = move |id: Uuid| async move {
    match api::post::<_, OneTimePassword>(&format!("/users/{id}/reset-password"), token(session).as_deref(), &()).await
    {
      Ok(result) => dialog.set(Some(Dialog::Password(result))),
      Err(e) => error.set(Some(e)),
    }
    version += 1;
  };

  rsx! {
    PageHeader {
      title: "Users",
      subtitle: "Accounts that log in with a password. Shared devices at tables and pods use access keys instead.",
      actions: rsx! {
        Button { onclick: move |_| dialog.set(Some(Dialog::Create)), "Add user" }
      },
    }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    match &*users.read() {
      None => rsx! { p { class: "text-sm text-muted", "Loading…" } },
      Some(Err(e)) => rsx! { ErrorBox { error: e.clone() } },
      Some(Ok(list)) => rsx! {
        DataTable {
          columns: vec!["Username".into(), "Name".into(), "Roles".into(), "Status".into(), String::new()],
          rows: list
              .iter()
              .map(|u| {
                  let id = u.id;
                  let disabled = u.disabled;
                  let edit = u.clone();
                  let (tone, status) = if u.disabled {
                      (Tone::Danger, "Disabled")
                  } else if u.must_change_password {
                      (Tone::Warning, "Must change password")
                  } else {
                      (Tone::Success, "Active")
                  };
                  rsx! {
                    tr {
                      td { class: "font-mono", "{u.username}" }
                      td { "{u.display_name}" }
                      td {
                        div { class: "flex flex-wrap gap-1",
                          for role in u.roles.iter() {
                            Badge { tone: Tone::Primary, "{role.label()}" }
                          }
                        }
                      }
                      td {
                        Badge { tone, "{status}" }
                      }
                      td { class: "text-right whitespace-nowrap",
                        Button { variant: ButtonVariant::Secondary, size: ButtonSize::Small, onclick: move |_| dialog.set(Some(Dialog::Edit(edit.clone()))), "Edit" }
                        ConfirmButton {
                          label: "Reset password",
                          variant: ButtonVariant::Warning,
                          title: "Reset {u.username}'s password?",
                          message: "They get a one-time password and are logged out everywhere.",
                          confirm_label: "Reset password",
                          onconfirm: move |()| { spawn(reset(id)); },
                        }
                        if disabled {
                          Button { variant: ButtonVariant::Secondary, size: ButtonSize::Small, onclick: move |_| { spawn(set_disabled(id, false)); }, "Enable" }
                        } else {
                          ConfirmButton {
                            label: "Disable",
                            title: "Disable {u.username}?",
                            message: "They are logged out everywhere and cannot log in until enabled again.",
                            confirm_label: "Disable",
                            onconfirm: move |()| { spawn(set_disabled(id, true)); },
                          }
                        }
                      }
                    }
                  }
              })
              .collect(),
        }
      },
    }
    match dialog() {
      Some(Dialog::Create) => rsx! {
        UserForm {
          user: None,
          onclose: move |()| dialog.set(None),
          oncreated: move |result| {
              version += 1;
              dialog.set(Some(Dialog::Password(result)));
          },
          onsaved: move |()| {},
        }
      },
      Some(Dialog::Edit(user)) => rsx! {
        UserForm {
          user: Some(user),
          onclose: move |()| dialog.set(None),
          oncreated: move |_| {},
          onsaved: move |()| {
              version += 1;
              dialog.set(None);
          },
        }
      },
      Some(Dialog::Password(result)) => rsx! {
        Modal {
          title: "One-time password for {result.user.username}",
          onclose: move |()| dialog.set(None),
          footer: rsx! {
            Button { onclick: move |_| dialog.set(None), "Done" }
          },
          p { class: "mb-3", "Give this to {result.user.display_name}. It is shown only now, and must be changed at first login." }
          p { class: "rounded-control border border-line-strong bg-surface-2 px-4 py-3 text-center font-mono text-2xl tracking-widest", "{result.password}" }
        }
      },
      None => rsx! {},
    }
  }
}

#[component]
fn UserForm(
  user: Option<UserSummary>,
  onclose: EventHandler<()>,
  oncreated: EventHandler<OneTimePassword>,
  onsaved: EventHandler<()>,
) -> Element {
  let session = use_context::<Session>();
  let existing = user.as_ref().map(|u| u.id);
  let mut username = use_signal(|| user.as_ref().map(|u| u.username.clone()).unwrap_or_default());
  let mut display_name = use_signal(|| user.as_ref().map(|u| u.display_name.clone()).unwrap_or_default());
  let mut roles = use_signal(|| user.as_ref().map(|u| u.roles.clone()).unwrap_or_default());
  let mut password = use_signal(String::new);
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut busy = use_signal(|| false);
  // Setting your own password here would end your own login; Settings is the place for that.
  let is_me = matches!(
    session.read(),
    SessionState::Online { identity, .. }
      if matches!(identity.principal, Principal::User { user_id, .. } if Some(user_id) == existing)
  );

  let save = move |_| async move {
    busy.set(true);
    error.set(None);
    let token = token(session);
    if let Some(id) = existing {
      let body = UpdateUserRequest {
        display_name: Some(display_name()),
        roles: Some(roles()),
        disabled: None,
      };
      let saved = match api::patch::<_, UserSummary>(&format!("/users/{id}"), token.as_deref(), &body).await {
        Ok(_) if password().is_empty() => Ok(()),
        Ok(_) => {
          let body = SetPasswordRequest {
            password: Some(password()),
          };
          api::post::<_, OneTimePassword>(&format!("/users/{id}/reset-password"), token.as_deref(), &body)
            .await
            .map(|_| ())
        }
        Err(e) => Err(e),
      };
      match saved {
        Ok(()) => onsaved.call(()),
        Err(e) => error.set(Some(e)),
      }
    } else {
      let chosen = Some(password()).filter(|p| !p.is_empty());
      let body = CreateUserRequest {
        username: username(),
        display_name: display_name(),
        roles: roles(),
        password: chosen.clone(),
      };
      match api::post::<_, OneTimePassword>("/users", token.as_deref(), &body).await {
        Ok(_) if chosen.is_some() => onsaved.call(()),
        Ok(result) => oncreated.call(result),
        Err(e) => error.set(Some(e)),
      }
    }
    busy.set(false);
  };

  rsx! {
    Modal {
      title: if existing.is_some() { "Edit user" } else { "Add user" },
      onclose,
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(()), "Cancel" }
        Button { loading: busy(), disabled: roles().is_empty(), onclick: save, "Save" }
      },
      div { class: "flex flex-col gap-3",
        TextField {
          label: "Username",
          value: username(),
          mono: true,
          disabled: existing.is_some(),
          hint: "Lower-case letters, digits, '.', '_' or '-'.",
          oninput: move |v| username.set(v),
        }
        TextField { label: "Display name", value: display_name(), oninput: move |v| display_name.set(v) }
        if !is_me {
          TextField {
            label: if existing.is_some() { "New password" } else { "Password" },
            r#type: "password",
            value: password(),
            autocomplete: "new-password",
            hint: if existing.is_some() { "Leave empty to keep it. A new one ends the user's other logins." } else { "At least 8 characters. Leave empty for a one-time password they change at first login." },
            oninput: move |v| password.set(v),
          }
        }
        fieldset {
          legend { class: "mb-1 text-sm font-medium", "Roles" }
          if existing.is_some() {
            p { class: "mb-1 text-sm text-muted", "Changing roles logs the user out so their next login has the new roles." }
          }
          div { class: "grid grid-cols-2",
            for role in Role::ALL {
              Checkbox {
                label: role.label(),
                checked: roles().contains(&role),
                onchange: move |on: bool| {
                    roles
                        .with_mut(|r| {
                            r.retain(|x| *x != role);
                            if on {
                                r.push(role);
                            }
                        });
                },
              }
            }
          }
        }
        if let Some(e) = error() {
          ErrorBox { error: e }
        }
      }
    }
  }
}
