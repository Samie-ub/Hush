import AppKit
import CoreGraphics

// The extension uses the same crescent mark as the macOS app.
let directory = URL(fileURLWithPath: "browser-extension", isDirectory: true)
for size in [16, 32, 48, 128] {
    guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
        let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fatalError("Cannot create Hush Mode icon bitmap")
    }
    let cg = context.cgContext
    let scale = CGFloat(size) / 1024
    cg.scaleBy(x: scale, y: scale)
    cg.setFillColor(CGColor(red: 0.075, green: 0.12, blue: 0.15, alpha: 1))
    cg.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: 1024, height: 1024),
                      cornerWidth: 220, cornerHeight: 220, transform: nil))
    cg.fillPath()
    let mint = CGColor(red: 0.46, green: 0.94, blue: 0.72, alpha: 1)
    cg.setFillColor(mint)
    let moon = CGRect(x: 215, y: 240, width: 520, height: 520)
    cg.fillEllipse(in: moon)
    cg.saveGState()
    cg.addEllipse(in: moon)
    cg.clip()
    cg.setFillColor(CGColor(red: 0.075, green: 0.12, blue: 0.15, alpha: 1))
    cg.fillEllipse(in: CGRect(x: 350, y: 350, width: 480, height: 480))
    cg.restoreGState()
    let star = CGMutablePath()
    star.move(to: CGPoint(x: 755, y: 765))
    star.addQuadCurve(to: CGPoint(x: 805, y: 715), control: CGPoint(x: 764, y: 724))
    star.addQuadCurve(to: CGPoint(x: 755, y: 665), control: CGPoint(x: 764, y: 706))
    star.addQuadCurve(to: CGPoint(x: 705, y: 715), control: CGPoint(x: 746, y: 706))
    star.addQuadCurve(to: CGPoint(x: 755, y: 765), control: CGPoint(x: 746, y: 724))
    star.closeSubpath()
    cg.setFillColor(CGColor(red: 0.92, green: 0.98, blue: 0.95, alpha: 1))
    cg.addPath(star)
    cg.fillPath()
    context.flushGraphics()
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Cannot encode Hush Mode icon")
    }
    try data.write(to: directory.appendingPathComponent("icon\(size).png"), options: .atomic)
}
