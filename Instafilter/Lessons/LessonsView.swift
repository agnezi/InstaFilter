////
// Instafilter
// Created by: itsjagnezi on 09/11/22
// Copyright (c) today and beyond
//

import SwiftUI

struct LessonsView: View {
	
	@State private var blurAmount = 0.0
	
    var body: some View {
			VStack{
				Text("Olha o blur ai")
					.blur(radius: blurAmount)
					.onChange(of: blurAmount) { newValue in
						print("Olha o blur mudando ai \(newValue)")
					}
				
				Slider(value: $blurAmount, in: 0...20)
			}
    }
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView()
    }
}
