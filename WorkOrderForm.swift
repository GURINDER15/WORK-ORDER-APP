
import SwiftUI
import PDFKit

struct WorkOrderForm: View {
    @State private var companyName = ""
    @State private var nameOnDoor = ""
    @State private var city = ""
    @State private var phone = ""
    @State private var unit = ""
    @State private var licensePlate = ""
    @State private var odometer = ""
    @State private var vin = ""
    @State private var address = ""
    @State private var province = ""
    @State private var postalCode = ""
    @State private var email = ""
    @State private var workOrderNumber = ""
    @State private var invoiceNumber = ""
    @State private var date = Date()
    @State private var contactName = ""
    @State private var makeYearModel = ""
    @State private var complaintInstructions = ""
    @State private var showMailAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customer Info")) {
                    TextField("Company Name", text: $companyName)
                    TextField("Name on Door", text: $nameOnDoor)
                    TextField("City", text: $city)
                    TextField("Phone", text: $phone)
                    TextField("Unit", text: $unit)
                }

                Section(header: Text("Vehicle Info")) {
                    TextField("License Plate", text: $licensePlate)
                    TextField("Odometer", text: $odometer)
                    TextField("VIN #", text: $vin)
                    TextField("Make-Year-Model", text: $makeYearModel)
                }

                Section(header: Text("Contact & Address")) {
                    TextField("Address", text: $address)
                    TextField("Province", text: $province)
                    TextField("Postal Code", text: $postalCode)
                    TextField("Email", text: $email)
                    TextField("Contact Name", text: $contactName)
                }

                Section(header: Text("Work Order Details")) {
                    TextField("Work Order #", text: $workOrderNumber)
                    TextField("Invoice No.", text: $invoiceNumber)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextEditor(text: $complaintInstructions)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                }

                Button("Submit Work Order") {
                    exportAsPDF()
                    sendEmail()
                    saveLocally()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .alert(isPresented: $showMailAlert) {
                    Alert(title: Text("Email Sent"), message: Text("Your work order has been emailed."), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Work Order Form")
        }
    }

    func exportAsPDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "WorkOrderApp",
            kCGPDFContextAuthor: "User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()
            let text = "Work Order\n\nCompany: \(companyName)\nName: \(nameOnDoor)\nCity: \(city)\nPhone: \(phone)\nUnit: \(unit)\nLicense Plate: \(licensePlate)\nOdometer: \(odometer)\nVIN: \(vin)\nAddress: \(address)\nProvince: \(province)\nPostal Code: \(postalCode)\nEmail: \(email)\nContact Name: \(contactName)\nWork Order #: \(workOrderNumber)\nInvoice #: \(invoiceNumber)\nDate: \(date)\nComplaint: \(complaintInstructions)"
            text.draw(in: CGRect(x: 20, y: 20, width: pageRect.width - 40, height: pageRect.height - 40), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("WorkOrder.pdf")
        try? data.write(to: url)
    }

    func sendEmail() {
        // In a real app, you would use MFMailComposeViewController here
        // Placeholder logic:
        showMailAlert = true
    }

    func saveLocally() {
        let workOrderData = "\(Date()): \(companyName), \(workOrderNumber)"
        let filename = FileManager.default.temporaryDirectory.appendingPathComponent("WorkOrders.txt")
        if FileManager.default.fileExists(atPath: filename.path) {
            if let handle = try? FileHandle(forWritingTo: filename) {
                handle.seekToEndOfFile()
                if let data = ("\n" + workOrderData).data(using: .utf8) {
                    handle.write(data)
                }
                handle.closeFile()
            }
        } else {
            try? workOrderData.write(to: filename, atomically: true, encoding: .utf8)
        }
    }
}

struct WorkOrderForm_Previews: PreviewProvider {
    static var previews: some View {
        WorkOrderForm()
    }
}
