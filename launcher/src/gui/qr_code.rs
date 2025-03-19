use egui::ColorImage;
use qrcodegen::QrCode;

pub fn qr_to_image(qr: &QrCode, scale: usize) -> ColorImage {
  let size = qr.size() as usize;
  let scaled_size = size * scale;

  // Create a white background with black QR code squares
  let mut pixels = vec![egui::Color32::WHITE; scaled_size * scaled_size];

  // Fill in the black squares
  for y in 0..size {
    for x in 0..size {
      if qr.get_module(x as i32, y as i32) {
        // Fill in a scale×scale block for each QR module
        for dy in 0..scale {
          for dx in 0..scale {
            let idx = (y * scale + dy) * scaled_size + (x * scale + dx);
            pixels[idx] = egui::Color32::BLACK;
          }
        }
      }
    }
  }

  ColorImage::from_rgba_unmultiplied(
    [scaled_size, scaled_size],
    &pixels.iter().flat_map(|c| c.to_array()).collect::<Vec<_>>(),
  )
}
