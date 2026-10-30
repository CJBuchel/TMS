//! The join URL as a QR code: an image for the window, and SVG for printing.

use eframe::egui::{Color32, ColorImage};
use qrcode::{Color, QrCode};

/// Each module is `scale` pixels, with a four-module quiet zone.
pub fn image(url: &str, scale: usize) -> Option<ColorImage> {
  let code = QrCode::new(url.as_bytes()).ok()?;
  let width = code.width();
  let quiet = 4;
  let side = (width + 2 * quiet) * scale;
  let mut pixels = vec![Color32::WHITE; side * side];
  for (i, color) in code.to_colors().into_iter().enumerate() {
    if color == Color::Dark {
      let (x, y) = ((i % width + quiet) * scale, (i / width + quiet) * scale);
      for dy in 0..scale {
        for dx in 0..scale {
          pixels[(y + dy) * side + x + dx] = Color32::BLACK;
        }
      }
    }
  }
  Some(ColorImage::new([side, side], pixels))
}

pub fn svg(url: &str) -> Option<String> {
  let code = QrCode::new(url.as_bytes()).ok()?;
  Some(
    code
      .render::<qrcode::render::svg::Color<'_>>()
      .min_dimensions(400, 400)
      .build(),
  )
}
