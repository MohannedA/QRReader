/*
 QRScannerViewController
 */
import AVFoundation
import UIKit
import SnapKit

// MARK: ~ QRScannerDelegate
protocol QRScannerDelegate: class {
    /*To get the string code value*/
    func getCodeStringValue(_ codeStringValue: String)
    /*To set the preview view of the code scanner*/
    func setPreviewView() -> UIView
    /*To draw bounding squa res*/
    func drawBoundingSquares(codeStringValue: String) -> (label: String?, labelPosition: SquareLabelPositions, color: CGColor?)
}

// MARK: ~ SquareLabelPositions Enum
enum SquareLabelPositions: String {
    case Top, Center, Bottom
}


open class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: ~ Variables
    var video = AVCaptureVideoPreviewLayer()
    var previewView = UIView()
    // Define square view variables.
    var squareView = UIView()
    var squareLabel: String?
    var squareLabelPosition: SquareLabelPositions = .Top
    var squareColor: CGColor?
    
    // Define delegate variable.
    weak var delegate: QRScannerDelegate?
    
    // MARK: ~ Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Create session.
        let session = AVCaptureSession()
        
        // Define capture devcie.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Set up the input of the QR scanner.
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        }
        catch
        {
            print ("QR scanner cannot get the input.")
        }
        
        // Set up the output of the QR scanner.
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Add the set session to the preview layer.
        video = AVCaptureVideoPreviewLayer(session: session)
        // Set the preview view.
        previewView = (delegate?.setPreviewView())!
        // Make the video(preview view) size = the main view size.
        video.frame = previewView.layer.bounds
        // Add the created viedo(preview view) to the main view.
        previewView.layer.addSublayer(video)
        
        // Start running the camera.
        session.startRunning()
    }
    
    // MARK: ~ QR Scanner Methods
    open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        cleanScreen(superView: self.previewView) // Clear from the old bounding squares.
        // If there is a code.
        if metadataObjects != nil && metadataObjects.count != 0
        {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                // If the detected code is QR code.
                if object.type == AVMetadataObjectTypeQRCode
                {
                    // Use the code stringValue.
                    delegate?.getCodeStringValue(object.stringValue)
                    let barCodeObject = self.video.transformedMetadataObject(for: object)
                    setSquareView(code: object, barCodeObject: barCodeObject!) // The code bounding square.
                }
            }
        }
    }
    
    // MARK: ~ Private Methods
    private func cleanScreen(superView: UIView) {
        for view in superView.subviews {
            view.removeFromSuperview()
        }
    }
    
    private func setSquareView(code: AVMetadataMachineReadableCodeObject, barCodeObject: AVMetadataObject) {
        // Initialize square view to highlight the QR code.
        squareView = UIView()
        previewView.addSubview(squareView)
        squareView.layer.borderWidth = 2
        squareView.frame = barCodeObject.bounds
        // Get square properties.
        (squareLabel, squareLabelPosition, squareColor) = (delegate?.drawBoundingSquares(codeStringValue: code.stringValue))!
        // Set up the square label if there is.
        if squareLabel != "" {
            let label = UILabel()
            label.text = squareLabel
            previewView.addSubview(label)
            // Set up the label position.
            switch squareLabelPosition {
            case .Top:
                label.snp.makeConstraints{(make) in
                    make.top.equalTo(squareView.snp.top).offset(-25)
                    make.centerX.equalTo(squareView.snp.centerX)
                }
            case .Center:
                label.snp.makeConstraints{(make) in
                    make.centerY.equalTo(squareView.snp.centerY)
                    make.centerX.equalTo(squareView.snp.centerX)
                }
            case .Bottom:
                label.snp.makeConstraints{(make) in
                    make.bottom.equalTo(squareView.snp.bottom).offset(25)
                    make.centerX.equalTo(squareView.snp.centerX)
                }
            }
            
        }
        // Set up the new sqaure color if there is, otherwise set the default color.
        squareView.layer.borderColor = squareColor ?? UIColor.darkGray.cgColor
        // Add the created square view to the preview view.
        previewView.bringSubview(toFront: squareView)
    }
}
