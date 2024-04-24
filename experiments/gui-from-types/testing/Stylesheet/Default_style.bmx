Global DEFAULT_STYLESHEET:String = """
// Default Stylesheet

// Define colour scheme
// Material Design Colours
// https://m2.material.io/design/color/the-color-system.html#tools-For-picking-colors

:root {
  --Blue50: #E3F2FD;
  --Blue100: #BBDEFB;
  --Blue200: #90CAF9;
  --Blue300: #64B5F6;
  --Blue400: #42A5F5;
  --Blue500: #2196F3;
  --Blue600: #1E88E5;
  --Blue700: #1976D2;
  --Blue800: #1565C0;
  --Blue900: #0D47A1;
}
* {
  margin: 5;
  padding: 1;
}
TPanel {
	background-color: --Blue50;
	color: --white;
}
TButton {
	background-color: --Blue900;
	color: --white;
}
"""