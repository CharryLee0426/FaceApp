//
//  ContentView.swift
//  FaceApp
//
//  Created by 李晨 on 2022/8/19.
//

import SwiftUI
import Vision

struct ContentView: View {
    let photoArray = ["darkwoman", "woman", "twomen", "ruhuilin", "lyb", "lc", "party", "helloworld", "title"]
    @State var message = ""
    @State var arrayIndex = 0
    @State var newImage: UIImage = UIImage(named: "darkwoman")!
    
    var body: some View {
        VStack {
            Image(uiImage: newImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 500, height: 500)
            
            Text(message)
                .padding()
            
            Button {
//                analyzeFaces(image: UIImage(named: photoArray[arrayIndex])!)
//                identifyFacesWithLandmarks(image: UIImage(named: photoArray[arrayIndex])!)
                analyzeText(image: UIImage(named: photoArray[arrayIndex])!)
            } label: {
                Text("Analyze Image")
            }.padding()
            
            HStack {
                Button {
                    if arrayIndex == 0 {
                        arrayIndex = photoArray.count - 1
                    } else {
                        arrayIndex -= 1
                    }
                    newImage = UIImage(named: photoArray[arrayIndex])!
                    message = ""
                } label: {
                    Image(systemName: "chevron.left.square.fill")
                }
                
                Button {
                    if arrayIndex == photoArray.count - 1 {
                        arrayIndex = 0
                    } else {
                        arrayIndex += 1
                    }
                    newImage = UIImage(named: photoArray[arrayIndex])!
                    message = ""
                } label: {
                    Image(systemName: "chevron.right.square.fill")
                }
            }
        }
    }
    
    // just detect faces
    func handleFaceRecognition(request: VNRequest, error: Error?) {
        guard let foundFaces = request.results as? [VNFaceObservation] else {
            fatalError("Cannot find a face in the picture.")
        }
        message = "Found \(foundFaces.count) faces in the picture"
    }
    
    func analyzeFaces(image: UIImage) {
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNDetectFaceRectanglesRequest(completionHandler: handleFaceRecognition)
        try! handler.perform([request])
    }
    
    // defect faces and draw a rectangle to the face
    func drawImage(source: UIImage, boundary: CGRect, faceLandmarkRegions: [VNFaceLandmarkRegion2D]) {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setLineJoin(.bevel)
        context.setLineCap(.square)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rect = CGRect(x: 0, y: 0, width: source.size.width, height: source.size.height)
        context.draw(source.cgImage!, in: rect)
        
        let fillColor = UIColor.red
        fillColor.setStroke()
        fillColor.setFill()
        
        let rectangleWidth = source.size.width * boundary.size.width
        let rectangleHeight = source.size.height * boundary.size.height
        let radius = (pow(rectangleWidth, 2)+pow(rectangleHeight, 2)).squareRoot() / 2
        
        print(source.size.width)
        print(source.size.height)
        print(boundary.size.width)
        print(boundary.size.height)
        
        context.setLineWidth(24)
        context.addRect(CGRect(x: boundary.origin.x * source.size.width, y: boundary.origin.y * source.size.height, width: rectangleWidth, height: rectangleHeight))
//        context.addArc(center: CGPoint(x: (boundary.origin.x * source.size.width + rectangleWidth/2), y: (boundary.origin.y * source.size.height + rectangleHeight/2)), radius: radius, startAngle: deg2rad(0), endAngle: deg2rad(180), clockwise: true)
//        context.addArc(center: CGPoint(x: (boundary.origin.x * source.size.width + rectangleWidth/2), y: (boundary.origin.y * source.size.height + rectangleHeight/2)), radius: radius, startAngle: deg2rad(180), endAngle: deg2rad(360), clockwise: true)
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
        let modifiedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        newImage = modifiedImage
    }
    
    func handleFaceLandmarksRecognition(request: VNRequest, error: Error?) {
        guard let foundFaces = request.results as? [VNFaceObservation] else {
            fatalError("Problem loading picture to examine faces")
        }
        
        message = "Found \(foundFaces.count) faces in the picture"
        
        for faceRectangle in foundFaces {
            let landmarkRegions: [VNFaceLandmarkRegion2D] = []
            drawImage(source: newImage, boundary: faceRectangle.boundingBox, faceLandmarkRegions: landmarkRegions)
        }
    }
    
    func identifyFacesWithLandmarks(image: UIImage) {
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNDetectFaceLandmarksRequest(completionHandler: handleFaceLandmarksRecognition)
        try! handler.perform([request])
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    func analyzeText(image: UIImage) {
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNRecognizeTextRequest(completionHandler: handleTextRecRecognition)
//        request.recognitionLanguages = ["zh-Hans", "English"]
        try! handler.perform([request])
    }
    
    func handleTextRecRecognition(request: VNRequest, error: Error?) {
        guard let foundTexts = request.results as? [VNRecognizedTextObservation] else {
            fatalError("Cannot find any text")
        }
        
        for eachText in foundTexts {
            message.append(contentsOf: "\(eachText.topCandidates(1)[0].string)\n")
            let landmarkRegions: [VNFaceLandmarkRegion2D] = []
            drawImage(source: newImage, boundary: eachText.boundingBox, faceLandmarkRegions: landmarkRegions)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
