////
// Instafilter
// Created by: itsjagnezi on 09/11/22
// Copyright (c) today and beyond
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
	@State private var filterIntensity = 1.0
	@State private var filterRadius = 1.0
	@State private var filterScale = 1.0
	@State private var filterWidth = 1.0
	@State private var filterRefraction = 1.0
	@State private var filterCenter = 1.0
	
	@State private var filterMultiplier = 1
	
	@State private var image: Image?
	@State private var showingImagePicker = false
	@State private var inputImage: UIImage?
	@State private var currentFilter: CIFilter = CIFilter.sepiaTone()
	
	let context = CIContext()
	
	@State private var showingFilterSheet = false
	
	@State private var processedImage: UIImage?
	
	
	var body: some View {
		NavigationView{
			ScrollView(.vertical) {
				
				
				VStack {
					ZStack {
						Rectangle()
							.fill(.secondary)
							.frame(height: 300)
							
						
						Text("Tap to select a picture")
							.foregroundColor(.white)
							.font(.headline)
						
						image?
							.resizable()
							.scaledToFit()
					}
					.onTapGesture {
						showingImagePicker = true
					}
					
					VStack{
						
						Text(currentFilter.inputKeys.joined(separator: ","))
						
						Picker("Multiplier", selection: $filterMultiplier) {
							ForEach(0..<100) {
								Text($0, format: .number)
							}
						}.pickerStyle(.wheel)
						
						Group {
							
							
							Text("Itensity")
							Slider(value: $filterIntensity)
								.onChange(of: filterIntensity) { _ in
									applyProcessing()
								}
							
							
							Text("Radius")
							Slider(value: $filterRadius)
								.onChange(of: filterRadius) { _ in
									applyProcessing()
								}
							
							Text("Scale")
							Slider(value: $filterScale)
								.onChange(of: filterScale) { _ in
									applyProcessing()
								}
							
							Text("Width")
							Slider(value: $filterWidth)
								.onChange(of: filterWidth) { _ in
									applyProcessing()
								}
							
							Text("Refraction")
							Slider(value: $filterRefraction)
								.onChange(of: filterRefraction) { _ in
									applyProcessing()
								}
						}
						
						Group {
							Text("Center")
							Slider(value: $filterCenter, in: 0...100)
								.onChange(of: filterCenter) { _ in
									applyProcessing()
								}
							
						}
					}
					.padding(.vertical)
					
					HStack{
						Button("Change Filter") {
							showingFilterSheet = true
						}
						
						Spacer()
						
						Button("Save") {
							save()
						}
						.disabled(inputImage != nil ? false : true)
					}
				}
				.padding([.horizontal, .bottom])
				.navigationTitle("Instafilter")
				.onChange(of: inputImage) { _ in
					loadImage()
				}
				.sheet(isPresented: $showingImagePicker) {
					ImagePicker(image: $inputImage)
				}
				.confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
					Group {
						
						Button("Crystallize") { setFilter(CIFilter.crystallize()) }
						Button("Edges") { setFilter(CIFilter.edges()) }
						Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
						Button("Pixellate") { setFilter(CIFilter.pixellate()) }
						Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
						Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
					}
					
					Group {
						Button("Vignette") { setFilter(CIFilter.vignette()) }
						Button("Hole Distortion") { setFilter(CIFilter.holeDistortion()) }
						Button("Torus Lens") { setFilter(CIFilter.torusLensDistortion()) }
						Button("Glass Lozenge") { setFilter(CIFilter.glassLozenge()) }
						Button("Histogram") { setFilter(CIFilter.areaHistogram()) }
						Button("Light Tunnel") { setFilter(CIFilter.lightTunnel()) }
						Button("Cancel", role: .cancel) { }
					}
					
				}
			}
		}
	}
	
	func loadImage() {
		guard let inputImage = inputImage else { return }
		
		let beginImage = CIImage(image: inputImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		applyProcessing()
	}
	
	func setFilter(_ filter: CIFilter) {
		currentFilter = filter
		loadImage()
	}
	
	
	func applyProcessing() {
		
		let inputKeys = currentFilter.inputKeys
		if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
		if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterRadius * Double(filterMultiplier), forKey: kCIInputRadiusKey) }
		if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterScale * Double(filterMultiplier), forKey: kCIInputScaleKey) }
		
		if inputKeys.contains(kCIInputRefractionKey) { currentFilter.setValue(filterRefraction * Double(filterMultiplier), forKey: kCIInputRefractionKey) }
		
		if inputKeys.contains(kCIInputWidthKey) { currentFilter.setValue(filterWidth * Double(filterMultiplier), forKey: kCIInputWidthKey) }
		
		if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x:filterCenter, y:filterCenter), forKey: kCIInputCenterKey) }
		
		
		
		guard let outputImage = currentFilter.outputImage else { return }
		
		if let cgimage = context.createCGImage(outputImage, from: outputImage.extent) {
			let uiImage = UIImage(cgImage: cgimage)
			image = Image(uiImage: uiImage)
			processedImage = uiImage
		}
	}
	
	func save() {
		guard let processedImage else { return }
		
		let imageSaver = ImageSaver()
		
		imageSaver.successHandler = {
			print("Success save")
		}
		
		imageSaver.errorHandler = {
			print("Oops: \($0.localizedDescription)")
		}
		
		imageSaver.writeToPhotoAlbum(image: processedImage)
	}
	
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		
		ContentView()
		
	}
}
