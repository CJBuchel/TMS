use dioxus::prelude::*;

/// Table with a sticky header. Rows are passed as already-rendered `tr` elements.
#[component]
pub fn DataTable(columns: Vec<String>, #[props(default)] empty: String, rows: Vec<Element>) -> Element {
  let is_empty = rows.is_empty();
  let span = columns.len().to_string();
  rsx! {
    div { class: "overflow-x-auto rounded-panel border border-line bg-surface",
      table { class: "w-full border-collapse text-sm",
        thead { class: "sticky top-0 bg-surface-2",
          tr {
            for c in columns {
              th { class: "border-b border-line px-3 py-2.5 text-left text-xs font-semibold text-muted", "{c}" }
            }
          }
        }
        tbody { class: "[&>tr]:border-b [&>tr]:border-line [&>tr:last-child]:border-b-0 [&>tr:hover]:bg-surface-2/60 [&_td]:px-3 [&_td]:py-2 [&_td]:tabular-nums",
          if is_empty {
            tr {
              td { colspan: "{span}", class: "py-6 text-center text-muted", "{empty}" }
            }
          }
          for row in rows {
            {row}
          }
        }
      }
    }
  }
}
