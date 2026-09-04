# Build and install Typeface 955 personal build on Windows

## 1. Open the project

1. Extract the ZIP.
2. In Visual Studio Code choose **File > Open Folder**.
3. Open the repository folder containing `monkey.jungle`.
4. Make sure Garmin's official **Monkey C** extension is installed.
5. Run **Monkey C: Verify Installation** from the Command Palette.

## 2. Verify the developer key path

The build command must point `-y` at your actual private developer-key file. If the key was moved, update **Monkey C > Developer Key Path** in VS Code Settings before building.

## 3. Run in the simulator

1. Press `Ctrl+F5` or choose **Run > Run Without Debugging**.
2. Select **Forerunner 955 / 955 Solar (`fr955`)**.
3. Confirm the face stays visible continuously.
4. Open the watch-face settings flow.
5. Verify the live editor: UP/DOWN changes the selected setting; START cycles the value; the face updates immediately.

Test:

- all five fonts in order: Smackers, Nautica, Cleo, Pincoya, Alien
- all four date sizes
- all four battery sizes
- percent symbol on/off
- time/date/battery/background colors
- edge times such as `0000`, `0444`, `1111`, and `2359`
- battery values `0`, `9`, `99`, and `100`

Time is fixed to 24-hour `HHMM` and the battery stays in the balanced position.

## 4. Build a sideloaded PRG

1. Open the Command Palette (`Ctrl+Shift+P`).
2. Run **Monkey C: Build for Device**.
3. Select `fr955`.
4. Choose your private developer key if prompted.
5. Copy the resulting `.prg` to the watch's `GARMIN\\APPS` folder over USB, safely eject, and disconnect.

## 5. Configure on the watch

1. Hold **UP / MENU**.
2. Open **Watch Face**.
3. Highlight **Typeface 955** and press **START**.
4. Choose **Customize** or **Settings**.
5. Use **UP/DOWN** to move between settings and **START** to cycle the current value while seeing the result live.
6. Press **BACK** when finished.
