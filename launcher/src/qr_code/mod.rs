use egui::ColorImage;
use qrcodegen::QrCode;

pub fn to_svg_string(qr: &QrCode, border: i32) -> String {
  assert!(border >= 0, "Border must be non-negative");
  let mut result = String::new();
  result += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
  result += "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n";
  let dimension = qr.size().checked_add(border.checked_mul(2).unwrap()).unwrap();
  result += &format!(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" viewBox=\"0 0 {0} {0}\" stroke=\"none\">\n",
    dimension
  );
  result += "\t<rect width=\"100%\" height=\"100%\" fill=\"#FFFFFF\"/>\n";
  result += "\t<path d=\"";
  for y in 0..qr.size() {
    for x in 0..qr.size() {
      if qr.get_module(x, y) {
        if x != 0 || y != 0 {
          result += " ";
        }
        result += &format!("M{},{}h1v1h-1z", x + border, y + border);
      }
    }
  }
  result += "\" fill=\"#000000\"/>\n";
  result += "</svg>\n";
  result
}

pub fn print_qr(qr: &QrCode) {
  let border: i32 = 4;
  for y in -border..qr.size() + border {
    for x in -border..qr.size() + border {
      let c: char = if qr.get_module(x, y) { '█' } else { ' ' };
      print!("{0}{0}", c);
    }
    println!();
  }
  println!();
}

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
