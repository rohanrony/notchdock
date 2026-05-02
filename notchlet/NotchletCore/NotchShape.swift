import SwiftUI

struct NotchShape: Shape {
    var cornerRadius: CGFloat
    let blendRadius: CGFloat = 12
    
    var animatableData: CGFloat {
        get { cornerRadius }
        set { cornerRadius = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let r = cornerRadius
        let br = blendRadius
        
        path.move(to: CGPoint(x: 0, y: 0))
        // Top-left inverted curve
        path.addArc(center: CGPoint(x: 0, y: br), radius: br, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        // Left edge
        path.addLine(to: CGPoint(x: br, y: h - r))
        
        // Bottom-left curve
        path.addArc(center: CGPoint(x: br + r, y: h - r), radius: r, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: true)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: w - br - r, y: h))
        
        // Bottom-right curve
        path.addArc(center: CGPoint(x: w - br - r, y: h - r), radius: r, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0), clockwise: true)
        
        // Right edge
        path.addLine(to: CGPoint(x: w - br, y: br))
        
        // Top-right inverted curve
        path.addArc(center: CGPoint(x: w, y: br), radius: br, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: -90), clockwise: false)
        
        path.closeSubpath()
        return path
    }
}
