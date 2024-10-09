int convertGpToInt(String gp) {
  int v = 2;

  switch (gp) {
    case "2 - Developing":
      v = 2;
      break;
    case "3 - Accomplished":
      v = 3;
      break;
    case "4 - Exceeds":
      v = 4;
      break;
    default:
      v = 2;
  }

  return v;
}
