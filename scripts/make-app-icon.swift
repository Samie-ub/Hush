import AppKit
import CoreGraphics
import Foundation

let output = CommandLine.arguments.dropFirst().first ?? "resources/hush.iconset"
let iconset = URL(fileURLWithPath: output, isDirectory: true)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(red: red, green: green, blue: blue, alpha: alpha)
}

func drawIcon(size: Int) throws -> Data {
    guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
        let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "HushIcon", code: 1)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    let cg = context.cgContext
    let scale = CGFloat(size) / 1024
    cg.scaleBy(x: scale, y: scale)
    cg.setAllowsAntialiasing(true)
    cg.setShouldAntialias(true)
    cg.setLineCap(.round)
    cg.setLineJoin(.round)

    cg.setFillColor(color(0.075, 0.12, 0.15))
    cg.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: 1024, height: 1024),
                      cornerWidth: 220, cornerHeight: 220, transform: nil))
    cg.fillPath()

    // A crescent and a quiet star give hush a simple mark that survives at 16 px.
    cg.setFillColor(color(0.46, 0.94, 0.72))
    let moon = CGRect(x: 215, y: 240, width: 520, height: 520)
    cg.fillEllipse(in: moon)
    cg.saveGState()
    cg.addEllipse(in: moon)
    cg.clip()
    cg.setFillColor(color(0.075, 0.12, 0.15))
    cg.fillEllipse(in: CGRect(x: 350, y: 350, width: 480, height: 480))
    cg.restoreGState()

    let star = CGMutablePath()
    star.move(to: CGPoint(x: 755, y: 765))
    star.addQuadCurve(to: CGPoint(x: 805, y: 715), control: CGPoint(x: 764, y: 724))
    star.addQuadCurve(to: CGPoint(x: 755, y: 665), control: CGPoint(x: 764, y: 706))
    star.addQuadCurve(to: CGPoint(x: 705, y: 715), control: CGPoint(x: 746, y: 706))
    star.addQuadCurve(to: CGPoint(x: 755, y: 765), control: CGPoint(x: 746, y: 724))
    star.closeSubpath()
    cg.setFillColor(color(0.92, 0.98, 0.95))
    cg.addPath(star)
    cg.fillPath()
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "HushIcon", code: 2)
    }
    return data
}

let variants: [(String, Int)] = [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024)
]
for (name, size) in variants {
    try drawIcon(size: size).write(to: iconset.appendingPathComponent(name), options: .atomic)
}
// Hush Mode extension icons are generated separately by make-focus-icons.swift.

let catalog: [[String: String]] = [
    ["filename": "icon_16x16.png", "idiom": "mac", "scale": "1x", "size": "16x16"],
    ["filename": "icon_16x16@2x.png", "idiom": "mac", "scale": "2x", "size": "16x16"],
    ["filename": "icon_32x32.png", "idiom": "mac", "scale": "1x", "size": "32x32"],
    ["filename": "icon_32x32@2x.png", "idiom": "mac", "scale": "2x", "size": "32x32"],
    ["filename": "icon_128x128.png", "idiom": "mac", "scale": "1x", "size": "128x128"],
    ["filename": "icon_128x128@2x.png", "idiom": "mac", "scale": "2x", "size": "128x128"],
    ["filename": "icon_256x256.png", "idiom": "mac", "scale": "1x", "size": "256x256"],
    ["filename": "icon_256x256@2x.png", "idiom": "mac", "scale": "2x", "size": "256x256"],
    ["filename": "icon_512x512.png", "idiom": "mac", "scale": "1x", "size": "512x512"],
    ["filename": "icon_512x512@2x.png", "idiom": "mac", "scale": "2x", "size": "512x512"]
]
let json: [String: Any] = ["images": catalog, "info": ["author": "xcode", "version": 1]]
let metadata = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
try metadata.write(to: iconset.appendingPathComponent("Contents.json"), options: .atomic)

func appendBigEndian(_ value: UInt32, to data: inout Data) {
    data.append(UInt8((value >> 24) & 0xff))
    data.append(UInt8((value >> 16) & 0xff))
    data.append(UInt8((value >> 8) & 0xff))
    data.append(UInt8(value & 0xff))
}

let chunks: [(String, String)] = [
    ("icp4", "icon_16x16.png"), ("icp5", "icon_32x32.png"),
    ("icp6", "icon_32x32@2x.png"), ("ic07", "icon_128x128.png"),
    ("ic08", "icon_256x256.png"), ("ic09", "icon_512x512.png"),
    ("ic10", "icon_512x512@2x.png")
]
var payload = Data()
for (type, filename) in chunks {
    let image = try Data(contentsOf: iconset.appendingPathComponent(filename))
    payload.append(contentsOf: type.utf8)
    appendBigEndian(UInt32(image.count + 8), to: &payload)
    payload.append(image)
}
var icns = Data("icns".utf8)
appendBigEndian(UInt32(payload.count + 8), to: &icns)
icns.append(payload)
try icns.write(to: iconset.deletingLastPathComponent().appendingPathComponent("hush.icns"), options: .atomic)
