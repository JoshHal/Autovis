import SwiftUI
import VisionKit
import Vision


struct ContentView: View {
    @State private var showScanner = false
    @State private var texts: [Scandata] = []

    var body: some View {
        NavigationView {
            VStack {
                Text("AutoVis")
                    .font(.title)
                    .navigationBarItems(trailing: Button(action: {
                        self.showScanner = true
                    }, label: {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.title2)
                    }))
                if texts.count > 0 {
                    List {
                        ForEach(texts) { text in
                            NavigationLink(destination: ScrollView {
                                Text(text.content)
                            }, label: {
                                Text(text.content).lineLimit(1)
                            })
                        }
                    }
                } else {
                    Text("No scan result yet")
                        .font(.title)
                    Text("But don't fret")
                        .font(.title)
                }
            }
            .padding()
            .navigationTitle("AutoVis") // This line sets the navigation title
            .sheet(isPresented: $showScanner, content: {
                makeScannerView()
            })
        }
    }
    private func makeScannerView() -> Scannerview{
        Scannerview(completion: { textPerPage in
            if let outputText = textPerPage?.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines) {
                let newScanData = Scandata(content: outputText)
                apiRequest(inputString: newScanData) { responseString in
                    if let responseString = responseString {
                        self.texts.append(Scandata(content: responseString))
                    } else {
                        print("Error: Failed to get response")
                        // Handle the error
                    }
                }
            }
            self.showScanner = false
        })
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func apiRequest(inputString: Scandata, completion: @escaping (String?) -> Void) {
    // Define the question
    let question = inputString.content

        // Create the URL with the question as a query parameter
        var encodedQuestion = question.replacingOccurrences(
            of: "[^><+-]",
            with: "",
            options: .regularExpression
        )
        encodedQuestion = question.replacingOccurrences(of: ">", with: "%3E")
        encodedQuestion = encodedQuestion.replacingOccurrences(of: " ", with: "%20")
        let apiUrlString = "https://fun.rawin1.repl.co/bard/\(encodedQuestion)"
        
        
        guard let apiUrl = URL(string: apiUrlString) else {// Debug print statement
            completion(nil)
            return
        }

    // Create a URLRequest with the URL
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "GET"

    // Create a URLSession and data task
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
        // Handle the response or error
        if let error = error {
            print("Error: \(error)")
            completion(nil)
            return
        }

        // Check the response status code
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
        }

        // Handle the response data
        if let data = data {
            // Convert response data to a string
            if let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
                return
            }
        }

        completion(nil)
    }

    // Start the data task
    task.resume()
}
