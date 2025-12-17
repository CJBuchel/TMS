use egui::ColorImage;
use qrcodegen::QrCode;

fn i32_to_usize(num: i32) -> usize {
  usize::try_from(num).unwrap_or_default()
}

fn usize_to_i32(num: usize) -> i32 {
  i32::try_from(num).unwrap_or_default()
}

pub fn qr_to_image(qr: &QrCode, scale: usize) -> ColorImage {
  let size = i32_to_usize(qr.size());
  let scaled_size = size * scale;

  // Create a white background with black QR code squares
  let mut pixels = vec![egui::Color32::WHITE; scaled_size * scaled_size];

  // Fill in the black squares
  for y in 0..size {
    for x in 0..size {
      if qr.get_module(usize_to_i32(x), usize_to_i32(y)) {
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
    &pixels.iter().flat_map(egui::Color32::to_array).collect::<Vec<_>>(),
  )
}
