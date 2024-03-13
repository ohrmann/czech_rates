import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Получаем ссылку на главное окно.
    if let window = NSApplication.shared.mainWindow {
        // Устанавливаем флаг "isOpaque" в false, чтобы окно могло быть прозрачным.
        window.isOpaque = false
        // Устанавливаем фон окна полностью прозрачным.
        window.backgroundColor = NSColor.clear
        // Опционально, если нужно убрать тень окна.
        window.hasShadow = false
    }

    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}
