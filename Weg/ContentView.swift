//
//  ContentView.swift
//  Weg
//
//  Created by Andre on 25.11.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        List {
            ForEach(vm.courses, id: \.id) { course in
                HStack {
                    AsyncImage(url: course.imageURL) { phase in
                        if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } else if phase.error != nil {
                            ZStack {
                                Color.red // Indicates an error.
                                    .frame(width: 100, height: 100)
                            }
                        
                        } else {
                            Color.blue // Acts as a placeholder.
                                .frame(width: 100, height: 100)
                        }
                    }
                    Text(course.name)
                }
            }
        }
        .task {
            await vm.loadCourses()
        }
        .scrollContentBackground(.hidden)
        .background(.green.gradient)
    }
}

@MainActor
class ViewModel: ObservableObject {
    @Published var courses: [Course] = []
    
    func loadCourses() async {
        let urlString = "https://api.letsbuildthatapp.com/jsondecodable/courses"
        guard let url = URL(string: urlString) else {
            return
        }
        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            let respose = resp as? HTTPURLResponse
            if respose?.statusCode == 200 {
                let json = try JSONDecoder().decode([Course].self, from: data)
                self.courses = json
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
}



struct Course: Codable {
  let id: Int
  let name: String
  let link: URL
  let imageURL: URL
  let numberOfLessons: Int

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case link
    case imageURL = "imageUrl"
    case numberOfLessons
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
