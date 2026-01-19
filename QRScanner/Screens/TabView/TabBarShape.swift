import SwiftUI


struct TabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Параметры выреза
        let cutoutRadius: CGFloat = 43
        let cornerRadius: CGFloat = 16 // Радиус скругления углов
        
        // Начинаем с левого верхнего угла
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Левая часть до выреза
        let leftCurveStart = width / 2 - cutoutRadius - cornerRadius
        path.addLine(to: CGPoint(x: leftCurveStart, y: 0))
        
        // Небольшое скругление слева перед дугой
        path.addArc(
            tangent1End: CGPoint(x: width / 2 - cutoutRadius, y: 0),
            tangent2End: CGPoint(x: width / 2 - cutoutRadius, y: cornerRadius),
            radius: cornerRadius
        )
        
        // Главная дуга выреза
        path.addArc(
            center: CGPoint(x: width / 2, y: 0),
            radius: cutoutRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )
        
        // Небольшое скругление справа после дуги
        path.addArc(
            tangent1End: CGPoint(x: width / 2 + cutoutRadius, y: 0),
            tangent2End: CGPoint(x: width / 2 + cutoutRadius + cornerRadius, y: 0),
            radius: cornerRadius
        )
        
        // Правая часть
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        path.closeSubpath()
        
        return path
    }
}
